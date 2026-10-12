import 'dart:math';

import '../generated/protocol.dart';
import 'demo_city.dart';

/// Opening hours read from TourAPI or OpenStreetMap text, as far as a simple
/// parser can tell. Unknown parts stay null so they never cause a warning.
class Hours {
  Hours({
    this.open,
    this.close,
    this.breakStart,
    this.breakEnd,
    this.closedDays = const {},
  });

  /// Minutes after midnight; close may pass 1440 for places open late.
  final int? open;
  final int? close;
  final int? breakStart;
  final int? breakEnd;

  /// Weekly closing days, 1 = Monday ... 7 = Sunday.
  final Set<int> closedDays;

  static final _range = RegExp(
    r'(\d{1,2}):(\d{2})\s*[~\-–]\s*(\d{1,2}):(\d{2})',
  );
  static final _breakWord = RegExp(
    r'(준비|브레이크|break|휴게|쉬는)',
    caseSensitive: false,
  );
  static const _days = {'월': 1, '화': 2, '수': 3, '목': 4, '금': 5, '토': 6, '일': 7};

  factory Hours.parse(String? hours, String? closed) {
    int? open, close, breakStart, breakEnd;
    final h = hours ?? '';
    if (RegExp(r'상시|24시간|24/7').hasMatch(h)) {
      open = 0;
      close = 1440;
    } else {
      for (final m in _range.allMatches(h)) {
        final a = int.parse(m[1]!) * 60 + int.parse(m[2]!);
        var b = int.parse(m[3]!) * 60 + int.parse(m[4]!);
        if (b <= a) b += 1440;
        final before = h.substring(max(0, m.start - 8), m.start);
        if (_breakWord.hasMatch(before)) {
          if (breakStart == null && b - a < 240) {
            breakStart = a;
            breakEnd = b;
          }
        } else if (open == null) {
          open = a;
          close = b;
        }
      }
    }
    return Hours(
      open: open,
      close: close,
      breakStart: breakStart,
      breakEnd: breakEnd,
      closedDays: _closedDays(closed ?? ''),
    );
  }

  /// "매주 월요일", "매주 토요일~일요일", "주말" -> weekdays. Irregular rules
  /// ("격주", "첫째 주") are skipped rather than guessed.
  static Set<int> _closedDays(String text) {
    var s = text.split('※').first;
    if (s.contains('연중무휴') || RegExp(r'격주|째|부정기|비정기').hasMatch(s)) {
      return {};
    }
    final days = <int>{};
    if (s.contains('주말')) days.addAll([6, 7]);
    s = s.replaceAll('주말', '');
    final r = RegExp(r'([월화수목금토일])요일\s*[~\-]\s*([월화수목금토일])요일');
    for (final m in r.allMatches(s)) {
      final a = _days[m[1]]!, b = _days[m[2]]!;
      for (var d = a; ; d = d % 7 + 1) {
        days.add(d);
        if (d == b) break;
      }
    }
    s = s.replaceAll(r, '');
    for (final m in RegExp(r'([월화수목금토일])요일').allMatches(s)) {
      days.add(_days[m[1]]!);
    }
    return days;
  }
}

/// Admission fee in won: 0 when free, the first price (usually adults)
/// otherwise, null when the text doesn't say.
int? parseFee(String? text) {
  if (text == null || text.trim().isEmpty) return null;
  final t = text.trim();
  if (t == 'no') return 0; // OpenStreetMap fee=no
  final m = RegExp(r'(\d{1,3}(?:,\d{3})+|\d+)\s*원').firstMatch(t);
  if (m != null) return int.parse(m[1]!.replaceAll(',', ''));
  if (t.contains('무료')) return 0;
  return null;
}

/// How long a traveler usually spends at a place, in minutes.
int stayMinutes(Place p) => switch ((p.category, p.subcategory)) {
  ('food', 'cafe') => 40,
  ('food', _) => 60,
  ('activity', _) => 90,
  _ => 60,
};

/// Food spend per person in won for one meal (rough, Korea only).
int mealWon(Place p) => p.subcategory == 'cafe' ? 7000 : 13000;

/// Travel time and distance between points when no road data is available:
/// straight line times a detour factor at an average speed.
({int min, int meters}) estimateLeg(
  double lat1,
  double lng1,
  double lat2,
  double lng2,
  String mode,
) {
  final meters = (distanceMeters(lat1, lng1, lat2, lng2) * 1.3).round();
  final km = meters / 1000;
  final min = switch (mode) {
    'driving' => km / 30 * 60 + 5, // city speed + parking
    'walking' => km / 4.5 * 60,
    // Short hops are walked; longer ones by bus or subway, with waiting.
    _ => km < 1.2 ? km / 4.5 * 60 : km / 20 * 60 + 10,
  };
  return (min: min.round(), meters: meters);
}

