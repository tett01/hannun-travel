import 'package:flutter/material.dart';

import '../l10n.dart';
import '../models/place_view.dart';
import '../theme.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppText.body.copyWith(color: AppColors.ink, fontSize: 15),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.soft,
        hintText: t('search_hint'),
        hintStyle: AppText.body.copyWith(color: AppColors.faint, fontSize: 15),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.faint,
          size: 22,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// 전체 / 명소 / 맛집 / 놀거리 — 밑줄형 탭
class CategoryTabs extends StatelessWidget {
  const CategoryTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PlaceCategory? selected;
  final ValueChanged<PlaceCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <(PlaceCategory?, String)>[
      (null, t('cat_all')),
      for (final c in PlaceCategory.values) (c, t('cat_${c.name}')),
    ];
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          for (final (value, label) in items)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: value == selected
                          ? AppColors.ink
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: AppText.body.copyWith(
                    fontSize: 15,
                    color: value == selected ? AppColors.ink : AppColors.faint,
                    fontWeight: value == selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 취향 칩 (전체 탭에서): 힐링 / 액티비티 / 맛집 탐방 / 사진 명소
class TasteChips extends StatelessWidget {
  const TasteChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String? selected;
  final ValueChanged<String?> onChanged;

  static const tastes = ['healing', 'activity', 'food', 'photo'];

  @override
  Widget build(BuildContext context) => _ChipRow(
    items: [for (final k in tastes) (k, t('taste_$k'))],
    selected: selected,
    onChanged: (k) => onChanged(k == selected ? null : k),
  );
}

/// 세부 분류 칩 (카테고리 탭 아래): 전체 · 한식 · 일식 · 카페 …
/// 지금 목록에 있는 분류만 보여줌.
class SubcategoryChips extends StatelessWidget {
  const SubcategoryChips({
    super.key,
    required this.available,
    required this.selected,
    required this.onChanged,
  });

  final List<String> available;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => _ChipRow(
    items: [
      (null, t('sub_all')),
      for (final k in available) (k, t('sub_$k')),
    ],
    selected: selected,
    onChanged: onChanged,
  );
}

/// 가로 스크롤 칩 한 줄 — 선택되면 검정 배경
class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  final List<(String?, String)> items;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final (key, label) = items[i];
          final on = key == selected;
          return GestureDetector(
            onTap: () => onChanged(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? AppColors.ink : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: on ? AppColors.ink : AppColors.line),
              ),
              child: Text(
                label,
                style: AppText.body.copyWith(
                  fontSize: 13,
                  color: on ? Colors.white : AppColors.sub,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
