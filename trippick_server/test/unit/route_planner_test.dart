import 'package:test/test.dart';
import 'package:trippick_server/src/generated/protocol.dart';
import 'package:trippick_server/src/places/route_planner.dart';

Place _place(
  int id,
  String category, {
  Map<String, String>? facts,
  String? sub,
}) => Place(
  id: id,
  sourceId: 'test:$id',
  name: 'P$id',
  category: category,
  subcategory: sub,
  address: '',
  lat: 37.5,
  lng: 127.0,
  facts: facts,
);

void main() {
  group('Hours.parse', () {
    test('reads opening hours and skips the break range', () {
      final h = Hours.parse(
        '- 10:30~21:20 - 준비시간 14:30~16:30 - 마지막 주문 20:40',
        '주말',
      );
      expect(h.open, 630);
      expect(h.close, 1280);
      expect(h.breakStart, 870);
      expect(h.breakEnd, 990);
      expect(h.closedDays, {6, 7});
    });

    test('break time written after the hours', () {
      final h = Hours.parse(
        '11:00 ~ 22:00 (브레이크타임 15:00~16:30)',
        '매주 토요일, 일요일',
      );
      expect(h.open, 660);
      expect(h.breakStart, 900);
      expect(h.closedDays, {6, 7});
    });

    test('always open, closed on Mondays with a note', () {
      final h = Hours.parse('상시 개방', '매주 월요일 ※ 단, 정기휴일이 공휴일이면 개방');
      expect(h.open, 0);
      expect(h.close, 1440);
      expect(h.closedDays, {1});
    });

    test('day ranges and irregular closing days', () {
      expect(Hours.parse(null, '매주 토요일~일요일 / 법정공휴일').closedDays, {6, 7});
      expect(Hours.parse(null, '연중무휴').closedDays, isEmpty);
      expect(Hours.parse(null, '매월 첫째 주 월요일').closedDays, isEmpty);
    });

    test('OpenStreetMap hours and late closing', () {
      expect(Hours.parse('Mo-Su 09:00-18:00', null).open, 540);
      expect(Hours.parse('18:00~02:00', null).close, 1560);
    });
  });

  test('parseFee', () {
    expect(parseFee('무료'), 0);
    expect(parseFee('- 성인(만 19세 이상) 8,000원 - 청소년 5,000원'), 8000);
    expect(parseFee('no'), 0);
    expect(parseFee('yes'), isNull);
    expect(parseFee(null), isNull);
  });

  test('plans avoid a place on its closing day and put lunch near noon', () {
    final museum = _place(
      1,
      'sight',
      facts: {
        'hours': '09:00~18:00',
        'closed': '매주 월요일',
        'fee': '3,000원',
      },
    );
    final lunch = _place(2, 'food', facts: {'hours': '11:00~21:00'});
    final park = _place(3, 'sight', facts: {'hours': '상시 개방', 'fee': '무료'});
    List<List<int>> grid(int v) =>
        List.generate(4, (i) => List.generate(4, (j) => i == j ? 0 : v));

    final plans = RoutePlanner(
      places: [museum, lunch, park],
      minutes: grid(15),
      meters: grid(2000),
      startMin: 9 * 60,
      weekday: 1, // Monday: the museum is closed
      measured: false,
    ).plans();

    expect(plans, isNotEmpty);
    expect(plans.first.kind, 'hours');
    expect(plans.first.issues, 1);
    expect(plans.first.feeTotal, 3000);
    expect(plans.first.mealEstimate, 13000);
    final meal = plans.firstWhere(
      (p) => p.kind == 'meal',
      orElse: () => plans.first,
    );
    final lunchStop = meal.stops.firstWhere((s) => s.placeId == 2);
    expect(
      lunchStop.arriveMin + lunchStop.waitMin,
      greaterThanOrEqualTo(11 * 60),
    );
  });
}
