import 'package:flutter/material.dart';

import '../l10n.dart';
import '../models/place_view.dart';
import '../theme.dart';
import '../widgets/place_widgets.dart';

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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(t('tab_saved'), style: AppText.title),
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
