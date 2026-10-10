import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'demo_city.dart';
import 'osm_service.dart';
import 'place_sync.dart';

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
      if (p.distance! <= DemoCity.radius) places.add(p);
    }
    places.sort((a, b) => a.distance!.compareTo(b.distance!));
    return places;
  }

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
}
