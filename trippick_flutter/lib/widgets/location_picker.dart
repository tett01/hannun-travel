import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippick_client/trippick_client.dart';

import '../client.dart';
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
        // Keeps the search field above the on-screen keyboard.
        padding: EdgeInsets.fromLTRB(
          8,
          20,
          8,
          8 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(t('pick_location'), style: AppText.section),
            ),
            LocationSearch(
              onPicked: (loc) {
                Navigator.of(sheetContext).pop();
                locationStore.value = loc;
              },
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
                if (!context.mounted) return;
                // 직접 누른 경우라 차단됐으면 안내 창을 바로 띄움
                if (result == LocateResult.blocked) {
                  showLocationHelp(context);
                } else if (result != LocateResult.ok) {
                  showLocationResult(context, result);
                }
              },
            ),
            const Divider(indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(t('featured_areas'), style: AppText.caption),
            ),
            // Chips instead of one row per area: a long list ran past the
            // bottom of short phone screens and hid the last city.
            _PresetChips(presets: presetLocations, sheetContext: sheetContext),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(t('abroad'), style: AppText.caption),
            ),
            _PresetChips(presets: abroadLocations, sheetContext: sheetContext),
          ],
        ),
      ),
    ),
  );
}

/// Featured areas as wrapping chips; the area shown now is filled in.
class _PresetChips extends StatelessWidget {
  const _PresetChips({required this.presets, required this.sheetContext});

  final List<AppLocation> presets;
  final BuildContext sheetContext;

  @override
  Widget build(BuildContext context) {
    final current = locationStore.value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final preset in presets)
            _chip(
              preset,
              on:
                  !current.isCurrent &&
                  preset.lat == current.lat &&
                  preset.lng == current.lng,
            ),
        ],
      ),
    );
  }

  Widget _chip(AppLocation preset, {required bool on}) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () {
      Navigator.of(sheetContext).pop();
      locationStore.value = preset;
    },
    child: Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: on ? AppColors.ink : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: on ? AppColors.ink : AppColors.line),
      ),
      child: Text(
        locationLabel(preset),
        style: AppText.body.copyWith(
          fontSize: 14,
          color: on ? Colors.white : AppColors.ink,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

/// Search box for any place or address, e.g. the area around a hotel booked
/// for a coming trip. Searches on submit only: OpenStreetMap's Nominatim
/// forbids search-as-you-type.
class LocationSearch extends StatefulWidget {
  const LocationSearch({super.key, required this.onPicked});

  final ValueChanged<AppLocation> onPicked;

  @override
  State<LocationSearch> createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  final _controller = TextEditingController();
  List<LocationHit>? _hits;
  bool _loading = false;
  bool _failed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty || _loading) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final hits = await client.place.searchLocation(
        query,
        lang.value == Lang.en ? 'en' : 'ko',
      );
      if (mounted) setState(() => _hits = hits);
    } catch (e) {
      debugPrint('searchLocation failed: $e');
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hits = _hits;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: t('loc_search_hint'),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      tooltip: t('loc_search_go'),
                      onPressed: _search,
                    ),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (_failed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(t('loc_search_failed'), style: AppText.caption),
          )
        else if (hits != null && hits.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(t('loc_search_none'), style: AppText.caption),
          )
        else if (hits != null)
          for (final h in hits)
            ListTile(
              dense: true,
              leading: Icon(
                inKorea(h.lat, h.lng) ? Icons.place_outlined : Icons.public,
                color: AppColors.accent,
              ),
              title: Text(h.name, style: AppText.name),
              subtitle: h.address.isEmpty
                  ? null
                  : Text(
                      h.address,
                      style: AppText.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              onTap: () => widget.onPicked(
                AppLocation(
                  lat: h.lat,
                  lng: h.lng,
                  labelKo: h.name,
                  labelEn: h.name,
                ),
              ),
            ),
        if (hits != null || _failed) const Divider(indent: 16, endIndent: 16),
      ],
    );
  }
}

/// Snackbar for a failed location attempt. When access is blocked it offers
/// a "How to turn on" action, since the browser or OS won't ask again.
void showLocationResult(BuildContext context, LocateResult result) {
  final key = switch (result) {
    LocateResult.blocked => 'loc_blocked',
    LocateResult.denied => 'loc_denied',
    _ => 'loc_failed',
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(t(key)),
      duration: const Duration(seconds: 6),
      action: result == LocateResult.blocked
          ? SnackBarAction(
              label: t('loc_how'),
              onPressed: () => showLocationHelp(context),
            )
          : null,
    ),
  );
}

/// Explains how to re-enable location after the user refused once.
void showLocationHelp(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t('loc_help_title')),
      content: Text(t(kIsWeb ? 'loc_help_web' : 'loc_help_app')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(t('close')),
        ),
        if (!kIsWeb)
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Geolocator.openAppSettings();
            },
            child: Text(t('open_settings')),
          ),
      ],
    ),
  );
}
