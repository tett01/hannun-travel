import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'demo_city.dart';
import 'osm_service.dart';
import 'place_sync.dart';
import 'summary_service.dart';
import 'tour_service.dart';

/// Accessed from the app as `client.place`.
class PlaceEndpoint extends Endpoint {
  /// Places within the search radius of ([lat], [lng]), nearest first.
  /// The first request for a new area collects its places first.
  /// Korea uses TourAPI/Kakao; elsewhere OpenStreetMap + Wikipedia.
  Future<List<Place>> nearby(Session session, double lat, double lng) async {
    await ensureArea(session, lat, lng);

    // Bounding box first (cheap, uses the DB), exact distance after.
    final dLat = DemoCity.radius / 111000;
    final dLng = DemoCity.radius / (111000 * cos(lat * pi / 180));
    final candidates = await Place.db.find(
      session,
      where: (t) =>
          t.lat.between(lat - dLat, lat + dLat) &
          t.lng.between(lng - dLng, lng + dLng),
    );

    final places = <Place>[];
    for (final p in candidates) {
      p.distance = distanceMeters(lat, lng, p.lat, p.lng);
      if (p.distance! > DemoCity.radius) continue;
      // Korean summaries from the old prompt had factual errors: hide them
      // until redone, so the app shows the official info instead.
      if (p.summaryVersion < SummaryService.versionFor(p) &&
          !p.sourceId.startsWith('osm:')) {
        p
          ..highlightKo = null
          ..highlightEn = null;
      } else if (p.highlightKo != null && p.highlightEn != null) {
        // Also cleans summaries saved before this check existed.
        final (ko, en) = SummaryService.withoutTrivialCaution(
          p.highlightKo!,
          p.highlightEn!,
        );
        p
          ..highlightKo = ko
          ..highlightEn = en;
      }
      places.add(p);
    }
    places.sort((a, b) => a.distance!.compareTo(b.distance!));
    return places;
  }

  /// Stations near ([lat], [lng]) for "near a station" filters, cached per
  /// area since stations rarely move. Empty when unknown.
  Future<List<LocationHit>> stations(
    Session session,
    double lat,
    double lng,
  ) async {
    final key = '${lat.toStringAsFixed(2)},${lng.toStringAsFixed(2)}';
    final cached = _stations[key];
    if (cached != null) return cached;
    try {
      final hits = isInKorea(lat, lng)
          ? await kakaoServiceFor(session)?.stations(lat, lng) ?? []
          : await OsmService().stations(lat, lng);
      if (_stations.length > 200) _stations.clear();
      return _stations[key] = hits;
    } catch (e) {
      session.log('stations failed: $e', level: LogLevel.warning);
      return [];
    }
  }

  static final _stations = <String, List<LocationHit>>{};

  /// Where to buy local specialties and souvenirs near ([lat], [lng]):
  /// markets, craft shops and specialty stores first, nearest first within
  /// each kind. Korea: TourAPI shopping info + Kakao; elsewhere OpenStreetMap.
  Future<List<ShopHit>> souvenirs(
    Session session,
    double lat,
    double lng,
  ) async {
    final key = '${lat.toStringAsFixed(2)},${lng.toStringAsFixed(2)}';
    final cached = _souvenirs[key];
    if (cached != null) return cached;
    final found = <ShopHit>[];
    Future<void> add(Future<List<ShopHit>> f) async {
      try {
        found.addAll(await f.timeout(const Duration(seconds: 20)));
      } catch (e) {
        session.log('souvenirs failed: $e', level: LogLevel.warning);
      }
    }

    if (isInKorea(lat, lng)) {
      final tourKey = session.passwords['tourApiKey'] ?? '';
      await Future.wait([
        if (tourKey.isNotEmpty) add(TourService(tourKey).shops(lat, lng)),
        if (kakaoServiceFor(session) case final kakao?)
          add(kakao.souvenirShops(lat, lng)),
      ]);
    } else {
      await add(OsmService().souvenirShops(lat, lng));
    }

    // Kinds take turns so markets don't crowd out craft and specialty
    // shops; within a kind, places with official sale items come first.
    const order = ['market', 'specialty', 'craft', 'souvenir', 'shop', 'mall'];
    // General shops and malls only when they sell something to take home.
    final gifty = RegExp(
      r'공예|기념|특산|전통|인삼|홍삼|한복|건어물|수산|기프트|선물|차|김|도자|한지|'
      r'농산|식품|과자|빵|술|souvenir|gift|craft',
      caseSensitive: false,
    );
    found.removeWhere(
      (h) =>
          (h.kind == 'shop' || h.kind == 'mall') &&
          !gifty.hasMatch(h.items ?? ''),
    );
    final seen = <String>{};
    final groups = [
      for (final kind in order)
        found
            .where(
              (h) => h.kind == kind && seen.add(h.name.replaceAll(' ', '')),
            )
            .toList()
          ..sort((a, b) {
            final s =
                (b.items != null && b.source == 'tour' ? 1 : 0) -
                (a.items != null && a.source == 'tour' ? 1 : 0);
            if (s != 0) return s;
            return distanceMeters(lat, lng, a.lat, a.lng) -
                distanceMeters(lat, lng, b.lat, b.lng);
          }),
    ];
    final result = <ShopHit>[];
    for (var i = 0; groups.any((g) => i < g.length); i++) {
      for (final g in groups) {
        if (i < g.length) result.add(g[i]);
      }
    }
    final top = result.take(20).toList();
    // Only cache a full answer, so a slow API is retried next time.
    if (top.isNotEmpty) {
      if (_souvenirs.length > 200) _souvenirs.clear();
      _souvenirs[key] = top;
    }
    return top;
  }

  static final _souvenirs = <String, List<ShopHit>>{};

  /// Neighborhood name such as "해운대구 우동" ('' if unknown).
  Future<String> regionName(
    Session session,
    double lat,
    double lng,
    String language,
  ) async {
    try {
      if (!isInKorea(lat, lng)) {
        return await OsmService().regionName(lat, lng, language);
      }
      return await kakaoServiceFor(session)?.regionName(lat, lng) ?? '';
    } catch (e) {
      session.log('regionName failed: $e', level: LogLevel.warning);
      return '';
    }
  }

  /// Places or addresses matching [query], for picking an area to explore
  /// (e.g. "near my hotel"). Korea comes from Kakao, the rest of the world
  /// from OpenStreetMap. A Korean query lists Kakao first; a query in other
  /// letters lists OpenStreetMap first, since Kakao matches romanized names
  /// poorly ("Gyeongbokgung" finds restaurants named after the palace).
  Future<List<LocationHit>> searchLocation(
    Session session,
    String query,
    String language,
  ) async {
    query = query.trim();
    if (query.isEmpty) return [];
    final kakao = kakaoServiceFor(session);
    Future<List<LocationHit>> safe(Future<List<LocationHit>> f) =>
        f.catchError((Object e) {
          session.log('searchLocation failed: $e', level: LogLevel.warning);
          return <LocationHit>[];
        });
    final results = await Future.wait([
      safe(kakao?.search(query) ?? Future.value([])),
      safe(OsmService().search(query, language)),
    ]);
    final korea = results[0];
    final world = results[1];
    if (!RegExp('[가-힣]').hasMatch(query)) {
      return [...world, ...korea].take(15).toList();
    }
    // Kakao already covers Korea better, so skip OSM's Korean matches then.
    return [
      ...korea,
      ...(korea.isEmpty ? world : world.where((h) => !isInKorea(h.lat, h.lng))),
    ].take(15).toList();
  }
}
