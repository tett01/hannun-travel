import 'package:flutter/foundation.dart';
import 'package:trippick_client/trippick_client.dart';

import '../client.dart';
import '../models/place_view.dart';
import 'location.dart';
import 'traits.dart';

/// Loads places around the current [locationStore] into [placesStore].
Future<void> loadPlaces() async {
  final loc = locationStore.value;
  final places = await client.place.nearby(loc.lat, loc.lng);
  placesStore.value = [for (final p in places) toView(p)];
  souvenirsStore.value = [];
  loadSouvenirs();
  // 역 근처 표시용. 실패해도 장소 목록에는 영향 없음.
  client.place
      .stations(loc.lat, loc.lng)
      .then((s) => stationsStore.value = s)
      .catchError((Object e) {
        stationsStore.value = [];
        return <LocationHit>[];
      });
}

/// 지금 지역의 특산물·기념품 살 곳. 실패하면 빈 목록.
final souvenirsStore = ValueNotifier<List<ShopHit>>([]);

Future<void> loadSouvenirs() async {
  final loc = locationStore.value;
  try {
    final shops = await client.place.souvenirs(loc.lat, loc.lng);
    // 그사이 다른 지역으로 옮겼으면 버림
    if (locationStore.value == loc) souvenirsStore.value = shops;
  } catch (e) {
    debugPrint('loadSouvenirs failed: $e');
  }
}

Future<List<PlaceReport>> loadReports(PlaceView place) =>
    client.report.list(place.dbId);

Future<List<PlaceReport>> addReport(
  PlaceView place, {
  required String kind,
  required String note,
}) => client.report.add(place.dbId, kind, note);

Future<List<UserReview>> loadReviews(PlaceView place) =>
    client.review.list(place.dbId);

/// Posts a review; the server returns the place with a refreshed summary.
Future<PlaceView> addReview(
  PlaceView place, {
  required String author,
  required int rating,
  required String text,
}) async {
  final updated = await client.review.add(place.dbId, author, rating, text);
  final view = toView(updated, distance: place.distance);
  replacePlace(view);
  return view;
}

ReviewSummaryView? _summary(ReviewSummary? s) =>
    s == null ? null : ReviewSummaryView(good: s.good, bad: s.bad, tip: s.tip);

PlaceView toView(Place p, {int? distance}) => PlaceView(
  dbId: p.id!,
  id: p.sourceId,
  name: p.name,
  nameEn: p.nameEn ?? p.name,
  category: PlaceCategory.values.firstWhere(
    (c) => c.name == p.category,
    orElse: () => PlaceCategory.sight,
  ),
  subcategory: p.subcategory,
  address: p.address,
  lat: p.lat,
  lng: p.lng,
  distance: p.distance ?? distance ?? 0,
  reviewCount: p.reviewCount,
  ratingAvg: p.ratingAvg,
  tags: p.tags ?? const [],
  source: p.sourceId.split(':').first,
  tel: p.tel,
  imageUrl: p.imageUrl,
  images: p.images ?? const [],
  overview: p.overview,
  facts: {
    for (final e in (p.facts ?? const <String, String>{}).entries)
      if (!e.key.startsWith('_') && e.key != 'contentTypeId') e.key: e.value,
  },
  factsEn: p.factsEn ?? const {},
  modified: DateTime.tryParse(p.facts?['_modified'] ?? ''),
  isArea: p.facts?['_area'] == 'true',
  highlightKo: _summary(p.highlightKo),
  highlightEn: _summary(p.highlightEn),
  reviewSummaryKo: _summary(p.reviewSummaryKo),
  reviewSummaryEn: _summary(p.reviewSummaryEn),
  reviewSummaryBasis: p.reviewSummaryBasis,
);
