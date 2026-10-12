import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'demo_city.dart';
import 'route_planner.dart';

/// Accessed from the app as `client.route`.
class RouteEndpoint extends Endpoint {
  /// Most places one route takes (7! orders are still quick to compare).
  static const maxStops = 7;

  /// The start point is ignored when it is farther than this from every
  /// place, e.g. when the traveler is still at home.
  static const maxStartDistance = 30000;

  /// Different visiting orders for [placeIds], starting at ([startLat],
  /// [startLng]) at [startMin] (minutes after midnight) on [weekday]
  /// (1 = Monday). [mode] is driving | walking | transit.
  /// Travel times come from Mapbox when a token is set, else are estimated.
  Future<List<RoutePlan>> plan(
    Session session,
    List<int> placeIds,
    String mode,
    double startLat,
    double startLng,
    int startMin,
    int weekday,
  ) async {
    final ids = placeIds.toSet().take(maxStops).toList();
    if (ids.isEmpty) return [];
    final found = await Place.db.find(
      session,
      where: (t) => t.id.inSet(ids.toSet()),
    );
    final places = [
      for (final id in ids) ...found.where((p) => p.id == id),
    ];
    if (places.isEmpty) return [];

    final nearStart = places.any(
      (p) =>
          distanceMeters(startLat, startLng, p.lat, p.lng) <= maxStartDistance,
    );
    final points = [
      (lat: startLat, lng: startLng),
      for (final p in places) (lat: p.lat, lng: p.lng),
    ];

    final n = points.length;
    final minutes = List.generate(n, (_) => List.filled(n, 0));
    final meters = List.generate(n, (_) => List.filled(n, 0));
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        if (i == j) continue;
        final leg = estimateLeg(
          points[i].lat,
          points[i].lng,
          points[j].lat,
          points[j].lng,
          mode,
        );
        minutes[i][j] = leg.min;
        meters[i][j] = leg.meters;
      }
    }

    // Mapbox has no public transit, so transit stays estimated.
    final token = session.passwords['mapboxToken'] ?? '';
    var measured = false;
    if (token.isNotEmpty && mode != 'transit') {
      try {
        measured = await _mapboxMatrix(token, mode, points, minutes, meters);
      } catch (e) {
        session.log('Mapbox matrix failed: $e', level: LogLevel.warning);
      }
    }

    if (!nearStart) {
      for (var j = 0; j < n; j++) {
        minutes[0][j] = 0;
        meters[0][j] = 0;
      }
    }

    return RoutePlanner(
      places: places,
      minutes: minutes,
      meters: meters,
      startMin: startMin,
      weekday: weekday,
      measured: measured,
    ).plans();
  }

  /// Fills [minutes] and [meters] with road travel from the Mapbox Matrix
  /// API. Cells Mapbox can't route keep their estimate.
  Future<bool> _mapboxMatrix(
    String token,
    String mode,
    List<({double lat, double lng})> points,
    List<List<int>> minutes,
    List<List<int>> meters,
  ) async {
    final profile = mode == 'walking' ? 'walking' : 'driving';
    final coords = points.map((p) => '${p.lng},${p.lat}').join(';');
    final res = await http
        .get(
          Uri.parse(
            'https://api.mapbox.com/directions-matrix/v1/mapbox/$profile/$coords',
          ).replace(
            queryParameters: {
              'annotations': 'duration,distance',
              'access_token': token,
            },
          ),
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['code'] != 'Ok') throw Exception('${body['code']}');
    final durations = body['durations'] as List;
    final distances = body['distances'] as List;
    for (var i = 0; i < points.length; i++) {
      for (var j = 0; j < points.length; j++) {
        if (i == j) continue;
        final d = (durations[i] as List)[j];
        final m = (distances[i] as List)[j];
        if (d == null || m == null) continue;
        // Driving also needs time to find parking.
        minutes[i][j] = ((d as num) / 60).round() + (mode == 'driving' ? 5 : 0);
        meters[i][j] = (m as num).round();
      }
    }
    return true;
  }
}
