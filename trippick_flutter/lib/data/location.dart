import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../client.dart';

/// Where the app is currently showing places for.
class AppLocation {
  const AppLocation({
    required this.lat,
    required this.lng,
    required this.labelKo,
    required this.labelEn,
    this.isCurrent = false,
  });

  final double lat;
  final double lng;
  final String labelKo;
  final String labelEn;

  /// True when this is the device's real position.
  final bool isCurrent;
}

/// Featured areas: Korea first, then cities abroad for visitors elsewhere.
const presetLocations = [
  AppLocation(
    lat: 35.1587,
    lng: 129.1604,
    labelKo: '부산 해운대',
    labelEn: 'Haeundae, Busan',
  ),
  AppLocation(
    lat: 37.5636,
    lng: 126.9834,
    labelKo: '서울 명동',
    labelEn: 'Myeongdong, Seoul',
  ),
  AppLocation(
    lat: 35.8380,
    lng: 129.2100,
    labelKo: '경주 황리단길',
    labelEn: 'Hwangnidan-gil, Gyeongju',
  ),
];

const abroadLocations = [
  AppLocation(
    lat: 59.3251,
    lng: 18.0711,
    labelKo: '스톡홀름 감라스탄',
    labelEn: 'Gamla stan, Stockholm',
  ),
  AppLocation(
    lat: 48.8606,
    lng: 2.3376,
    labelKo: '파리 루브르',
    labelEn: 'Louvre, Paris',
  ),
  AppLocation(
    lat: 35.6595,
    lng: 139.7005,
    labelKo: '도쿄 시부야',
    labelEn: 'Shibuya, Tokyo',
  ),
  AppLocation(
    lat: 40.7580,
    lng: -73.9855,
    labelKo: '뉴욕 미드타운',
    labelEn: 'Midtown, New York',
  ),
];

final locationStore = ValueNotifier<AppLocation>(presetLocations.first);

bool inKorea(double lat, double lng) =>
    lat >= 33.0 && lat <= 38.7 && lng >= 124.5 && lng <= 131.9;

/// [blocked]: the user refused before, so the browser or OS will not ask
/// again until it is re-enabled in settings.
enum LocateResult { ok, denied, blocked, failed }

/// Tries to use the device's position. On success updates [locationStore]
/// with the neighborhood name from the server.
Future<LocateResult> useCurrentLocation() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocateResult.denied;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return LocateResult.blocked;
    }
    if (permission == LocationPermission.denied) {
      return LocateResult.denied;
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
    final korea = inKorea(pos.latitude, pos.longitude);
    final nameKo = await client.place.regionName(
      pos.latitude,
      pos.longitude,
      'ko',
    );
    final nameEn = korea
        ? nameKo
        : await client.place.regionName(pos.latitude, pos.longitude, 'en');
    locationStore.value = AppLocation(
      lat: pos.latitude,
      lng: pos.longitude,
      labelKo: nameKo.isEmpty ? '현재 위치' : nameKo,
      labelEn: nameEn.isEmpty ? 'Current location' : nameEn,
      isCurrent: true,
    );
    return LocateResult.ok;
  } catch (e) {
    debugPrint('useCurrentLocation failed: $e');
    return LocateResult.failed;
  }
}
