import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'demo_city.dart';
import 'osm_service.dart';
import 'place_sync.dart';
import 'summary_service.dart';

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
