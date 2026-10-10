import 'package:flutter/material.dart';

import '../l10n.dart';
import '../models/place_view.dart';
import '../screens/place_detail_screen.dart';
import '../theme.dart';

IconData categoryIcon(PlaceCategory c) => switch (c) {
  PlaceCategory.sight => Icons.landscape_outlined,
  PlaceCategory.food => Icons.restaurant_outlined,
  PlaceCategory.activity => Icons.kayaking_outlined,
};

void openPlace(BuildContext context, PlaceView place) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.dbId)),
  );
}

/// 사진. 없으면 차분한 회색 바탕에 카테고리 아이콘.
class PlaceThumb extends StatelessWidget {
  const PlaceThumb({
    super.key,
    required this.place,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final PlaceView place;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.soft,
      alignment: Alignment.center,
      child: Icon(
        categoryIcon(place.category),
        color: const Color(0xFFB0B8C1),
        size: (height < width ? height : width) * 0.3,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: place.imageUrl == null
            ? placeholder
            : Image.network(
                place.imageUrl!,
                fit: BoxFit.cover,
                // On web, load through an <img> element so photos from
                // servers without CORS headers (TourAPI) still show.
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (_, _, _) => placeholder,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : Container(color: AppColors.soft),
              ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.id, this.size = 22});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: savedIds,
      builder: (context, saved, _) {
        final on = saved.contains(id);
        return IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => toggleSaved(id),
          icon: Icon(on ? Icons.bookmark : Icons.bookmark_border, size: size),
          color: on ? AppColors.accent : AppColors.faint,
        );
      },
    );
  }
}

/// "명소 · 540m · ★4.5 (3)"
class PlaceMeta extends StatelessWidget {
  const PlaceMeta({super.key, required this.place, this.showRating = true});

  final PlaceView place;
  final bool showRating;

  @override
  Widget build(BuildContext context) {
    final parts = [place.categoryLabel, place.distanceLabel];
    return Row(
      children: [
        Flexible(
          child: Text(
            parts.join('  ·  '),
            style: AppText.small,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showRating && place.ratingAvg != null) ...[
          Text('  ·  ', style: AppText.small),
          const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFB400)),
          Text(
            ' ${place.ratingAvg!.toStringAsFixed(1)} (${place.reviewCount})',
            style: AppText.small.copyWith(color: AppColors.sub),
          ),
        ],
      ],
    );
  }
}

/// 3줄 요약 블록. 리뷰 요약이 있으면 리뷰 요약, 없으면 공식 정보 요약.
class SummaryBlock extends StatelessWidget {
  const SummaryBlock({super.key, required this.place, this.kind});

  final PlaceView place;

  /// null = 자동 선택, 'review' 또는 'highlight' = 강제.
  final String? kind;

  @override
  Widget build(BuildContext context) {
    final useReview =
        kind == 'review' || (kind == null && place.reviewSummary != null);
    final s = useReview ? place.reviewSummary : place.highlight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: s == null
          ? Text(t('no_summary'), style: AppText.small)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      t(useReview ? 'summary' : 'highlight'),
                      style: AppText.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.sub,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      useReview
                          ? t('summary_basis', n: place.reviewSummaryBasis)
                          : t(
                              place.source == 'osm'
                                  ? 'highlight_basis_osm'
                                  : 'highlight_basis',
                            ),
                      style: AppText.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _line(
                  t(useReview ? 'good' : 'hl_good'),
                  s.good,
                  AppColors.good,
                ),
                _line(t(useReview ? 'bad' : 'hl_bad'), s.bad, AppColors.bad),
                _line(t('tip'), s.tip, AppColors.tip),
              ],
            ),
    );
  }

  Widget _line(String label, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: lang.value == Lang.en ? 92 : 62,
            child: Text(
              label,
              style: AppText.body.copyWith(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppText.body.copyWith(fontSize: 13, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// 목록 한 줄: 이름/정보 + 오른쪽 썸네일, 아래에 3줄 요약.
class PlaceRow extends StatelessWidget {
  const PlaceRow({super.key, required this.place});

  final PlaceView place;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openPlace(context, place),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              place.displayName,
                              style: AppText.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SaveButton(id: place.id, size: 20),
                        ],
                      ),
                      PlaceMeta(place: place),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                PlaceThumb(place: place, width: 76, height: 76),
              ],
            ),
            const SizedBox(height: 12),
            SummaryBlock(place: place),
          ],
        ),
      ),
    );
  }
}

/// 가로 스크롤용 큰 카드.
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({super.key, required this.place});

  final PlaceView place;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openPlace(context, place),
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                PlaceThumb(place: place, width: 180, height: 132, radius: 10),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      place.categoryLabel,
                      style: AppText.caption.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              place.displayName,
              style: AppText.name.copyWith(fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            if (place.oneLiner != null)
              Text(
                place.oneLiner!,
                style: AppText.small,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
