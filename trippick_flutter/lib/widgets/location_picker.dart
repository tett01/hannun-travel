import 'package:flutter/material.dart';

import '../data/location.dart';
import '../l10n.dart';
import '../theme.dart';

String locationLabel(AppLocation l) =>
    lang.value == Lang.en ? l.labelEn : l.labelKo;

/// Header button: "해운대구 우동 ⌄" — opens the location picker.
class LocationButton extends StatelessWidget {
  const LocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: locationStore,
      builder: (context, loc, _) => InkWell(
        onTap: () => showLocationPicker(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loc.isCurrent)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.near_me_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
              ),
            Flexible(
              child: Text(
                locationLabel(loc),
                style: AppText.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}

Future<void> showLocationPicker(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(t('pick_location'), style: AppText.section),
            ),
            ListTile(
              leading: const Icon(
                Icons.near_me_rounded,
                color: AppColors.accent,
              ),
              title: Text(t('use_current'), style: AppText.name),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final result = await useCurrentLocation();
                if (result != LocateResult.ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        t(
                          result == LocateResult.denied
                              ? 'loc_denied'
                              : 'loc_failed',
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            const Divider(indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(t('featured_areas'), style: AppText.caption),
            ),
            for (final preset in [...presetLocations, ...abroadLocations]) ...[
              if (identical(preset, abroadLocations.first))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(t('abroad'), style: AppText.caption),
                ),
              ListTile(
                dense: true,
                leading: Icon(
                  inKorea(preset.lat, preset.lng)
                      ? Icons.place_outlined
                      : Icons.public,
                  color: AppColors.faint,
                ),
                title: Text(locationLabel(preset), style: AppText.name),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  locationStore.value = preset;
                },
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
