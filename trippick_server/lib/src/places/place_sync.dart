import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'demo_city.dart';
import 'kakao_service.dart';
import 'osm_service.dart';
import 'subcategory.dart';
import 'summary_service.dart';
import 'tour_service.dart';

String _key(Session session, String name) => session.passwords[name] ?? '';

SummaryService? summaryServiceFor(Session session) {
  final key = _key(session, 'groqApiKey');
  if (key.isEmpty) return null;
  return SummaryService(
    key,
    model: session.passwords['groqModel'] ?? 'openai/gpt-oss-120b',
  );
}

KakaoService? kakaoServiceFor(Session session) {
  final key = _key(session, 'kakaoRestKey');
  return key.isEmpty ? null : KakaoService(key);
}

/// Collections in progress, so two requests for the same area share one.
final _collecting = <String, Future<void>>{};

/// Makes sure places around ([lat], [lng]) are in the database.
/// The first visit to an area collects its places (a few seconds); details
/// and AI summaries are then filled in the background.
Future<void> ensureArea(Session session, double lat, double lng) async {
  final areas = await CollectedArea.db.find(session);
  final known = areas.any(
    (a) => distanceMeters(a.lat, a.lng, lat, lng) < DemoCity.areaReuseDistance,
  );
  if (known) {
    // Self-heal: an area recorded earlier but with no places (e.g. the
    // source was down) is forgotten and collected again.
    final dLat = DemoCity.radius / 111000;
    final hasPlaces =
        await Place.db.count(
          session,
          where: (t) => t.lat.between(lat - dLat, lat + dLat),
        ) >
        0;
    if (hasPlaces) return;
    await CollectedArea.db.deleteWhere(
      session,
      where: (t) =>
          t.lat.between(lat - dLat, lat + dLat) &
          t.lng.between(lng - 2 * dLat, lng + 2 * dLat),
    );
  }

  // Collection runs in its own session so it can outlive this request.
  final key = '${(lat * 100).round()}:${(lng * 100).round()}';
  final job = _collecting[key] ??= _collectInOwnSession(lat, lng).whenComplete(
    () {
      _collecting.remove(key);
      unawaited(enrichInBackground());
    },
  );

  // Hosting gateways cut requests at ~40s. Wait at most 25s; if collection
  // is slower, return what is there now and the app retries shortly.
  try {
    await job.timeout(const Duration(seconds: 25));
  } on TimeoutException {
    session.log('[sync] collection near $lat,$lng still running');
  }
}

Future<void> _collectInOwnSession(double lat, double lng) async {
  final session = await Serverpod.instance.createSession();
  try {
    await _collectArea(session, lat, lng);
  } catch (e, st) {
    session.log(
      '[sync] collect failed: $e',
      level: LogLevel.error,
      stackTrace: st,
    );
  } finally {
    await session.close();
  }
}

Future<void> _collectArea(Session session, double lat, double lng) async {
  if (!isInKorea(lat, lng)) return _collectOverseas(session, lat, lng);
  final tourKey = _key(session, 'tourApiKey');
  final kakao = kakaoServiceFor(session);
  if (tourKey.isEmpty && kakao == null) {
    session.log(
      '[sync] no tourApiKey or kakaoRestKey',
      level: LogLevel.warning,
    );
    return;
  }

  final existing = {
    for (final p in await Place.db.find(session)) p.sourceId,
  };
  final places = <Place>[];
  for (final category in TourService.categoryTypes.keys) {
    final found = <Place>[];
    if (tourKey.isNotEmpty) {
      try {
        found.addAll(await TourService(tourKey).nearby(category, lat, lng));
      } catch (e) {
        session.log(
          '[sync] TourAPI $category failed: $e',
          level: LogLevel.warning,
        );
      }
    }
    // Kakao tops up categories where TourAPI has few places.
    final missing = DemoCity.placesPerCategory - found.length;
    if (missing > 0 && kakao != null) {
      try {
        final names = found.map((p) => p.name).toSet();
        final extra = await kakao.nearby(category, missing + 5, lat, lng);
        found.addAll(extra.where((p) => !names.contains(p.name)).take(missing));
      } catch (e) {
        session.log(
          '[sync] Kakao $category failed: $e',
          level: LogLevel.warning,
        );
      }
    }
    places.addAll(found.where((p) => existing.add(p.sourceId)));
  }

  await Place.db.insert(session, places);
  await CollectedArea.db.insertRow(session, CollectedArea(lat: lat, lng: lng));
  session.log('[sync] collected ${places.length} new places near $lat,$lng');
}

Future<void> _collectOverseas(
  Session session,
  double lat,
  double lng,
) async {
  final existing = {
    for (final p in await Place.db.find(session)) p.sourceId,
  };
  final osm = OsmService();
  final places = <Place>[];
  var failed = false;
  for (final category in TourService.categoryTypes.keys) {
    try {
      final found = await osm.nearby(category, lat, lng);
      places.addAll(found.where((p) => existing.add(p.sourceId)));
    } catch (e) {
      failed = true;
      session.log('[sync] OSM $category failed: $e', level: LogLevel.warning);
    }
  }
  if (places.isNotEmpty) await Place.db.insert(session, places);
  // Only mark the area done when every category worked, so a failed one
  // is retried on the next request (existing places are skipped).
  if (!failed) {
    await CollectedArea.db.insertRow(
      session,
      CollectedArea(lat: lat, lng: lng),
    );
  }
  session.log(
    '[sync] collected ${places.length} overseas places near $lat,$lng',
  );
}

