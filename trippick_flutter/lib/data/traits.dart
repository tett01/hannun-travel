import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:trippick_client/trippick_client.dart';

import '../l10n.dart';
import '../models/place_view.dart';

/// 장소 정보(분류·이름·공식 정보 텍스트)에서 규칙으로 읽어 낸 특징들.
/// AI가 아니라 정해진 규칙이라, 근거가 없으면 null(모름)로 둡니다.

// ── 실내 / 실외 ───────────────────────────────────────────────

const _indoorWords = [
  '아쿠아리움',
  '박물관',
  '미술관',
  '전시',
  '갤러리',
  '키즈카페',
  '볼링',
  '방탈출',
  '오락',
  '게임',
  '실내',
  '체험관',
  '영화',
  '공방',
  '서점',
  '백화점',
  '시장',
  'aquarium',
  'museum',
  'gallery',
  'indoor',
  'mall',
  'cinema',
  'theatre',
  'theater',
];
const _outdoorWords = [
  '해수욕장',
  '해변',
  '공원',
  '산책',
  '둘레길',
  '숲',
  '계곡',
  '전망대',
  '정원',
  'beach',
  'park',
  'garden',
  'trail',
];

/// 실내면 true, 실외면 false, 판단할 근거가 없으면 null.
bool? isIndoor(PlaceView p) {
  final name = '${p.name} ${p.nameEn}'.toLowerCase();
  if (_indoorWords.any(name.contains)) return true;
  if (_outdoorWords.any(name.contains)) return false;
  if (p.isArea) return false;
  return switch ((p.category, p.subcategory)) {
    (PlaceCategory.food, _) => true,
    (_, 'indoor' || 'show' || 'culture') => true,
    (_, 'nature' || 'leisure' || 'landmark' || 'trail') => false,
    (_, 'water' || 'camping' || 'themepark') => false,
    (PlaceCategory.sight, 'history') => false,
    _ => null,
  };
}

// ── 주차 ──────────────────────────────────────────────────────

/// 공식 정보의 주차 항목: 가능 true, 불가 false, 정보 없음 null.
bool? hasParking(PlaceView p) {
  final s = (p.facts['parking'] ?? '').toLowerCase();
  if (s.isEmpty) return null;
  if (RegExp(r'불가|없음|no\b').hasMatch(s)) return false;
  if (RegExp(r'가능|있음|주차장|yes|무료').hasMatch(s)) return true;
  return null;
}

// ── 역 근처 ───────────────────────────────────────────────────

/// 지금 지역의 지하철·기차역 (서버가 카카오/오픈스트리트맵에서 찾아 줌).
final stationsStore = ValueNotifier<List<LocationHit>>([]);

/// 가장 가까운 역과 거리(m). 역 정보가 없으면 null.
({String name, int meters})? nearestStation(PlaceView p) {
  ({String name, int meters})? best;
  for (final s in stationsStore.value) {
    final m = _meters(p.lat, p.lng, s.lat, s.lng);
    if (best == null || m < best.meters) best = (name: s.name, meters: m);
  }
  return best;
}

/// 역에서 걸어서 10분(약 800m) 안쪽인지.
bool nearStation(PlaceView p) => (nearestStation(p)?.meters ?? 99999) <= 800;

/// 걸어서 몇 분 (분당 75m).
int walkMinutes(int meters) => max(1, (meters / 75).round());

