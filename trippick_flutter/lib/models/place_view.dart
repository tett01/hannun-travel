import 'package:flutter/foundation.dart';

import '../l10n.dart';

enum PlaceCategory { sight, food, activity }

class ReviewSummaryView {
  const ReviewSummaryView({
    required this.good,
    required this.bad,
    required this.tip,
  });
  final String good;
  final String bad;
  final String tip;
}

/// 화면에서 쓰는 장소 정보 (서버의 Place 모델에서 변환).
class PlaceView {
  const PlaceView({
    required this.dbId,
    required this.id,
    required this.name,
    required this.nameEn,
    required this.category,
    this.subcategory,
    required this.address,
    required this.lat,
    required this.lng,
    required this.distance,
    required this.reviewCount,
    required this.tags,
    required this.source,
    this.ratingAvg,
    this.tel,
    this.imageUrl,
    this.images = const [],
    this.overview,
    this.facts = const {},
    this.factsEn = const {},
    this.modified,
    this.isArea = false,
    this.highlightKo,
    this.highlightEn,
    this.reviewSummaryKo,
    this.reviewSummaryEn,
    this.reviewSummaryBasis = 0,
  });

  final int dbId;
  final String id;
  final String name;
  final String nameEn;
  final PlaceCategory category;

  /// Finer kind inside [category], e.g. korean / cafe (see `sub_*` strings).
  final String? subcategory;
  final String address;
  final double lat;
  final double lng;
  final int distance; // meters
  final int reviewCount;
  final double? ratingAvg;
  final List<String> tags; // healing, activity, food, photo
  /// tour (Korea Tourism Organization) | kakao | osm (OpenStreetMap)
  final String source;
  bool get isOfficial => source == 'tour';
  final String? tel;
  final String? imageUrl;

  /// More photos besides [imageUrl].
  final List<String> images;
  final String? overview;
  final Map<String, String> facts;
  final Map<String, String> factsEn;

  /// When the official info was last updated (TourAPI).
  final DateTime? modified;

  /// A wide area (zone, street, trail) rather than one building.
  final bool isArea;
  final ReviewSummaryView? highlightKo;
  final ReviewSummaryView? highlightEn;
  final ReviewSummaryView? reviewSummaryKo;
  final ReviewSummaryView? reviewSummaryEn;
  final int reviewSummaryBasis;

  bool get _en => lang.value == Lang.en;
  String get displayName => _en ? nameEn : name;
  ReviewSummaryView? get _aiHighlight => _en ? highlightEn : highlightKo;

  /// AI 요약, 아직 없으면 공식 정보를 그대로 옮긴 요약.
  ReviewSummaryView? get highlight => _aiHighlight ?? officialExcerpt;

  /// [highlight]가 AI 요약이 아니라 공식 정보 발췌인지.
  bool get highlightIsExcerpt => _aiHighlight == null && highlight != null;

  /// AI 없이 공식 정보에서 바로 뽑은 3줄 (AI 한도와 무관, 지어내지 않음).
  /// 관광공사 소개는 한국어라 영어 모드에서는 위키백과 소개만 씀.
  ReviewSummaryView? get officialExcerpt {
    final f = facts; // 영어 번역은 AI 요약과 함께 생기므로 원문 사용
    final useOverview = !_en || source == 'osm';
    var good = '';
    final text = (useOverview ? overview : null)?.trim() ?? '';
    if (text.isNotEmpty) {
      final end = RegExp(r'[.!?。](\s|$)').firstMatch(text)?.start;
      good = end == null ? text : text.substring(0, end + 1);
      if (good.length > 80) good = '${good.substring(0, 78)}…';
    }
    if (_en && source != 'osm') return null;

    final cautions = <String>[
      if (f['closed'] != null && !RegExp('연중무휴|없음').hasMatch(f['closed']!))
        '${t('fact_closed')}: ${f['closed']}',
      ?RegExp(
        r'(준비시간|브레이크타임|브레이크 타임|휴게시간)[^-/,]*',
      ).firstMatch(f['hours'] ?? '')?.group(0)?.trim(),
      if ((f['parking'] ?? '').contains('불가')) '${t('fact_parking')}: 불가',
    ];
    final tipKey = ['signature', 'fee', 'reservation'].firstWhere(
      (k) => f[k] != null,
      orElse: () => '',
    );
    final tip = tipKey.isEmpty ? '' : '${t('fact_$tipKey')}: ${f[tipKey]}';
    if (good.isEmpty && cautions.isEmpty && tip.isEmpty) return null;
    return ReviewSummaryView(good: good, bad: cautions.join(' · '), tip: tip);
  }

  ReviewSummaryView? get reviewSummary =>
      _en ? reviewSummaryEn : reviewSummaryKo;

  /// 카드에 보여줄 한 줄 소개.
  String? get oneLiner {
    final s = reviewSummary?.good ?? highlight?.good;
    return s == null || s.isEmpty ? null : s;
  }

  /// Practical info in the current language (Korean if not translated).
  Map<String, String> get displayFacts =>
      _en && factsEn.isNotEmpty ? {...facts, ...factsEn} : facts;

  /// All photos, main one first.
  List<String> get photos => [?imageUrl, ...images];

  String get categoryLabel => t('cat_${category.name}');

  String? get subcategoryLabel =>
      subcategory == null ? null : t('sub_$subcategory');

  String get distanceLabel => distance < 1000
      ? '${distance}m'
      : '${(distance / 1000).toStringAsFixed(1)}km';
}

/// 앱 전체가 공유하는 장소 목록. 리뷰를 쓰면 여기서 갱신됩니다.
final placesStore = ValueNotifier<List<PlaceView>>([]);

void replacePlace(PlaceView updated) {
  placesStore.value = [
    for (final p in placesStore.value) p.dbId == updated.dbId ? updated : p,
  ];
}

/// 저장한 장소 id 목록 (지금은 기기 메모리에만 보관).
final savedIds = ValueNotifier<Set<String>>({});

void toggleSaved(String id) {
  final next = {...savedIds.value};
  next.contains(id) ? next.remove(id) : next.add(id);
  savedIds.value = next;
}

/// 취향에 맞는 장소인지. 맛집·놀거리 취향은 카테고리로도 판단.
bool matchesTaste(PlaceView p, String taste) =>
    p.tags.contains(taste) ||
    (taste == 'food' && p.category == PlaceCategory.food) ||
    (taste == 'activity' && p.category == PlaceCategory.activity);

/// 취향 태그가 맞는 곳 먼저, 다음은 요약·사진이 있는 곳, 그다음 가까운 순.
List<PlaceView> recommend(List<PlaceView> places, String? taste) {
  int richness(PlaceView p) =>
      (p.reviewSummaryKo != null ? 2 : 0) +
      (p.highlightKo != null ? 1 : 0) +
      (p.imageUrl != null ? 1 : 0);
  final list = [...places];
  list.sort((a, b) {
    if (taste != null) {
      final m =
          (matchesTaste(b, taste) ? 1 : 0) - (matchesTaste(a, taste) ? 1 : 0);
      if (m != 0) return m;
    }
    final r = richness(b) - richness(a);
    if (r != 0) return r;
    return a.distance.compareTo(b.distance);
  });
  return list;
}
