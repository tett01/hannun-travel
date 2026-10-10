import 'package:trippick_client/trippick_client.dart';

import '../client.dart';
import '../models/place_view.dart';
import 'location.dart';

/// Loads places around the current [locationStore] into [placesStore].
Future<void> loadPlaces() async {
  final loc = locationStore.value;
  final places = await client.place.nearby(loc.lat, loc.lng);
  placesStore.value = [for (final p in places) toView(p)];
}

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
  overview: p.overview,
  facts: {
    for (final e in (p.facts ?? const <String, String>{}).entries)
      if (!e.key.startsWith('_') && e.key != 'contentTypeId') e.key: e.value,
  },
  highlightKo: _summary(p.highlightKo),
  highlightEn: _summary(p.highlightEn),
  reviewSummaryKo: _summary(p.reviewSummaryKo),
  reviewSummaryEn: _summary(p.reviewSummaryEn),
  reviewSummaryBasis: p.reviewSummaryBasis,
);