int _meters(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  double rad(double d) => d * pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(rad(lat1)) * cos(rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  return (2 * r * asin(sqrt(a))).round();
}

// ── 금액대 ────────────────────────────────────────────────────

/// free 무료 · low ~1.5만원 · mid 1.5~3만원 · high 3만원 이상 (1인 기준).
enum PriceTier { free, low, mid, high }

/// 비싼 메뉴, 저렴한 메뉴를 알려 주는 단어 (식당 가격 데이터가 없어 메뉴로 추정).
const _premiumFood = [
  '오마카세',
  '한우',
  '등심',
  '갈비살',
  '꽃갈비',
  '코스',
  '스시',
  '모둠회',
  '장어',
  '히츠마부시',
  '대게',
  '킹크랩',
  '랍스터',
  '파인다이닝',
  '다이닝',
  '스테이크',
  'omakase',
  'steak',
  'fine dining',
];
const _cheapFood = [
  '국밥',
  '칼국수',
  '국수',
  '곰탕',
  '해장국',
  '라멘',
  '돈가스',
  '돈까스',
  '텐동',
  '우동',
  '김밥',
  '분식',
  '만두',
  '짜장',
  '떡볶이',
  '북어',
  '냉면',
  '밀면',
  '순대',
  '버거',
  '피자',
  'noodle',
  'ramen',
  'burger',
  'pizza',
];

/// 금액대와, 공식 요금이 아니라 추정인지 여부. 모르면 null.
({PriceTier tier, bool estimated})? priceOf(PlaceView p) {
  if (p.category == PlaceCategory.food) {
    if (p.subcategory == 'cafe') return (tier: PriceTier.low, estimated: true);
    final menu =
        '${p.facts['signature'] ?? ''} ${p.facts['menu'] ?? ''} '
                '${p.name}'
            .toLowerCase();
    if (_premiumFood.any(menu.contains)) {
      return (tier: PriceTier.high, estimated: true);
    }
    if (_cheapFood.any(menu.contains)) {
      return (tier: PriceTier.low, estimated: true);
    }
    return menu.trim().isEmpty ? null : (tier: PriceTier.mid, estimated: true);
  }
  final fee = parseFee(p.facts['fee']);
  if (fee == null) {
    // 상시 개방인 공원·거리·해변은 입장료가 없음
    final open = (p.facts['hours'] ?? '').contains('상시') || p.isArea;
    return open && isIndoor(p) == false
        ? (tier: PriceTier.free, estimated: true)
        : null;
  }
  final tier = fee == 0
      ? PriceTier.free
      : fee <= 15000
      ? PriceTier.low
      : fee <= 30000
      ? PriceTier.mid
      : PriceTier.high;
  return (tier: tier, estimated: false);
}

/// 요금 텍스트의 첫 금액(보통 성인), 무료면 0, 알 수 없으면 null.
int? parseFee(String? text) {
  if (text == null || text.trim().isEmpty) return null;
  final s = text.trim();
  if (s == 'no') return 0;
  final m = RegExp(r'(\d{1,3}(?:,\d{3})+|\d+)\s*원').firstMatch(s);
  if (m != null) return int.parse(m[1]!.replaceAll(',', ''));
  if (s.contains('무료')) return 0;
  return null;
}

String priceLabel(PriceTier tier) => t('price_${tier.name}');

// ── 누구와 (연인 · 부모님 · 아이) ──────────────────────────────

/// 아이와 먹기 좋은 메뉴 (맵지 않고 익숙한 음식).
const _kidMenus = [
  '어린이',
  '키즈',
  '돈가스',
  '돈까스',
  '피자',
  '파스타',
  '우동',
  '덮밥',
  '칼국수',
  '만두',
  '곰탕',
  '삼계탕',
  '불고기',
  '갈비',
  '짜장',
  '볶음밥',
  '김밥',
  '버거',
  '텐동',
  '오므라이스',
  '국수',
  '빙수',
  '케이크',
  'kids',
  'pizza',
  'pasta',
  'burger',
];
const _adultOnly = ['술', '하이볼', 'pub', ' bar', '와인', '포차', '이자카야'];

/// 아이와 먹기 좋은 메뉴 하나 (메뉴 정보 근거). 없으면 null.
String? kidMenu(PlaceView p) {
  if (p.category != PlaceCategory.food) return null;
  final name = p.name.toLowerCase();
  if (_adultOnly.any(name.contains)) return null;
  final items = '${p.facts['menu'] ?? ''}/${p.facts['signature'] ?? ''}'
      .split(RegExp(r'[/,·]| 등'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty);
  for (final item in items) {
    if (_kidMenus.any(item.toLowerCase().contains)) return item;
  }
  return null;
}

const companions = ['couple', 'parents', 'kids'];

/// 동행에 얼마나 잘 맞는지 (0이면 맞지 않음). 분류·이름·공식 정보 규칙.
int companionScore(PlaceView p, String who) {
  final name = '${p.name} ${p.nameEn}'.toLowerCase();
  final sub = p.subcategory;
  var score = 0;
  switch (who) {
    case 'kids':
      if (RegExp(
        r'키즈|아쿠아리움|동물|과학|체험|어린이|놀이|테마파크|kids|zoo|aquarium',
      ).hasMatch(name)) {
        score += 3;
      }
      if (sub == 'themepark' || sub == 'experience') score += 2;
      if (sub == 'indoor' && RegExp(r'키즈|볼링|오락').hasMatch(name)) score += 2;
      if (sub == 'culture' || sub == 'nature' || sub == 'leisure') score += 1;
      if (kidMenu(p) != null) score += 2;
      if (RegExp(r'방탈출|사격|술').hasMatch(name)) score = 0;
    case 'parents':
      if (sub == 'history' || sub == 'culture') score += 3;
      if (sub == 'nature' || sub == 'leisure') score += 2;
      if (p.tags.contains('healing')) score += 1;
      if (p.category == PlaceCategory.food && sub == 'korean') score += 2;
      if (hasParking(p) == true) score += 1;
      if (sub == 'indoor' || sub == 'land' || sub == 'water') score = 0;
    case 'couple':
      if (p.tags.contains('photo')) score += 2;
      if (p.tags.contains('healing')) score += 1;
      if (sub == 'cafe' || sub == 'landmark' || sub == 'show') score += 2;
      if (sub == 'experience' && RegExp(r'공방|체험').hasMatch(name)) score += 2;
      if (RegExp(r'방탈출|전망|야경|해변|해수욕장|bar|view').hasMatch(name)) {
        score += 2;
      }
      if (p.category == PlaceCategory.food &&
          (sub == 'western' || sub == 'japanese')) {
        score += 1;
      }
      if (RegExp(r'키즈|어린이').hasMatch(name)) score = 0;
  }
  // 정보가 풍부한 곳을 살짝 우대
  if (score > 0 && p.imageUrl != null) score += 1;
  return score;
}

/// 동행에 맞는 추천 코스: 명소(또는 놀거리) 2곳 + 식당 1곳 + 카페 1곳,
/// 첫 장소 근처(3km 안)에서 고릅니다.
List<PlaceView> companionCourse(List<PlaceView> places, String who) {
  final scored = [
    for (final p in places)
      if (companionScore(p, who) > 0) p,
  ]..sort((a, b) => companionScore(b, who) - companionScore(a, who));
  final spots = scored.where((p) => p.category != PlaceCategory.food).toList();
  if (spots.isEmpty) return [];
  final anchor = spots.first;
  bool near(PlaceView p) =>
      _meters(anchor.lat, anchor.lng, p.lat, p.lng) <= 3000;
  PlaceView? pick(bool Function(PlaceView) test, List<PlaceView> taken) {
    for (final p in scored) {
      if (!taken.contains(p) && near(p) && test(p)) return p;
    }
    return null;
  }

  final course = <PlaceView>[anchor];
  final second = pick((p) => p.category != PlaceCategory.food, course);
  if (second != null) course.add(second);
  final meal = pick(
    (p) => p.category == PlaceCategory.food && p.subcategory != 'cafe',
    course,
  );
  if (meal != null) course.add(meal);
  final cafe = pick((p) => p.subcategory == 'cafe', course);
  if (cafe != null) course.add(cafe);
  return course;
}
