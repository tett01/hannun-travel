import 'dart:math';

/// Default location (used when the user's location is unknown or outside
/// Korea) and collection settings.
class DemoCity {
  static const lat = 35.1587;
  static const lng = 129.1604;

  /// Search radius in meters (TourAPI and Kakao allow up to 20000).
  static const radius = 6000;

  /// A new area is collected when no collected area is closer than this.
  static const areaReuseDistance = 3000;

  static const placesPerCategory = 12;
}

/// TourAPI and Kakao only cover Korea.
bool isInKorea(double lat, double lng) =>
    lat >= 33.0 && lat <= 38.7 && lng >= 124.5 && lng <= 131.9;

/// Great-circle distance in meters.
int distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  double rad(double d) => d * pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(rad(lat1)) * cos(rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  return (2 * r * asin(sqrt(a))).round();
}
