import 'package:flutter/material.dart';

import '../l10n.dart';
import '../models/place_view.dart';
import '../theme.dart';
import '../widgets/filters.dart';
import '../widgets/location_picker.dart';
import '../widgets/place_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.places});

  final List<PlaceView> places;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlaceCategory? _category;
  String? _taste;
  String _query = '';

  List<PlaceView> get _filtered {
    final q = _query.trim().toLowerCase();
    final list = widget.places.where((p) {
      if (_category != null && p.category != _category) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.nameEn.toLowerCase().contains(q);
    }).toList();
    return recommend(list, _taste);
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final featured = recommend(
      widget.places,
      _taste,
    ).where((p) => p.imageUrl != null || p.oneLiner != null).take(5).toList();
    final showFeatured = _category == null && _query.isEmpty;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedFilters(
              child: Column(
                children: [
                  CategoryTabs(
                    selected: _category,
                    onChanged: (c) => setState(() => _category = c),
                  ),
                  TasteChips(
                    selected: _taste,
                    onChanged: (v) => setState(() => _taste = v),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
          ),
          if (showFeatured) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 2),
                child: Text(t('for_you'), style: AppText.section),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Text(t('for_you_sub'), style: AppText.small),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 222,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => FeaturedCard(place: featured[i]),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Divider(height: 8, thickness: 8, color: AppColors.soft),
            ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Text(t('nearby'), style: AppText.section),
                  const SizedBox(width: 6),
                  Text(
                    t('count', n: list.length),
                    style: AppText.section.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ),
          if (list.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Center(child: Text(t('empty'), style: AppText.body)),
              ),
            )
          else
            SliverList.separated(
              itemCount: list.length,
              itemBuilder: (_, i) => PlaceRow(place: list[i]),
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 20, endIndent: 20),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LocationButton(),
                ),
              ),
              TextButton(
                onPressed: () =>
                    lang.value = lang.value == Lang.ko ? Lang.en : Lang.ko,
                style: TextButton.styleFrom(foregroundColor: AppColors.sub),
                child: Text(
                  t('lang_toggle'),
                  style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SearchField(onChanged: (v) => setState(() => _query = v)),
          ),
        ],
      ),
    );
  }
}

class _PinnedFilters extends SliverPersistentHeaderDelegate {
  _PinnedFilters({required this.child});

  final Widget child;
  static const _height = 101.0;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(color: AppColors.bg, child: child);

  @override
  bool shouldRebuild(covariant _PinnedFilters old) => true;
}
