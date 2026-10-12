import 'dart:convert';

import 'package:http/http.dart' as http;

import '../generated/protocol.dart';
import 'demo_city.dart';
import 'subcategory.dart';

/// Places outside Korea: OpenStreetMap (Overpass API) for places and
/// Wikipedia for descriptions and photos. Both are free and keyless.
/// Data: © OpenStreetMap contributors (ODbL), Wikipedia (CC BY-SA).
class OsmService {
  static const _headers = {
    'User-Agent': 'HannunTravel/1.0 (Serverpod hackathon project)',
  };

  static const _overpass = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
  ];

  /// Overpass tag filters per app category.
  static const _filters = {
    'sight': [
      r'[tourism~"^(attraction|museum|viewpoint|gallery)$"][name][wikidata]',
      r'[historic~"^(monument|castle|memorial|ruins|archaeological_site|palace)$"][name][wikidata]',
    ],
    'food': [r'[amenity~"^(restaurant|cafe)$"][name]'],
    'activity': [
      r'[tourism~"^(theme_park|zoo|aquarium)$"][name]',
      r'[leisure~"^(water_park|park|sports_centre|ice_rink|marina)$"][name][wikidata]',
      r'[amenity~"^(cinema|theatre)$"][name]',
      r'[leisure~"^(bowling_alley|escape_game|amusement_arcade|trampoline_park|indoor_play)$"][name]',
    ],
  };

  static const _searchRadius = 4000;

  Future<List<Map<String, dynamic>>> _query(String query) async {
    Object? lastError;
    for (final url in _overpass) {
      try {
        final res = await http
            .post(Uri.parse(url), headers: _headers, body: {'data': query})
            .timeout(const Duration(seconds: 30));
        if (res.statusCode == 200) {
          final body = jsonDecode(utf8.decode(res.bodyBytes));
          return (body['elements'] as List).cast<Map<String, dynamic>>();
        }
        lastError = 'Overpass ${res.statusCode}';
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception('Overpass failed: $lastError');
  }

  /// Rail, subway and tram stations within the search radius.
  Future<List<LocationHit>> stations(double lat, double lng) async {
    final r = DemoCity.radius;
    final elements = await _query(
      '[out:json][timeout:20];'
      '(node["railway"="station"](around:$r,$lat,$lng);'
      'node["public_transport"="station"](around:$r,$lat,$lng);'
      'node["railway"="tram_stop"](around:$r,$lat,$lng););out;',
    );
    final seen = <String>{};
    return [
      for (final e in elements)
        if (e['tags'] is Map &&
            (e['tags'] as Map)['name'] != null &&
            seen.add('${(e['tags'] as Map)['name']}'))
          LocationHit(
            name: '${(e['tags'] as Map)['name']}',
            address: '',
            lat: (e['lat'] as num).toDouble(),
            lng: (e['lon'] as num).toDouble(),
          ),
    ];
  }

  static String _address(Map<String, dynamic> t) {
    final street = [
      t['addr:street'],
      t['addr:housenumber'],
    ].whereType<String>().join(' ');
    return [
      street,
      t['addr:city'],
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
  }

  /// Facts shown in the app. Keys starting with "_" are internal.
  static Map<String, String> _facts(Map<String, dynamic> t) => {
    if (t['opening_hours'] != null) 'hours': '${t['opening_hours']}',
    if (t['cuisine'] != null) 'menu': '${t['cuisine']}'.replaceAll(';', ', '),
    if (t['fee'] != null) 'fee': '${t['fee']}',
    if ((t['website'] ?? t['contact:website']) != null)
      'website': '${t['website'] ?? t['contact:website']}',
    if (t['wikipedia'] != null) '_wikipedia': '${t['wikipedia']}',
    if (t['wikidata'] != null) '_wikidata': '${t['wikidata']}',
  };

  Future<List<Place>> nearby(
    String category,
    double lat,
    double lng, {
    int limit = DemoCity.placesPerCategory,
  }) async {
    final parts = _filters[category]!
        .map((f) => 'nwr(around:$_searchRadius,$lat,$lng)$f;')
        .join();
    final elements = await _query(
      '[out:json][timeout:30];($parts);out center tags ${category == 'sight' ? 600 : 200};',
    );

    // Well-documented places first (Wikipedia link, more tags), then nearer.
    int score(Map<String, dynamic> e) {
      final t = e['tags'] as Map<String, dynamic>;
      return (t['wikidata'] != null ? 20 : 0) +
          (t['name:en'] != null ? 3 : 0) +
          t.length;
    }

    double eLat(Map<String, dynamic> e) =>
        ((e['lat'] ?? e['center']?['lat']) as num).toDouble();
    double eLng(Map<String, dynamic> e) =>
        ((e['lon'] ?? e['center']?['lon']) as num).toDouble();

    final usable =
        elements
            .where(
              (e) => e['tags'] != null && (e['lat'] ?? e['center']) != null,
            )
            .toList()
          ..sort((a, b) {
            final s = score(b) - score(a);
            if (s != 0) return s;
            return distanceMeters(
              lat,
              lng,
              eLat(a),
              eLng(a),
            ).compareTo(distanceMeters(lat, lng, eLat(b), eLng(b)));
          });

    // The same place can be mapped twice (e.g. building + institution):
    // skip repeats by name and by Wikidata id.
    final seen = <String>{};
    final places = <Place>[];
    for (final e in usable) {
      final t = e['tags'] as Map<String, dynamic>;
      final name = '${t['name']}';
      final wikidata = t['wikidata'] as String?;
      final displayKo = '${t['name:ko'] ?? t['name:en'] ?? name}'.replaceAll(
        '_',
        ' ',
      );
      if (!seen.add('n:$name') ||
          !seen.add('k:$displayKo') ||
          !seen.add('e:${t['name:en'] ?? name}') ||
          (wikidata != null && !seen.add('w:$wikidata'))) {
        continue;
      }
      places.add(
        Place(
          sourceId: 'osm:${e['type']}/${e['id']}',
          name: displayKo,
          nameEn: '${t['name:en'] ?? name}',
          category: category,
          subcategory: Subcategory.fromOsm(category, t),
          address: _address(t),
          lat: eLat(e),
          lng: eLng(e),
          tel: (t['phone'] ?? t['contact:phone']) as String?,
          facts: _facts(t),
        ),
      );
      if (places.length >= limit) break;
    }
    return places;
  }

  /// Adds a Wikipedia description and photo when the place has a wiki link.
  Future<Place> withDetails(Place place) async {
    final facts = {...?place.facts};
    String? lang;
    String? title;

    // Prefer English Wikipedia (via Wikidata), else the linked local article.
    final qid = facts['_wikidata'];
    if (qid != null) {
      try {
        final res = await http.get(
          Uri.parse('https://www.wikidata.org/w/api.php').replace(
            queryParameters: {
              'action': 'wbgetentities',
              'ids': qid,
              'props': 'sitelinks',
              'sitefilter': 'enwiki',
              'format': 'json',
            },
          ),
          headers: _headers,
        );
        final en = jsonDecode(
          utf8.decode(res.bodyBytes),
        )['entities']?[qid]?['sitelinks']?['enwiki']?['title'];
        if (en is String) {
          lang = 'en';
          title = en;
        }
      } catch (_) {}
    }
    final wiki = facts['_wikipedia'];
    if (title == null && wiki != null && wiki.contains(':')) {
      lang = wiki.substring(0, wiki.indexOf(':'));
      title = wiki.substring(wiki.indexOf(':') + 1);
    }

    String? overview;
    String? image;
    if (title != null) {
      // Be polite to Wikimedia: one request at a time with a short pause.
      await Future.delayed(const Duration(milliseconds: 400));
      final res = await http.get(
        Uri.parse(
          'https://$lang.wikipedia.org/api/rest_v1/page/summary/'
          '${Uri.encodeComponent(title.replaceAll(' ', '_'))}',
        ),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(utf8.decode(res.bodyBytes));
        overview = body['extract'] as String?;
        // Use the thumbnail as given: Wikimedia only serves standard sizes.
        image = body['thumbnail']?['source'] as String?;
        facts['_source'] = 'wikipedia:$lang:$title';
      } else if (res.statusCode != 404) {
        // Temporary failure (rate limit etc.): throw so it is retried later.
        throw Exception('Wikipedia ${res.statusCode} for $lang:$title');
      }
    }

    return place.copyWith(
      overview: overview ?? place.overview,
      imageUrl: image ?? place.imageUrl,
      facts: facts,
      detailFetchedAt: DateTime.now(),
    );
  }

  /// "Gamla stan, Stockholm" style name for a coordinate (Nominatim).
  Future<String> regionName(double lat, double lng, String language) async {
    final res = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/reverse').replace(
        queryParameters: {
          'format': 'jsonv2',
          'lat': '$lat',
          'lon': '$lng',
          'zoom': '14',
          'accept-language': language,
        },
      ),
      headers: _headers,
    );
    if (res.statusCode != 200) return '';
    final a = (jsonDecode(utf8.decode(res.bodyBytes))['address'] ?? {}) as Map;
    final local =
        a['suburb'] ?? a['neighbourhood'] ?? a['quarter'] ?? a['city_district'];
    final city = a['city'] ?? a['town'] ?? a['village'] ?? a['state'];
    return [local, city].whereType<String>().toSet().join(', ');
  }

  /// Places and addresses matching [query] worldwide (Nominatim search).
  /// Nominatim allows no search-as-you-type, so call this on submit only.
  Future<List<LocationHit>> search(String query, String language) async {
    final res = await http
        .get(
          Uri.parse('https://nominatim.openstreetmap.org/search').replace(
            queryParameters: {
              'format': 'jsonv2',
              'q': query,
              'limit': '8',
              'accept-language': language,
            },
          ),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return [];
    return [
      for (final d
          in (jsonDecode(utf8.decode(res.bodyBytes)) as List)
              .cast<Map<String, dynamic>>())
        _hit(d),
    ];
  }

  static LocationHit _hit(Map<String, dynamic> d) {
    final full = (d['display_name'] as String?) ?? '';
    final name = (d['name'] as String?) ?? '';
    return LocationHit(
      name: name.isNotEmpty ? name : full.split(',').first,
      // display_name repeats the name first; drop it from the address.
      address: name.isNotEmpty && full.startsWith('$name, ')
          ? full.substring(name.length + 2)
          : full,
      lat: double.parse(d['lat'] as String),
      lng: double.parse(d['lon'] as String),
    );
  }
}
