import 'dart:convert';

import 'package:http/http.dart' as http;

import '../generated/protocol.dart';
import 'demo_city.dart';
import 'subcategory.dart';

/// Fallback place source when TourAPI has too few places in a category.
/// Kakao gives no description or photo, so these places rely on user reviews.
class KakaoService {
  KakaoService(this.apiKey);

  final String apiKey;

  static const _base = 'https://dapi.kakao.com/v2/local/search';

  /// App category -> Kakao category code (AT4 tourist spot, FD6 restaurant)
  /// or keywords for "activity", which has no Kakao category code.
  static const _sources = {
    'sight': (codes: ['AT4'], keywords: <String>[]),
    'food': (codes: ['FD6'], keywords: <String>[]),
    'activity': (codes: <String>[], keywords: ['체험', '서핑', '요트투어']),
  };

  /// "해운대구 우동" style neighborhood name for a coordinate.
  Future<String> regionName(double lat, double lng) async {
    final res = await http.get(
      Uri.parse(
        'https://dapi.kakao.com/v2/local/geo/coord2regioncode.json',
      ).replace(queryParameters: {'x': '$lng', 'y': '$lat'}),
      headers: {'Authorization': 'KakaoAK $apiKey'},
    );
    if (res.statusCode != 200) return '';
    final docs = (jsonDecode(utf8.decode(res.bodyBytes))['documents'] as List)
        .cast<Map<String, dynamic>>();
    final region = docs.firstWhere(
      (d) => d['region_type'] == 'H',
      orElse: () => docs.isEmpty ? const {} : docs.first,
    );
    return [
      region['region_2depth_name'],
      region['region_3depth_name'],
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
  }

  /// Places and addresses matching [query] anywhere in Korea, for the
  /// location search. Place names first, then plain addresses.
  Future<List<LocationHit>> search(String query) async {
    final results = await Future.wait([
      _get('keyword', {'query': query, 'size': '8'}),
      _get('address', {'query': query, 'size': '5'}),
    ]);
    return [
      for (final d in results[0])
        LocationHit(
          name: d['place_name'] as String,
          address: ((d['road_address_name'] as String?) ?? '').isNotEmpty
              ? d['road_address_name'] as String
              : (d['address_name'] as String?) ?? '',
          lat: double.parse(d['y'] as String),
          lng: double.parse(d['x'] as String),
        ),
      for (final d in results[1])
        LocationHit(
          name: d['address_name'] as String,
          address: '',
          lat: double.parse(d['y'] as String),
          lng: double.parse(d['x'] as String),
        ),
    ];
  }

  /// Subway stations within the search radius (Kakao category SW8).
  Future<List<LocationHit>> stations(double lat, double lng) async {
    final hits = <LocationHit>[];
    for (var page = 1; page <= 3; page++) {
      final docs = await _get('category', {
        'category_group_code': 'SW8',
        'x': '$lng',
        'y': '$lat',
        'radius': '${DemoCity.radius}',
        'sort': 'distance',
        'page': '$page',
      });
      for (final d in docs) {
        hits.add(
          LocationHit(
            name: d['place_name'] as String,
            address: (d['category_name'] as String?) ?? '',
            lat: double.parse(d['y'] as String),
            lng: double.parse(d['x'] as String),
          ),
        );
      }
      if (docs.length < 15) break;
    }
    return hits;
  }

  Future<List<Map<String, dynamic>>> _get(
    String path,
    Map<String, String> params,
  ) async {
    final uri = Uri.parse('$_base/$path.json').replace(queryParameters: params);
    final res = await http.get(
      uri,
      headers: {'Authorization': 'KakaoAK $apiKey'},
    );
    if (res.statusCode != 200) {
      throw Exception('Kakao API ${res.statusCode}: ${res.body}');
    }
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return (body['documents'] as List).cast<Map<String, dynamic>>();
  }

  /// Kind of a place stored before subcategories existed, found again by
  /// searching its name next to its coordinates.
  Future<String> subcategoryOf(Place place) async {
    final docs = await _get('keyword', {
      'query': place.name,
      'x': '${place.lng}',
      'y': '${place.lat}',
      'radius': '300',
      'size': '1',
    });
    return Subcategory.fromKakao(
      place.category,
      docs.isEmpty ? '' : (docs.first['category_name'] as String?) ?? '',
    );
  }

  /// Keywords for indoor fun (arcades, escape rooms, bowling, kids' play
  /// cafés, indoor racing). TourAPI lists almost none of these.
  static const _indoorKeywords = ['오락실', '방탈출', '볼링장', '키즈카페', '서킷'];

  /// Indoor fun near ([lat], [lng]): the best few per keyword, keeping only
  /// results Kakao files as leisure (e.g. "서킷" also finds car services).
  Future<List<Place>> indoorFun(
    double lat,
    double lng, {
    int perKeyword = 3,
  }) async {
    final params = {
      'x': '$lng',
      'y': '$lat',
      'radius': '${DemoCity.radius}',
      'sort': 'accuracy',
      'size': '15',
    };
    final seen = <String>{};
    final places = <Place>[];
    for (final kw in _indoorKeywords) {
      final docs = await _get('keyword', {...params, 'query': kw});
      places.addAll(
        docs
            .where((d) => isIndoorFun((d['category_name'] as String?) ?? ''))
            .where((d) => seen.add(d['id'] as String))
            .take(perKeyword)
            .map((d) => _place(d, 'activity')),
      );
    }
    return places;
  }

  Place _place(Map<String, dynamic> d, String category) {
    final phone = (d['phone'] as String?) ?? '';
    final road = (d['road_address_name'] as String?) ?? '';
    return Place(
      sourceId: 'kakao:${d['id']}',
      name: d['place_name'] as String,
      category: category,
      subcategory: Subcategory.fromKakao(
        category,
        (d['category_name'] as String?) ?? '',
      ),
      address: road.isNotEmpty ? road : (d['address_name'] as String?) ?? '',
      lat: double.parse(d['y'] as String),
      lng: double.parse(d['x'] as String),
      tel: phone.isEmpty ? null : phone,
    );
  }

  Future<List<Place>> nearby(
    String category,
    int limit,
    double lat,
    double lng,
  ) async {
    final src = _sources[category]!;
    final params = {
      'x': '$lng',
      'y': '$lat',
      'radius': '${DemoCity.radius}',
      'sort': 'accuracy',
      'size': '15',
    };
    final docs = [
      for (final code in src.codes)
        ...await _get('category', {...params, 'category_group_code': code}),
      for (final kw in src.keywords)
        ...await _get('keyword', {...params, 'query': kw}),
    ];

    final seen = <String>{};
    final places = <Place>[];
    for (final d in docs) {
      if (!seen.add(d['id'] as String)) continue;
      places.add(_place(d, category));
      if (places.length >= limit) break;
    }
    return places;
  }
}
