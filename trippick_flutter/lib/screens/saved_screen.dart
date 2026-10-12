import 'package:flutter/material.dart';

import '../l10n.dart';
import '../models/place_view.dart';
import '../theme.dart';
import '../widgets/place_widgets.dart';
import 'route_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key, required this.places});

  final List<PlaceView> places;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: savedIds,
        builder: (context, saved, _) {
          final list = places.where((p) => saved.contains(p.id)).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Text(t('tab_saved'), style: AppText.title),
                    const Spacer(),
                    // 저장한 곳이 2곳 이상이면 방문 순서를 짜 볼 수 있음
                    if (list.length >= 2)
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RouteScreen(places: list),
                          ),
                        ),
                        icon: const Icon(Icons.route_outlined, size: 18),
                        label: Text(t('route_make')),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bookmark_border,
                              size: 40,
                              color: AppColors.line,
                            ),
                            const SizedBox(height: 12),
                            Text(t('saved_empty'), style: AppText.name),
                            const SizedBox(height: 4),
                            Text(t('saved_empty_sub'), style: AppText.small),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: list.length,
                        itemBuilder: (_, i) => PlaceRow(
                          key: ValueKey(list[i].dbId),
                          place: list[i],
                        ),
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, indent: 20, endIndent: 20),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
