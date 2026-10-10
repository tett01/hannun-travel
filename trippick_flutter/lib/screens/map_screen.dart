import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/location.dart';
import '../models/place_view.dart';
import '../theme.dart';
import '../widgets/filters.dart';
import '../widgets/place_widgets.dart';

/// 지도 + 하단 장소 카드 슬라이드 (지도 앱에서 흔한 구성)
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.places});

  final List<PlaceView> places;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _map = MapController();
  final _pages = PageController(viewportFraction: 0.88);
  PlaceCategory? _category;
  int _index = 0;

  List<PlaceView> get _visible => widget.places
      .where((p) => _category == null || p.category == _category)
      .toList();

  void _select(int i, {bool fromMarker = false}) {
    final list = _visible;
    if (i >= list.length) return;
    setState(() => _index = i);
    _map.move(LatLng(list[i].lat, list[i].lng), _map.camera.zoom);
    if (fromMarker) {
      _pages.animateToPage(
        i,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void didUpdateWidget(MapScreen old) {
    super.didUpdateWidget(old);
    // New area loaded: recenter on it and start from the first card.
    if (!identical(old.places, widget.places) &&
        (old.places.isEmpty ||
            widget.places.isEmpty ||
            old.places.first.dbId != widget.places.first.dbId)) {
      final loc = locationStore.value;
      _map.move(LatLng(loc.lat, loc.lng), 14);
      _index = 0;
      if (_pages.hasClients) _pages.jumpToPage(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _visible;
    final loc = locationStore.value;

    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: LatLng(loc.lat, loc.lng),
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.hannun.travel',
            ),
            MarkerLayer(
              markers: [
                if (loc.isCurrent)
                  Marker(
                    point: LatLng(loc.lat, loc.lng),
                    width: 22,
                    height: 22,
                    child: const _MyLocationDot(),
                  ),
                for (var i = 0; i < list.length; i++)
                  Marker(
                    point: LatLng(list[i].lat, list[i].lng),
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      onTap: () => _select(i, fromMarker: true),
                      child: _Pin(
                        category: list[i].category,
                        selected: i == _index,
                      ),
                    ),
                  ),
              ],
            ),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors'),
            ),
          ],
        ),
        SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CategoryTabs(
              selected: _category,
              onChanged: (c) {
                setState(() {
                  _category = c;
                  _index = 0;
                });
                if (_pages.hasClients) _pages.jumpToPage(0);
              },
            ),
          ),
        ),
        if (list.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            height: 112,
            child: PageView.builder(
              controller: _pages,
              itemCount: list.length,
              onPageChanged: _select,
              itemBuilder: (_, i) => _MapCard(place: list[i]),
            ),
          ),
      ],
    );
  }
}

class _MyLocationDot extends StatelessWidget {
  const _MyLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2F80ED),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x552F80ED), blurRadius: 10, spreadRadius: 4),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.category, required this.selected});

  final PlaceCategory category;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final size = selected ? 40.0 : 30.0;
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : AppColors.accent,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          categoryIcon(category),
          size: size * 0.5,
          color: selected ? Colors.white : AppColors.accent,
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.place});

  final PlaceView place;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openPlace(context, place),
      child: _card(),
    );
  }

  Widget _card() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          PlaceThumb(place: place, width: 88, height: 88),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  place.displayName,
                  style: AppText.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                PlaceMeta(place: place, showRating: false),
                const SizedBox(height: 6),
                if (place.oneLiner != null)
                  Text(
                    place.oneLiner!,
                    style: AppText.body.copyWith(
                      fontSize: 13,
                      color: AppColors.ink,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          SaveButton(id: place.id),
        ],
      ),
    );
  }
}
