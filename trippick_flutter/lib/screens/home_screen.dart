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
  String? _subcategory;
  String? _taste;
  String _query = '';

  List<PlaceView> get _filtered {
    final q = _query.trim().toLowerCase();
    final list = widget.places.where((p) {
      if (_category != null && p.category != _category) return false;
      if (_subcategory != null && p.subcategory != _subcategory) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.nameEn.toLowerCase().contains(q);
    }).toList();
    return recommend(list, _taste);
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    // 취향을 고르면 그 취향에 맞는 곳만 (안 맞는 곳으로 채우지 않음).
    final featured = recommend(widget.places, _taste)
        .where((p) => _taste == null || matchesTaste(p, _taste!))
        .where((p) => p.imageUrl != null || p.oneLiner != null)
        .take(5)
        .toList();
    final showFeatured = _category == null && _query.isEmpty;
    // 이 카테고리에 실제로 있는 세부 분류만, 정해진 순서대로.
    final subs = _category == null
        ? const <String>[]
        : _subOrder[_category]!
              .where(
                (k) => widget.places.any(
                  (p) => p.category == _category && p.subcategory == k,
                ),
              )
              .toList();

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
                    onChanged: (c) => setState(() {
                      _category = c;
                      _subcategory = null;
                    }),
                  ),
                  // 전체 탭에서는 취향, 카테고리 탭에서는 세부 분류
                  if (_category == null)
                    TasteChips(
                      selected: _taste,
                      onChanged: (v) => setState(() => _taste = v),
                    )
                  else
                    SubcategoryChips(
                      available: subs,
                      selected: _subcategory,
                      onChanged: (v) => setState(() => _subcategory = v),
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
              child: featured.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Text(t('no_taste_match'), style: AppText.body),
                    )
                  : SizedBox(
                      height: 222,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: featured.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => FeaturedCard(
                          key: ValueKey(featured[i].dbId),
                          place: featured[i],
                        ),
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
              itemBuilder: (_, i) =>
                  PlaceRow(key: ValueKey(list[i].dbId), place: list[i]),
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
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'assets/images/logo_main.png',
                    height: 52,
                    semanticLabel: '한눈에여행 Hannun Travel',
                  ),
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
          const SizedBox(height: 8),
          const Align(alignment: Alignment.centerLeft, child: LocationButton()),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SearchField(onChanged: (v) => setState(() => _query = v)),
          ),
        ],
      ),
    );
  }
}

const _subOrder = {
  PlaceCategory.sight: [
    'nature',
    'history',
    'culture',
    'leisure',
    'landmark',
    'experience',
  ],
  PlaceCategory.food: [
    'korean',
    'western',
    'japanese',
    'chinese',
    'cafe',
    'other',
  ],
  PlaceCategory.activity: [
    'land',
    'water',
    'trail',
    'camping',
    'experience',
    'show',
    'themepark',
    'indoor',
    'other',
  ],
};

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
