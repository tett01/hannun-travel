import 'package:flutter/material.dart';
import 'package:trippick_client/trippick_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../client.dart';
import '../data/location.dart';
import '../data/trips.dart';
import '../l10n.dart';
import '../models/place_view.dart';
import '../theme.dart';
import '../widgets/place_widgets.dart';

/// 저장한 장소들로 방문 순서를 여러 개 짜서 보여 주는 화면.
class RouteScreen extends StatefulWidget {
  const RouteScreen({
    super.key,
    required this.places,
    this.title,
    this.autoPlan = false,
  });

  final List<PlaceView> places;

  /// 화면 제목 (예: 연인 추천 코스). 없으면 "여행 루트".
  final String? title;

  /// 열자마자 루트를 만듦 (추천 코스에서 열 때).
  final bool autoPlan;

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

const _maxStops = 7;

class _RouteScreenState extends State<RouteScreen> {
  /// 고를 수 있는 장소 (근처 추천을 누르면 늘어남).
  late final List<PlaceView> _places = [...widget.places];

  /// 고른 장소 → 며칠째에 갈지 (0 = 첫날).
  late final Map<int, int> _dayOf = {
    for (final p in widget.places.take(_maxStops)) p.dbId: 0,
  };
  int _days = 1;

  /// 장소를 누르면 이 날에 넣음.
  int _editDay = 0;

  String _mode = 'walking';
  // 저녁 늦게나 이른 새벽에는 대부분 문을 닫으므로 내일 오전 10시로 시작.
  static final bool _tomorrow =
      DateTime.now().hour >= 19 || DateTime.now().hour < 7;
  bool _nextDay = _tomorrow;
  late TimeOfDay _start = _nextDay
      ? const TimeOfDay(hour: 10, minute: 0)
      : _roundedNow();

  bool _loading = false;
  bool _failed = false;

  /// 날짜별 루트 후보와, 날짜별로 고른 후보.
  Map<int, List<RoutePlan>>? _plans;
  final Map<int, int> _selected = {};
  int _viewDay = 0;

  static TimeOfDay _roundedNow() {
    final now = DateTime.now();
    final m = (now.hour * 60 + now.minute + 14) ~/ 15 * 15;
    return TimeOfDay(hour: m ~/ 60 % 24, minute: m % 60);
  }

  PlaceView _place(int id) => _places.firstWhere((p) => p.dbId == id);

  List<int> _idsOn(int day) => [
    for (final p in _places)
      if (_dayOf[p.dbId] == day) p.dbId,
  ];