/// Builds up to three different visiting orders for [places].
/// [minutes] and [meters] are square matrices over [start] + places
/// (index 0 is the start point).
class RoutePlanner {
  RoutePlanner({
    required this.places,
    required this.minutes,
    required this.meters,
    required this.startMin,
    required this.weekday,
    required this.measured,
  }) : hours = [
         for (final p in places)
           Hours.parse(p.facts?['hours'], p.facts?['closed']),
       ];

  final List<Place> places;
  final List<List<int>> minutes;
  final List<List<int>> meters;
  final int startMin;
  final int weekday;
  final bool measured;
  final List<Hours> hours;

  List<RoutePlan> plans() {
    final orders = _permutations(List.generate(places.length, (i) => i));
    final sims = [for (final o in orders) _simulate(o)];

    _Sim best(num Function(_Sim) score) =>
        sims.reduce((a, b) => score(b) < score(a) ? b : a);

    final picks = <String, _Sim>{
      'fast': best((s) => s.travel * 1000 + s.end),
      'hours': best((s) => s.issues * 100000 + s.end),
    };
    if (places.any((p) => p.category == 'food' && p.subcategory != 'cafe')) {
      picks['meal'] = best(
        (s) => s.issues * 100000 + s.mealPenalty * 3 + s.end,
      );
    }

    final seen = <String>{};
    final result = <RoutePlan>[];
    // Opening hours first: it is the one most travelers can follow as is.
    for (final kind in ['hours', 'meal', 'fast']) {
      final s = picks[kind];
      if (s == null || !seen.add(s.order.join(','))) continue;
      result.add(_toPlan(kind, s));
    }
    return result;
  }

  _Sim _simulate(List<int> order) {
    var now = startMin;
    var prev = 0;
    var travel = 0, issues = 0, mealPenalty = 0;
    final stops = <RouteStop>[];
    for (final i in order) {
      final leg = minutes[prev][i + 1];
      travel += leg;
      final arrive = now + leg;
      var wait = 0;
      String? issue;
      final h = hours[i];
      if (h.closedDays.contains(weekday)) {
        issue = 'closed_day';
      } else if (h.open != null && h.close != null) {
        // Compare within one day, also for times past midnight.
        var at = arrive % 1440;
        if (at < h.open! && arrive % 1440 + 1440 < h.close!) at += 1440;
        if (at < h.open! && h.open! - at <= 180) {
          wait = h.open! - at;
        } else if (at < h.open!) {
          issue = 'closed_hours';
        }
        final t = at + wait;
        if (issue == null &&
            h.breakStart != null &&
            t >= h.breakStart! &&
            t < h.breakEnd!) {
          wait += h.breakEnd! - t;
        }
        if (issue == null && at + wait >= h.close!) issue = 'closed_hours';
      }
      if (issue != null) issues++;
      final p = places[i];
      if (p.category == 'food' && p.subcategory != 'cafe') {
        final at = (arrive + wait) % 1440;
        mealPenalty += min((at - 12 * 60).abs(), (at - 18 * 60).abs());
      }
      final leave = arrive + wait + stayMinutes(p);
      stops.add(
        RouteStop(
          placeId: p.id!,
          travelMin: leg,
          distanceM: meters[prev][i + 1],
          arriveMin: arrive,
          waitMin: wait,
          leaveMin: leave,
          issue: issue,
          fee: p.category == 'food' ? null : parseFee(p.facts?['fee']),
        ),
      );
      now = leave;
      prev = i + 1;
    }
    return _Sim(order, stops, travel, now, issues, mealPenalty);
  }

  RoutePlan _toPlan(String kind, _Sim s) {
    final korea = places.every((p) => isInKorea(p.lat, p.lng));
    var fee = 0, unknown = 0, meal = 0;
    for (var k = 0; k < s.stops.length; k++) {
      final p = places[s.order[k]];
      final stop = s.stops[k];
      if (p.category == 'food') {
        if (korea) meal += mealWon(p);
      } else if (stop.fee == null || !korea) {
        unknown++;
      } else {
        fee += stop.fee!;
      }
    }
    return RoutePlan(
      kind: kind,
      stops: s.stops,
      travelMin: s.travel,
      distanceM: s.stops.fold(0, (a, st) => a + st.distanceM),
      endMin: s.end,
      issues: s.issues,
      feeTotal: fee,
      feeUnknown: unknown,
      mealEstimate: meal,
      measured: measured,
    );
  }

  static List<List<int>> _permutations(List<int> items) {
    if (items.length <= 1) return [items];
    return [
      for (var i = 0; i < items.length; i++)
        for (final rest in _permutations([...items]..removeAt(i)))
          [items[i], ...rest],
    ];
  }
}

class _Sim {
  _Sim(
    this.order,
    this.stops,
    this.travel,
    this.end,
    this.issues,
    this.mealPenalty,
  );

  final List<int> order;
  final List<RouteStop> stops;
  final int travel;
  final int end;
  final int issues;
  final int mealPenalty;
}
