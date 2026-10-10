import 'package:flutter_test/flutter_test.dart';
import 'package:trippick_flutter/models/place_view.dart';

PlaceView _place({String? overview, Map<String, String> facts = const {}}) =>
    PlaceView(
      dbId: 1,
      id: 'tour:1',
      name: '시즈닝',
      nameEn: 'Seasoning',
      category: PlaceCategory.food,
      address: '경주시',
      lat: 0,
      lng: 0,
      distance: 0,
      reviewCount: 0,
      tags: const [],
      source: 'tour',
      overview: overview,
      facts: facts,
    );

void main() {
  test('official excerpt uses only given info', () {
    final s = _place(
      overview: '시즈닝은 경주시 황남동에 있다. 한옥이어서 외관이 고풍스럽다.',
      facts: {
        'signature': '시즈닝 파스타',
        'hours': '- 10:30~21:00 - 준비시간 15:30~17:00 - 마지막 주문 20:30',
        'closed': '매주 화요일',
        'parking': '불가능',
      },
    ).officialExcerpt!;
    expect(s.good, '시즈닝은 경주시 황남동에 있다.');
    expect(s.bad, '휴무일: 매주 화요일 · 준비시간 15:30~17:00 · 주차: 불가');
    expect(s.tip, '대표 메뉴: 시즈닝 파스타');
  });

  test('nothing to show gives no excerpt', () {
    expect(_place(facts: {'closed': '연중무휴'}).officialExcerpt, isNull);
  });
}
