import 'package:flutter/material.dart';
import 'package:trippick_client/trippick_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/location.dart';
import '../data/place_repository.dart';
import '../l10n.dart';
import '../models/place_view.dart';
import '../theme.dart';
import '../widgets/place_widgets.dart';

class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final int placeId;

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  List<UserReview>? _reviews;

  PlaceView get _place =>
      placesStore.value.firstWhere((p) => p.dbId == widget.placeId);

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await loadReviews(_place);
      if (mounted) setState(() => _reviews = reviews);
    } catch (e) {
      debugPrint('loadReviews failed: $e');
      if (mounted) setState(() => _reviews = []);
    }
  }

  Future<void> _writeReview() async {
    final posted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ReviewSheet(place: _place),
    );
    if (posted == true) {
      await _loadReviews();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t('review_done'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: placesStore,
      builder: (context, _, _) {
        final p = _place;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: p.imageUrl != null ? 260 : 0,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.ink,
                surfaceTintColor: Colors.white,
                // White round backgrounds keep icons readable over photos.
                leading: _RoundIcon(child: BackButton(color: AppColors.ink)),
                actions: [_RoundIcon(child: SaveButton(id: p.id))],
                flexibleSpace: p.imageUrl == null
                    ? null
                    : FlexibleSpaceBar(
                        background: PlaceThumb(
                          place: p,
                          width: double.infinity,
                          height: 300,
                          radius: 0,
                        ),
                      ),
              ),
              SliverToBoxAdapter(child: _body(p)),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: FilledButton(
                onPressed: _writeReview,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  t('write_review'),
                  style: AppText.name.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(PlaceView p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.displayName, style: AppText.title.copyWith(fontSize: 22)),
          if (lang.value == Lang.en && p.nameEn != p.name)
            Text(p.name, style: AppText.small),
          const SizedBox(height: 4),
          PlaceMeta(place: p),
          const SizedBox(height: 12),
          _iconLine(Icons.place_outlined, p.address),
          if (p.tel != null) _iconLine(Icons.call_outlined, p.tel!),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(
                inKorea(p.lat, p.lng)
                    ? 'https://map.kakao.com/link/map/'
                          '${Uri.encodeComponent(p.name)},${p.lat},${p.lng}'
                    : 'https://www.google.com/maps/search/?api=1'
                          '&query=${p.lat},${p.lng}',
              ),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.map_outlined, size: 18),
            label: Text(t(inKorea(p.lat, p.lng) ? 'open_map' : 'open_google')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              side: const BorderSide(color: AppColors.line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (p.reviewSummary != null) ...[
            SummaryBlock(place: p, kind: 'review'),
            const SizedBox(height: 10),
          ],
          if (p.highlight != null) SummaryBlock(place: p, kind: 'highlight'),
          if (p.reviewSummary == null && p.highlight == null)
            SummaryBlock(place: p),
          if (p.facts.isNotEmpty) ...[
            _sectionTitle(t('info')),
            if (lang.value == Lang.en && p.isOfficial)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(t('korean_only'), style: AppText.caption),
              ),
            for (final e in p.facts.entries) _fact(t('fact_${e.key}'), e.value),
          ],
          // TourAPI text is Korean (hidden in English mode); Wikipedia
          // text is usually English, so it is shown in both modes.
          if (p.overview != null &&
              (lang.value == Lang.ko || p.source == 'osm')) ...[
            _sectionTitle(t('about')),
            Text(
              p.overview!,
              style: AppText.body.copyWith(color: AppColors.ink, height: 1.6),
            ),
          ],
          if (p.isOfficial || p.source == 'osm') ...[
            const SizedBox(height: 12),
            Text(
              t(p.isOfficial ? 'source_tour' : 'source_osm'),
              style: AppText.caption,
            ),
          ],
          _sectionTitle('${t('reviews_title')} ${p.reviewCount}'),
          _reviewList(p),
        ],
      ),
    );
  }

  Widget _reviewList(PlaceView p) {
    final reviews = _reviews;
    if (reviews == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final need = 3 - reviews.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(t('review_empty'), style: AppText.body),
          ),
        if (need > 0)
          Text(t('review_need_more', n: need), style: AppText.small),
        for (final r in reviews)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      r.author,
                      style: AppText.body.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    for (var i = 1; i <= 5; i++)
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: i <= r.rating
                            ? const Color(0xFFFFB400)
                            : AppColors.line,
                      ),
                    const Spacer(),
                    Text(
                      '${r.createdAt.year}.${r.createdAt.month}.${r.createdAt.day}',
                      style: AppText.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  r.text,
                  style: AppText.body.copyWith(color: AppColors.ink),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _iconLine(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.faint),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: AppText.body)),
      ],
    ),
  );

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 10),
    child: Text(text, style: AppText.section),
  );

  Widget _fact(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(label, style: AppText.body.copyWith(fontSize: 13)),
        ),
        Expanded(
          child: Text(
            value,
            style: AppText.body.copyWith(fontSize: 13, color: AppColors.ink),
          ),
        ),
      ],
    ),
  );
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xE6FFFFFF),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.place});

  final PlaceView place;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  final _name = TextEditingController();
  final _text = TextEditingController();
  int _rating = 5;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_text.text.trim().length < 5) {
      setState(() => _error = t('review_too_short'));
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await addReview(
        widget.place,
        author: _name.text,
        rating: _rating,
        text: _text.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('addReview failed: $e');
      if (mounted) {
        setState(() {
          _sending = false;
          _error = t('review_failed');
        });
      }
    }
  }

  InputDecoration _input(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppText.body.copyWith(color: AppColors.faint),
    filled: true,
    fillColor: AppColors.soft,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.place.displayName, style: AppText.section),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(
                    Icons.star_rounded,
                    size: 32,
                    color: i <= _rating
                        ? const Color(0xFFFFB400)
                        : AppColors.line,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            maxLength: 30,
            decoration: _input(t('review_name')).copyWith(counterText: ''),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _text,
            maxLength: 500,
            minLines: 3,
            maxLines: 6,
            decoration: _input(t('review_text')),
          ),
          if (_error != null)
            Text(
              _error!,
              style: AppText.small.copyWith(color: AppColors.bad),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _sending ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(t('review_submit')),
          ),
        ],
      ),
    );
  }
}
