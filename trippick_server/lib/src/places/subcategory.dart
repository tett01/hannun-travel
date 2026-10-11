/// Finer kinds inside each app category (category -> subcategory), shown in
/// the app as a second row of filters. Labels live in the app (`sub_<key>`).
///
/// sight:    nature | history | culture | leisure | landmark | experience
/// food:     korean | western | japanese | chinese | cafe | other
/// activity: land | water | trail | camping | experience | show | themepark
///           | indoor | other
class Subcategory {
  /// From TourAPI cat2 / cat3 codes.
  static String fromTour(String category, String cat2, String cat3) {
    switch (category) {
      case 'food':
        return switch (cat3) {
          'A05020100' => 'korean',
          'A05020200' => 'western',
          'A05020300' => 'japanese',
          'A05020400' => 'chinese',
          'A05020900' => 'cafe',
          _ => 'other',
        };
      case 'activity':
        if (cat2 == 'A0303') return 'water';
        if (cat3 == 'A03021700') return 'camping';
        if (cat3 == 'A03022700' || cat3 == 'A03020500') return 'trail';
        if (cat2 == 'A0302') return 'land';
        return 'other';
      default:
        if (cat2.startsWith('A01')) return 'nature';
        if (cat2 == 'A0201') return 'history';
        if (cat2 == 'A0206' || cat2 == 'A0207' || cat2 == 'A0208') {
          return 'culture';
        }
        if (cat2 == 'A0202') return 'leisure';
        if (cat2 == 'A0203' && cat3 != 'A02030600') return 'experience';
        return 'landmark';
    }
  }

  /// From a Kakao category_name such as "음식점 > 일식 > 초밥,롤".
  static String fromKakao(String category, String categoryName) {
    final parts = categoryName.split('>').map((s) => s.trim()).toList();
    final kind = parts.length > 1 ? parts[1] : '';
    switch (category) {
      case 'food':
        return switch (kind) {
          '한식' => 'korean',
          '양식' => 'western',
          '일식' => 'japanese',
          '중식' => 'chinese',
          '카페' => 'cafe',
          _ => 'other',
        };
      case 'activity':
        if (isIndoorFun(categoryName)) return 'indoor';
        if (categoryName.contains('캠핑')) return 'camping';
        if (RegExp('서핑|요트|카약|다이빙|낚시').hasMatch(categoryName)) {
          return 'water';
        }
        return 'experience';
      default:
        if (RegExp('문화유적|사찰|궁|유적').hasMatch(categoryName)) {
          return 'history';
        }
        if (RegExp('산|해수욕장|계곡|폭포|섬|자연').hasMatch(categoryName)) {
          return 'nature';
        }
        if (RegExp('박물관|미술관|전시|기념관').hasMatch(categoryName)) {
          return 'culture';
        }
        if (RegExp('공원|온천|테마').hasMatch(categoryName)) return 'leisure';
        return 'landmark';
    }
  }

  /// From OpenStreetMap tags (or, for places stored before subcategories
  /// existed, from the saved facts: menu = cuisine).
  static String fromOsm(String category, Map<String, dynamic> t) {
    String tag(String k) => '${t[k] ?? ''}';
    switch (category) {
      case 'food':
        if (tag('amenity') == 'cafe') return 'cafe';
        final cuisine = '${tag('cuisine')} ${tag('menu')}'.toLowerCase();
        if (cuisine.contains('korean')) return 'korean';
        if (RegExp('japanese|sushi|ramen').hasMatch(cuisine)) {
          return 'japanese';
        }
        if (cuisine.contains('chinese')) return 'chinese';
        if (RegExp('coffee|cafe|tea').hasMatch(cuisine)) return 'cafe';
        if (RegExp(
          'italian|french|pizza|burger|american|steak|spanish|british|'
          'german|european|mediterranean|swedish|greek|international',
        ).hasMatch(cuisine)) {
          return 'western';
        }
        return 'other';
      case 'activity':
        if (RegExp('theme_park|zoo|aquarium|water_park').hasMatch(
          '${tag('tourism')} ${tag('leisure')}',
        )) {
          return 'themepark';
        }
        if (RegExp('cinema|theatre').hasMatch(tag('amenity'))) return 'show';
        if (RegExp(
          '^(bowling_alley|escape_game|amusement_arcade|trampoline_park|'
          'indoor_play)\$',
        ).hasMatch(tag('leisure'))) {
          return 'indoor';
        }
        if (tag('leisure') == 'marina') return 'water';
        if (tag('leisure') == 'park') return 'trail';
        if (tag('leisure').isNotEmpty) return 'land';
        return 'other';
      default:
        if (RegExp('museum|gallery').hasMatch(tag('tourism'))) {
          return 'culture';
        }
        if (tag('historic').isNotEmpty) return 'history';
        if (tag('tourism') == 'viewpoint') return 'nature';
        return 'landmark';
    }
  }
}

/// Indoor fun from a Kakao category_name: arcades, escape rooms, bowling,
/// kids' play cafés, racing simulators ("교통,수송 > 자동차" is how Kakao files
/// indoor racing venues such as 서킷스토리).
bool isIndoorFun(String categoryName) => RegExp(
  '여가시설|놀이시설|키즈카페|볼링|방탈출|오락실|트램폴린|^교통,수송 > 자동차\$',
).hasMatch(categoryName);

/// A wide area rather than one building (tourist zone, street, trail
/// course): opening hours and closing days mean little there.
bool isAreaPlace(String name, String address) =>
    RegExp(r'(특구|관광지구|일대|거리|골목|길|로드|코스|구간)\s*$').hasMatch(name) ||
    RegExp(r'^\[[^\]]+\]').hasMatch(name) ||
    RegExp(r'[동가리],\s*\S+[동가리]').hasMatch(address);
