import 'package:flutter/material.dart';
import 'package:trippick_client/trippick_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../client.dart';
import '../data/location.dart';
import '../l10n.dart';
import '../models/place_view.dart';
import '../theme.dart';
import '../widgets/place_widgets.dart';

/// 저장한 장소들로 방문 순서를 여러 개 짜서 보여 주는 화면.
class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key, required this.places});

  final List<PlaceView> places;

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

const _maxStops = 7;

class _RouteScreenState extends State<RouteScreen> {
  late final Set<int> _picked = {
    for (final p in widget.places.take(_maxStops)) p.dbId,
  };
  String _mode = 'walking';
  late TimeOfDay _start = _roundedNow();

  bool _loading = false;
  bool _failed = false;
  List<RoutePlan>? _plans;
  int _selected = 0;

  static TimeOfDay _roundedNow() {
    final now = DateTime.now();
    final m = (now.hour * 60 + now.minute + 14) ~/ 15 * 15;
    return TimeOfDay(hour: m ~/ 60 % 24, minute: m % 60);
  }

  PlaceView _place(int id) => widget.places.firstWhere((p) => p.dbId == id);

  Future<void> _plan() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final loc = locationStore.value;
    try {
      final plans = await client.route.plan(
        [
          for (final p in widget.places)
            if (_picked.contains(p.dbId)) p.dbId,
        ],
        _mode,
        loc.lat,
        loc.lng,
        _start.hour * 60 + _start.minute,
        DateTime.now().weekday,
      );
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _selected = 0;
        _loading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('route_title'), style: AppText.section),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Text(t('route_pick', n: _maxStops), style: AppText.small),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final p in widget.places)
                FilterChip(
                  label: Text(p.displayName),
                  selected: _picked.contains(p.dbId),
                  showCheckmark: false,
                  onSelected: (on) => _changed(() {
                    if (!on) {
                      _picked.remove(p.dbId);
                    } else if (_picked.length < _maxStops) {
                      _picked.add(p.dbId);
                    }
                  }),
                ),
            ],
          ),
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
                onPressed: _picked.length < 2 || _loading ? null : _plan,
                child: Text(t('route_go')),
              ),
            ],
          ),
          if (_picked.length < 2) ...[
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

  List<Widget> _results(List<RoutePlan> plans) {
    final plan = plans[_selected.clamp(0, plans.length - 1)];
    return [
      Wrap(
        spacing: 6,
        children: [
          for (var i = 0; i < plans.length; i++)
            ChoiceChip(
              label: Text(t('route_${plans[i].kind}')),
              selected: i == _selected,
              showCheckmark: false,
              onSelected: (_) => setState(() => _selected = i),
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