bool _enriching = false;
bool _enrichAgain = false;
Timer? _resumeTimer;

/// Runs [enrichPending] in its own session; overlapping calls are merged.
/// If the free AI limits stop it early, it resumes by itself later.
Future<void> enrichInBackground() async {
  if (_enriching) {
    _enrichAgain = true;
    return;
  }
  _enriching = true;
  _resumeTimer?.cancel();
  var unfinished = false;
  try {
    do {
      _enrichAgain = false;
      final session = await Serverpod.instance.createSession();
      try {
        unfinished = !await enrichPending(session);
      } catch (e, st) {
        session.log('[sync] failed: $e', level: LogLevel.error, stackTrace: st);
      } finally {
        await session.close();
      }
    } while (_enrichAgain);
  } finally {
    _enriching = false;
  }
  if (unfinished) {
    _resumeTimer = Timer(const Duration(minutes: 30), enrichInBackground);
  }
}

/// Fills official details (TourAPI), kinds, photos and AI summaries for
/// places missing them. Skips work already done, so it is safe to run
/// repeatedly. Returns false if summaries are left for later (AI limits).
Future<bool> enrichPending(Session session) async {
  final tourKey = _key(session, 'tourApiKey');
  if (tourKey.isNotEmpty) {
    final tour = TourService(tourKey);
    // Places stored before kinds and photos existed are fetched again.
    final pending = await Place.db.find(
      session,
      where: (t) =>
          (t.detailFetchedAt.equals(null) | t.subcategory.equals(null)) &
          t.sourceId.like('tour:%'),
      orderBy: (t) => t.id,
    );
    for (final place in pending) {
      try {
        await Place.db.updateRow(session, await tour.withDetails(place));
      } catch (e) {
        session.log(
          '[sync] detail ${place.name} failed: $e',
          level: LogLevel.warning,
        );
      }
    }
  }

  final kakao = kakaoServiceFor(session);
  if (kakao != null) {
    final pending = await Place.db.find(
      session,
      where: (t) => t.subcategory.equals(null) & t.sourceId.like('kakao:%'),
    );
    for (final place in pending) {
      try {
        await Place.db.updateRow(
          session,
          place.copyWith(subcategory: await kakao.subcategoryOf(place)),
        );
      } catch (e) {
        session.log(
          '[sync] kakao kind ${place.name} failed: $e',
          level: LogLevel.warning,
        );
      }
    }
  }

  final osm = OsmService();
  final osmPending = await Place.db.find(
    session,
    where: (t) => t.detailFetchedAt.equals(null) & t.sourceId.like('osm:%'),
  );
  for (final place in osmPending) {
    try {
      await Place.db.updateRow(session, await osm.withDetails(place));
    } catch (e) {
      session.log(
        '[sync] wiki ${place.name} failed: $e',
        level: LogLevel.warning,
      );
    }
  }
  final osmNoKind = await Place.db.find(
    session,
    where: (t) => t.subcategory.equals(null) & t.sourceId.like('osm:%'),
  );
  for (final place in osmNoKind) {
    await Place.db.updateRow(
      session,
      place.copyWith(
        subcategory: Subcategory.fromOsm(place.category, {...?place.facts}),
      ),
    );
  }

  final summarizer = summaryServiceFor(session);
  if (summarizer == null) {
    session.log(
      '[sync] groqApiKey not set; skipping summaries',
      level: LogLevel.warning,
    );
    return true;
  }
  final toSummarize = await Place.db.find(
    session,
    where: (t) =>
        t.summaryVersion.notEquals(SummaryService.version) &
        (t.detailFetchedAt.notEquals(null) | t.sourceId.like('kakao:%')),
    orderBy: (t) => t.id,
  );
  // Korean places first: they are the demo and had the old prompt's errors.
  toSummarize.sort(
    (a, b) =>
        (a.sourceId.startsWith('osm:') ? 1 : 0) -
        (b.sourceId.startsWith('osm:') ? 1 : 0),
  );
  var done = true;
  for (final place in toSummarize) {
    try {
      final usefulFacts = (place.facts ?? const {}).keys
          .where((k) => !k.startsWith('_') && k != 'contentTypeId')
          .length;
      if ((place.overview ?? '').length <= 20 && usefulFacts < 2) {
        // Nothing official to summarize: only give it an English name.
        final nameEn = place.nameEn ?? await summarizer.translateName(place);
        if (nameEn == null) {
          done = false;
          continue;
        }
        await Place.db.updateRow(
          session,
          place.copyWith(
            nameEn: nameEn,
            summarizedAt: DateTime.now(),
            summaryVersion: SummaryService.version,
          ),
        );
        continue;
      }
      final s = await summarizer.summarizeOfficial(place);
      if (s == null) {
        done = false;
        continue;
      }
      await Place.db.updateRow(
        session,
        place.copyWith(
          highlightKo: s.ko,
          highlightEn: s.en,
          nameEn: s.nameEn.isEmpty ? place.nameEn : s.nameEn,
          factsEn: s.factsEn,
          tags: s.tags,
          summarizedAt: DateTime.now(),
          summaryVersion: SummaryService.version,
        ),
      );
      session.log('[sync] summarized ${place.name}');
    } catch (e) {
      done = false;
      session.log(
        '[sync] summary ${place.name} failed: $e',
        level: LogLevel.warning,
      );
    }
  }
  return done;
}

/// Called on server start: collect the default area if needed, then fill gaps.
Future<void> syncOnStart(Session session) async {
  await ensureArea(session, DemoCity.lat, DemoCity.lng);
  unawaited(enrichInBackground());
}