  /// [day]째 날짜 (첫날은 오늘 또는 내일).
  DateTime _date(int day) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + (_nextDay ? 1 : 0) + day);
  }

  String _dayLabel(int day) {
    final d = _date(day);
    return '${t('route_day', n: day + 1)} · ${d.month}/${d.day}';
  }

  bool get _canPlan =>
      _dayOf.length >= 2 &&
      [for (var d = 0; d < _days; d++) d].any((d) => _idsOn(d).isNotEmpty);

  @override
  void initState() {
    super.initState();
    if (widget.autoPlan && _canPlan) _plan();
  }

  /// 고른 곳들의 가운데에서 가까운, 아직 안 고른 곳 (정보 많은 곳 우선).
  List<PlaceView> get _suggestions {
    final picked = _places.where((p) => _dayOf.containsKey(p.dbId)).toList();
    if (picked.isEmpty) return [];
    final lat =
        picked.map((p) => p.lat).reduce((a, b) => a + b) / picked.length;
    final lng =
        picked.map((p) => p.lng).reduce((a, b) => a + b) / picked.length;
    double d(PlaceView p) =>
        (p.lat - lat) * (p.lat - lat) + (p.lng - lng) * (p.lng - lng);
    final hasFood = picked.any((p) => p.category == PlaceCategory.food);
    final candidates =
        placesStore.value
            .where((p) => !_places.any((q) => q.dbId == p.dbId))
            .where((p) => p.imageUrl != null || p.oneLiner != null)
            .toList()
          ..sort((a, b) => d(a).compareTo(d(b)));
    // 식당이 없으면 식당 하나는 꼭 보여 줌
    final food = hasFood
        ? null
        : candidates.where((p) => p.category == PlaceCategory.food).firstOrNull;
    return [
      ?food,
      ...candidates.where((p) => p != food).take(food == null ? 3 : 2),
    ];
  }

  /// 장소를 지금 고르는 날에 넣거나 뺌 (다른 날에 있으면 이 날로 옮김).
  void _toggle(PlaceView p) => _changed(() {
    if (_dayOf[p.dbId] == _editDay) {
      _dayOf.remove(p.dbId);
    } else if (_idsOn(_editDay).length < _maxStops) {
      _dayOf[p.dbId] = _editDay;
    }
  });

  Future<void> _plan() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final loc = locationStore.value;
    final days = [
      for (var d = 0; d < _days; d++)
        if (_idsOn(d).isNotEmpty) d,
    ];
    try {
      final results = await Future.wait([
        for (final d in days)
          client.route.plan(
            _idsOn(d),
            _mode,
            loc.lat,
            loc.lng,
            d == 0 ? _start.hour * 60 + _start.minute : 10 * 60,
            _date(d).weekday,
          ),
      ]);
      if (!mounted) return;
      setState(() {
        _plans = {for (var i = 0; i < days.length; i++) days[i]: results[i]};
        _selected.clear();
        _viewDay = days.first;
        _loading = false;
      });
      _autoSave();
    } catch (e) {
      debugPrint('route.plan failed: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  void _changed(VoidCallback f) => setState(() {
    f();
    _plans = null;
  });

  /// 이 화면에서 만든 루트가 저장된 여행. 루트를 다시 만들거나 다른 후보를
  /// 고르면 새로 쌓지 않고 이 여행을 고칩니다.
  Trip? _trip;
  bool _saveFailed = false;

  String get _area {
    final loc = locationStore.value;
    return lang.value == Lang.en ? loc.labelEn : loc.labelKo;
  }

  /// 지금 고른 후보들로 여행 내용을 만듦.
  List<TripDay> _tripDays() => [
    for (final MapEntry(key: d, value: list) in _plans!.entries)
      if (list.isNotEmpty)
        () {
          final plan = list[(_selected[d] ?? 0).clamp(0, list.length - 1)];
          final date = _date(d);
          return TripDay(
            day: d,
            date:
                '${date.year}-${date.month.toString().padLeft(2, '0')}-'
                '${date.day.toString().padLeft(2, '0')}',
            mode: _mode,
            kind: plan.kind,
            placeIds: [for (final s in plan.stops) s.placeId],
            stops: [
              for (final s in plan.stops)
                '${_fmt(s.arriveMin + s.waitMin)} ${_place(s.placeId).displayName}',
            ],
            travelMin: plan.travelMin,
            cost: plan.feeTotal + plan.mealEstimate,
          );
        }(),
  ];

  /// 루트를 만들면 내 여행에 자동으로 쌓음 (같은 화면에서는 한 여행만 고침).
  Future<void> _autoSave() async {
    final days = _tripDays();
    if (days.isEmpty) return;
    try {
      final trip = _trip == null
          ? await saveTrip(
              Trip(
                deviceId: deviceId,
                title: widget.title ?? t('trip_default_title', n: _area),
                area: _area,
                days: days,
                createdAt: DateTime.now(),
              ),
            )
          : await updateTrip(_trip!.copyWith(days: days, area: _area));
      if (mounted) {
        setState(() {
          _trip = trip;
          _saveFailed = false;
        });
      }
    } catch (e) {
      debugPrint('auto save failed: $e');
      if (mounted) setState(() => _saveFailed = true);
    }
  }

  /// "부산 가족 여행"처럼 이름 바꾸기.
  Future<void> _rename() async {
    final trip = _trip;
    if (trip == null) return;
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        final ctrl = TextEditingController(text: trip.title);
        return AlertDialog(
          title: Text(t('trip_save_title')),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            maxLength: 60,
            decoration: InputDecoration(hintText: t('trip_name_hint')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: Text(t('save')),
            ),
          ],
        );
      },
    );
    if (title == null || title.isEmpty || !mounted) return;
    try {
      final saved = await updateTrip(trip.copyWith(title: title));
      if (mounted) setState(() => _trip = saved);
    } catch (e) {
      debugPrint('rename failed: $e');
      if (mounted) setState(() => _saveFailed = true);
    }
  }

  /// 결과 맨 위: 내 여행에 저장됐는지와 이름 바꾸기.
  Widget _savedBar() {
    final trip = _trip;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      decoration: BoxDecoration(
        color: _saveFailed
            ? AppColors.bad.withValues(alpha: 0.06)
            : AppColors.good.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _saveFailed
                ? Icons.error_outline
                : trip == null
                ? Icons.sync
                : Icons.check_circle_outline,
            size: 18,
            color: _saveFailed ? AppColors.bad : AppColors.good,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _saveFailed
                  ? t('trip_save_failed')
                  : trip == null
                  ? t('trip_saving')
                  : t('trip_auto_saved', n: trip.title),
              style: AppText.body.copyWith(fontSize: 13, color: AppColors.ink),
            ),
          ),
          if (_saveFailed)
            TextButton(onPressed: _autoSave, child: Text(t('retry')))
          else if (trip != null)
            TextButton(onPressed: _rename, child: Text(t('trip_rename'))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? t('route_title'), style: AppText.section),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          // 며칠 일정인지: 날짜를 고른 뒤 그날 갈 곳을 누름
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var d = 0; d < _days; d++)
                ChoiceChip(
                  label: Text(_dayLabel(d)),
                  selected: _editDay == d,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _editDay = d),
                ),
              if (_days < 5)
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: Text(t('route_add_day')),
                  onPressed: () => _changed(() {
                    _days++;
                    _editDay = _days - 1;
                  }),
                ),
              if (_days > 1)
                IconButton(
                  tooltip: t('route_remove_day'),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: () => _changed(() {
                    _dayOf.removeWhere((_, d) => d == _days - 1);
                    _days--;
                    _editDay = _editDay.clamp(0, _days - 1);
                  }),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t(
              _days > 1 ? 'route_pick_day' : 'route_pick',
              n: _days > 1 ? _editDay + 1 : _maxStops,
            ),
            style: AppText.small,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final p in _places)
                FilterChip(
                  label: Text(
                    _dayOf[p.dbId] != null && _dayOf[p.dbId] != _editDay
                        ? '${p.displayName} · ${t('route_day', n: _dayOf[p.dbId]! + 1)}'
                        : p.displayName,
                  ),
                  selected: _dayOf[p.dbId] == _editDay,
                  backgroundColor: _dayOf.containsKey(p.dbId)
                      ? AppColors.soft
                      : null,
                  showCheckmark: false,
                  onSelected: (_) => _toggle(p),
                ),
            ],
          ),
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              t('route_suggest'),
              style: AppText.name.copyWith(fontSize: 14),
            ),
            Text(t('route_suggest_sub'), style: AppText.caption),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in _suggestions)
                  ActionChip(
                    avatar: Icon(categoryIcon(p.category), size: 16),
                    label: Text('${p.displayName} · ${p.categoryLabel}'),
                    onPressed: () => _changed(() {
                      _places.add(p);
                      if (_idsOn(_editDay).length < _maxStops) {
                        _dayOf[p.dbId] = _editDay;
                      }
                    }),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'driving',
                icon: const Icon(Icons.directions_car_outlined, size: 18),
                label: Text(t('mode_driving')),
              ),
              ButtonSegment(
                value: 'walking',
                icon: const Icon(Icons.directions_walk, size: 18),
                label: Text(t('mode_walking')),
              ),
              ButtonSegment(
                value: 'transit',
                icon: const Icon(Icons.directions_subway_outlined, size: 18),
                label: Text(t('mode_transit')),
              ),
            ],
            selected: {_mode},
            showSelectedIcon: false,
            onSelectionChanged: (s) => _changed(() => _mode = s.first),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(t('route_start'), style: AppText.body),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(t(_nextDay ? 'route_tomorrow' : 'route_today')),
                selected: false,
                showCheckmark: false,
                onSelected: (_) => _changed(() => _nextDay = !_nextDay),
              ),
              const SizedBox(width: 6),
              ActionChip(
                avatar: const Icon(Icons.schedule, size: 16),
                label: Text(_fmt(_start.hour * 60 + _start.minute)),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _start,
                  );
                  if (picked != null) _changed(() => _start = picked);
                },
              ),
              const Spacer(),
              FilledButton(
                onPressed: !_canPlan || _loading ? null : _plan,
                child: Text(t('route_go')),
              ),
            ],
          ),
          if (_days > 1)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(t('route_later_days'), style: AppText.caption),
            ),
          if (!_canPlan) ...[
            const SizedBox(height: 8),
            Text(t('route_need_two'), style: AppText.small),
          ],
          const SizedBox(height: 20),
          if (_loading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (_failed)
            Text(t('route_failed'), style: AppText.body)
          else if (_plans != null && _plans!.isNotEmpty)
            ..._results(_plans!),
        ],
      ),
    );
  }

  List<Widget> _results(Map<int, List<RoutePlan>> byDay) {
    final days = byDay.keys.toList();
    final day = days.contains(_viewDay) ? _viewDay : days.first;
    final plans = byDay[day]!;
    if (plans.isEmpty) return [Text(t('route_failed'), style: AppText.body)];
    final selected = (_selected[day] ?? 0).clamp(0, plans.length - 1);
    final plan = plans[selected];
    return [
      _savedBar(),
      if (days.length > 1) ...[
        SegmentedButton<int>(
          segments: [
            for (final d in days)
              ButtonSegment(
                value: d,
                label: Text(t('route_day', n: d + 1)),
              ),
          ],
          selected: {day},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _viewDay = s.first),
        ),
        const SizedBox(height: 4),
        Text(_dayLabel(day), style: AppText.small),
        const SizedBox(height: 10),
      ],
      Wrap(
        spacing: 6,
        children: [
          for (var i = 0; i < plans.length; i++)
            ChoiceChip(
              label: Text(t('route_${plans[i].kind}')),
              selected: i == selected,
              showCheckmark: false,
              onSelected: (_) {
                setState(() => _selected[day] = i);
                _autoSave();
              },
            ),
        ],
      ),
      const SizedBox(height: 12),
      _summary(plan),
      const SizedBox(height: 12),
      for (final stop in plan.stops) _stop(stop),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => _navigate(plan),
        icon: const Icon(Icons.navigation_outlined, size: 18),
        label: Text(t('route_navigate')),
      ),
      const SizedBox(height: 8),
      const SizedBox(height: 10),
      Text(
        t(plan.measured ? 'route_measured' : 'route_estimated'),
        style: AppText.caption,
      ),
      Text(t('check_before'), style: AppText.caption),
    ];
  }

  Widget _summary(RoutePlan plan) {
    final cost = <String>[
      if (plan.feeTotal > 0) '${t('route_fee')} ${_won(plan.feeTotal)}',
      if (plan.feeTotal == 0 && plan.feeUnknown == 0 && plan.mealEstimate == 0)
        t('route_free'),
      if (plan.mealEstimate > 0)
        '${t('route_meal_cost')} ${_won(plan.mealEstimate)}',
      if (plan.feeUnknown > 0) t('route_fee_unknown', n: plan.feeUnknown),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('route_${plan.kind}_sub'), style: AppText.small),
          const SizedBox(height: 6),
          Text(
            '${t('route_travel', n: _duration(plan.travelMin))} · '
            '${_km(plan.distanceM)} · '
            '${t('route_end', n: _fmt(plan.endMin))}',
            style: AppText.name.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            '${t('route_cost')}: ${cost.join(' + ')}',
            style: AppText.body,
          ),
          if (plan.issues > 0) ...[
            const SizedBox(height: 4),
            Text(
              t('route_issues', n: plan.issues),
              style: AppText.body.copyWith(color: AppColors.bad),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stop(RouteStop s) {
    final p = _place(s.placeId);
    final parking = lang.value == Lang.en
        ? (p.factsEn['parking'] ?? p.facts['parking'])
        : p.facts['parking'];
    final noParking =
        parking != null &&
        RegExp(r'불가|없음|no parking', caseSensitive: false).hasMatch(parking);
    final legIcon = switch (_mode) {
      'driving' => Icons.directions_car_outlined,
      'transit' => Icons.directions_subway_outlined,
      _ => Icons.directions_walk,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (s.travelMin > 0)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              children: [
                Icon(legIcon, size: 16, color: AppColors.faint),
                const SizedBox(width: 6),
                Text(
                  '${_duration(s.travelMin)} · ${_km(s.distanceM)}',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
        InkWell(
          onTap: () => openPlace(context, p),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    _fmt(s.arriveMin + s.waitMin),
                    style: AppText.name.copyWith(fontSize: 14),
                  ),
                ),
                PlaceThumb(place: p, width: 44, height: 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.displayName, style: AppText.name),
                      Text(
                        '~${_fmt(s.leaveMin)}'
                        '${p.category == PlaceCategory.food
                            ? ''
                            : s.fee == null
                            ? ''
                            : ' · ${s.fee == 0 ? t('route_free') : _won(s.fee!)}'}',
                        style: AppText.small,
                      ),
                      if (s.waitMin > 0)
                        Text(
                          t('route_wait', n: _duration(s.waitMin)),
                          style: AppText.small.copyWith(color: AppColors.tip),
                        ),
                      if (s.issue != null)
                        Text(
                          t('route_${s.issue}'),
                          style: AppText.small.copyWith(color: AppColors.bad),
                        ),
                      if (_mode == 'driving' && parking != null)
                        Text(
                          '${t('fact_parking')}: $parking',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.small.copyWith(
                            color: noParking ? AppColors.bad : AppColors.good,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 카카오맵(한국) 또는 구글 지도(해외)에서 이 순서대로 길 안내.
  void _navigate(RoutePlan plan) {
    final stops = [for (final s in plan.stops) _place(s.placeId)];
    final loc = locationStore.value;
    final Uri uri;
    if (stops.every((p) => inKorea(p.lat, p.lng))) {
      final by = switch (_mode) {
        'driving' => 'car',
        'transit' => 'traffic',
        _ => 'walk',
      };
      final points = [
        if (loc.isCurrent)
          '${Uri.encodeComponent(t('route_here'))},${loc.lat},${loc.lng}',
        for (final p in stops)
          '${Uri.encodeComponent(p.name)},${p.lat},${p.lng}',
      ];
      uri = Uri.parse('https://map.kakao.com/link/by/$by/${points.join('/')}');
    } else {
      final last = stops.last;
      uri = Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        if (loc.isCurrent) 'origin': '${loc.lat},${loc.lng}',
        'destination': '${last.lat},${last.lng}',
        if (stops.length > 1)
          'waypoints': stops
              .take(stops.length - 1)
              .map((p) => '${p.lat},${p.lng}')
              .join('|'),
        'travelmode': _mode,
      });
    }
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

String _fmt(int minutes) {
  final m = minutes % 1440;
  return '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')}';
}

String _duration(int minutes) {
  if (minutes < 60) return t('min', n: minutes);
  final h = minutes ~/ 60, m = minutes % 60;
  return m == 0 ? t('hours', n: h) : '${t('hours', n: h)} ${t('min', n: m)}';
}

String _km(int meters) =>
    meters < 1000 ? '${meters}m' : '${(meters / 1000).toStringAsFixed(1)}km';

String _won(int won) {
  final s = won.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return lang.value == Lang.en ? '₩$s' : '$s원';
}
