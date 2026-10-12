import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trippick_client/trippick_client.dart';

import '../client.dart';
import '../models/place_view.dart';

/// 이 기기를 구분하는 임의의 id (로그인 없이 내 여행을 서버에 보관하려고).
/// 처음 실행할 때 만들어 기기에 저장합니다.
late final String deviceId;

/// 저장한 여행 목록 (최신순).
final tripsStore = ValueNotifier<List<Trip>>([]);

const _deviceKey = 'deviceId';
const _savedKey = 'savedIds';

/// 기기 id를 준비하고, 저장해 둔 장소 북마크를 불러옵니다.
Future<void> initDeviceData() async {
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPreferences unavailable: $e');
  }
  var id = prefs?.getString(_deviceKey);
  if (id == null || id.length < 16) {
    final r = Random.secure();
    id = List.generate(32, (_) => r.nextInt(16).toRadixString(16)).join();
    await prefs?.setString(_deviceKey, id);
  }
  deviceId = id;

  savedIds.value = {...?prefs?.getStringList(_savedKey)};
  savedIds.addListener(() {
    prefs?.setStringList(_savedKey, savedIds.value.toList());
  });
}

Future<void> loadTrips() async {
  tripsStore.value = await client.trip.list(deviceId);
}

Future<Trip> saveTrip(Trip trip) async {
  final saved = await client.trip.save(deviceId, trip);
  tripsStore.value = [saved, ...tripsStore.value];
  return saved;
}

/// 같은 여행을 고쳐 저장 (다른 루트를 고르거나 이름을 바꿀 때).
Future<Trip> updateTrip(Trip trip) async {
  final saved = await client.trip.update(deviceId, trip);
  tripsStore.value = [
    for (final t in tripsStore.value) t.id == saved.id ? saved : t,
  ];
  return saved;
}

Future<void> deleteTrip(Trip trip) async {
  await client.trip.delete(deviceId, trip.id!);
  tripsStore.value = [
    for (final t in tripsStore.value)
      if (t.id != trip.id) t,
  ];
}
