import 'dart:convert';

import 'package:http/http.dart' as http;

import '../generated/protocol.dart';
import 'demo_city.dart';

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
      final id = d['id'] as String;
      if (!seen.add(id)) continue;
      final phone = (d['phone'] as String?) ?? '';
      final road = (d['road_address_name'] as String?) ?? '';
      places.add(
        Place(
          sourceId: 'kakao:$id',
          name: d['place_name'] as String,
          category: category,
          address: road.isNotEmpty
              ? road
              : (d['address_name'] as String?) ?? '',
          lat: double.parse(d['y'] as String),
          lng: double.parse(d['x'] as String),
          tel: phone.isEmpty ? null : phone,
        ),
      );
      if (places.length >= limit) break;
    }
    return places;
  }
}
