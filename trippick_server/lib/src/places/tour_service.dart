import 'dart:convert';

import 'package:http/http.dart' as http;

import '../generated/protocol.dart';
import 'demo_city.dart';

/// Korea Tourism Organization TourAPI (KorService2).
/// License: KOGL Type 1 — free to use and modify with source attribution.
class TourService {
  TourService(this.serviceKey);

  /// The "Decoding" key from data.go.kr.
  final String serviceKey;

  static const _base = 'https://apis.data.go.kr/B551011/KorService2';

  /// App category -> TourAPI content type ids.
  /// 12 tourist spot, 14 culture facility, 28 leisure sports, 39 restaurant.
  static const categoryTypes = {
    'sight': [12, 14],
    'food': [39],
    'activity': [28],
  };

  /// Which TourAPI intro fields to keep per content type, as fact keys.
  static const _factFields = {
    12: {
      'usetime': 'hours',
      'restdate': 'closed',
      'parking': 'parking',
      'useseason': 'season',
      'expguide': 'experience',
    },
    14: {
      'usetimeculture': 'hours',
      'restdateculture': 'closed',
      'usefee': 'fee',
      'parkingculture': 'parking',
      'spendtime': 'duration',
    },
    28: {
      'usetimeleports': 'hours',
      'restdateleports': 'closed',
      'usefeeleports': 'fee',
      'reservation': 'reservation',
      'openperiod': 'season',
      'parkingleports': 'parking',
    },
    39: {
      'firstmenu': 'signature',
      'treatmenu': 'menu',
      'opentimefood': 'hours',
      'restdatefood': 'closed',
      'parkingfood': 'parking',
      'reservationfood': 'reservation',
      'packing': 'takeout',
    },
  };

  Future<List<Map<String, dynamic>>> _get(
    String op,
    Map<String, String> params,
  ) async {
    final uri = Uri.parse('$_base/$op').replace(
      queryParameters: {
        'serviceKey': serviceKey,
        'MobileOS': 'ETC',
        'MobileApp': 'HannunTravel',
        '_type': 'json',
        ...params,
      },
    );
    final res = await http.get(uri);
    final text = utf8.decode(res.bodyBytes);
    if (res.statusCode != 200 || !text.trimLeft().startsWith('{')) {
      throw Exception(
        'TourAPI $op ${res.statusCode}: ${text.substring(0, text.length.clamp(0, 300))}',
      );
    }
    final body =
        (jsonDecode(text) as Map<String, dynamic>)['response']?['body'];
    final items = body?['items'];
    // When there are no results TourAPI returns "items": "" instead of an object.
    if (items is! Map) return [];
    final item = items['item'];
    if (item is List) return item.cast<Map<String, dynamic>>();
    if (item is Map<String, dynamic>) return [item];
    return [];
  }

  static String clean(Object? v) => '${v ?? ''}'
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Places around the demo city, those with a photo first.
  Future<List<Place>> nearby(
    String category,
    double lat,
    double lng, {
    int limit = DemoCity.placesPerCategory,
  }) async {
    final items = <Map<String, dynamic>>[];
    for (final type in categoryTypes[category]!) {
      items.addAll(
        await _get('locationBasedList2', {
          'mapX': '$lng',
          'mapY': '$lat',
          'radius': '${DemoCity.radius}',
          'contentTypeId': '$type',
          'arrange': 'E',
          'numOfRows': '40',
          'pageNo': '1',
        }),
      );
    }
    bool hasImage(Map<String, dynamic> i) => clean(i['firstimage']).isNotEmpty;
    items.sort((a, b) {
      final img = (hasImage(b) ? 1 : 0) - (hasImage(a) ? 1 : 0);
      if (img != 0) return img;
      return (double.tryParse('${a['dist']}') ?? 0).compareTo(
        double.tryParse('${b['dist']}') ?? 0,
      );
    });

    return [
      for (final i in items.take(limit))
        Place(
          sourceId: 'tour:${i['contentid']}',
          name: clean(i['title']),
          category: category,
          address: clean('${i['addr1'] ?? ''} ${i['addr2'] ?? ''}'),
          lat: double.parse('${i['mapy']}'),
          lng: double.parse('${i['mapx']}'),
          tel: clean(i['tel']).isEmpty ? null : clean(i['tel']),
          imageUrl: hasImage(i)
              ? clean(i['firstimage']).replaceFirst('http://', 'https://')
              : null,
          facts: {'contentTypeId': '${i['contenttypeid']}'},
        ),
    ];
  }

  /// Fills overview and practical facts for a TourAPI place.
  Future<Place> withDetails(Place place) async {
    final contentId = place.sourceId.substring('tour:'.length);
    final typeId = int.parse(place.facts?['contentTypeId'] ?? '12');

    final common = await _get('detailCommon2', {'contentId': contentId});
    final intro = await _get('detailIntro2', {
      'contentId': contentId,
      'contentTypeId': '$typeId',
    });

    final facts = <String, String>{'contentTypeId': '$typeId'};
    if (intro.isNotEmpty) {
      for (final MapEntry(key: field, value: key)
          in (_factFields[typeId] ?? const {}).entries) {
        final v = clean(intro.first[field]);
        if (v.isNotEmpty) facts[key] = v;
      }
    }
    final overview = common.isEmpty ? '' : clean(common.first['overview']);
    return place.copyWith(
      overview: overview.isEmpty ? null : overview,
      facts: facts,
      detailFetchedAt: DateTime.now(),
    );
  }
}
