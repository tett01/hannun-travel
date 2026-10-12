import 'package:flutter/material.dart';
import 'package:trippick_client/trippick_client.dart';

import '../data/trips.dart';
import '../l10n.dart';
import '../theme.dart';

/// 내 여행: 루트 화면에서 저장한 여행이 최신순으로 쌓입니다.
class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      await loadTrips();
    } catch (e) {
      debugPrint('loadTrips failed: $e');
      _failed = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _delete(Trip trip) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('trip_delete_q')),
        content: Text(trip.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.bad),
            child: Text(t('delete')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await deleteTrip(trip);
    } catch (e) {
      debugPrint('deleteTrip failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: tripsStore,
        builder: (context, trips, _) {
          final places = trips.fold<int>(
            0,
            (n, trip) => n + trip.days.fold(0, (m, d) => m + d.placeIds.length),
          );
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Text(t('trips_title'), style: AppText.title),
                if (trips.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      t('trips_count', n: trips.length) +
                          t('trips_places', n: places),
                      style: AppText.small,
                    ),
                  ),
                const SizedBox(height: 16),
                if (_loading && trips.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_failed && trips.isEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 60),
                      Text(t('trips_failed'), style: AppText.name),
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: _load, child: Text(t('retry'))),
                    ],
                  )
                else if (trips.isEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 60),
                      const Icon(
                        Icons.luggage_outlined,
                        size: 40,
                        color: AppColors.line,
                      ),
                      const SizedBox(height: 12),
                      Text(t('trips_empty'), style: AppText.name),
                      const SizedBox(height: 4),
                      Text(t('trips_empty_sub'), style: AppText.small),
                    ],
                  )
                else
                  for (final trip in trips)
                    _TripCard(
                      trip: trip,
                      onDelete: () => _delete(trip),
                    ),
                const SizedBox(height: 12),
                Text(t('trip_device_note'), style: AppText.caption),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.onDelete});

  final Trip trip;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final days = [...trip.days]..sort((a, b) => a.day - b.day);
    final first = days.first.date.replaceAll('-', '.');
    final last = days.last.date.replaceAll('-', '.');
    final cost = days.fold<int>(0, (n, d) => n + d.cost);
    final meta = [
      trip.area,
      first == last ? first : '$first – ${last.substring(5)}',
      t('trip_days', n: days.length),
      if (cost > 0) t('trip_cost', n: _won(cost)),
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          expandedAlignment: Alignment.centerLeft,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          title: Text(trip.title, style: AppText.name),
          subtitle: Text(meta.join(' · '), style: AppText.small),
          trailing: IconButton(
            tooltip: t('delete'),
            icon: const Icon(Icons.delete_outline, color: AppColors.faint),
            onPressed: onDelete,
          ),
          children: [
            for (final d in days)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t('route_day', n: d.day + 1)} · '
                      '${d.date.substring(5).replaceAll('-', '/')} · '
                      '${t('mode_${d.mode}')} · ${t('route_${d.kind}')}',
                      style: AppText.caption.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (final s in d.stops)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          s,
                          style: AppText.body.copyWith(color: AppColors.ink),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _won(int won) {
  final s = won.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return lang.value == Lang.en ? '₩$s' : '$s원';
}
