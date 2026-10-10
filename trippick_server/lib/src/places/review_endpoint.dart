import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'place_sync.dart';

/// Accessed from the app as `client.review`.
class ReviewEndpoint extends Endpoint {
  /// Minimum number of reviews before an AI review summary is shown.
  static const minReviews = 3;

  Future<List<UserReview>> list(Session session, int placeId) {
    return UserReview.db.find(
      session,
      where: (t) => t.placeId.equals(placeId),
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  /// Saves a review, updates the rating, and refreshes the AI review summary.
  /// Returns the updated place.
  Future<Place> add(
    Session session,
    int placeId,
    String author,
    int rating,
    String text,
  ) async {
    final place = await Place.db.findById(session, placeId);
    if (place == null) throw ArgumentError('Unknown place');

    final cleanText = text.trim();
    final cleanAuthor = author.trim().isEmpty ? 'Guest' : author.trim();
    if (rating < 1 || rating > 5) throw ArgumentError('Rating must be 1-5');
    if (cleanText.length < 5 || cleanText.length > 500) {
      throw ArgumentError('Review must be 5-500 characters');
    }

    await UserReview.db.insertRow(
      session,
      UserReview(
        placeId: placeId,
        author: cleanAuthor.length > 30
            ? cleanAuthor.substring(0, 30)
            : cleanAuthor,
        rating: rating,
        text: cleanText,
      ),
    );

    final reviews = await list(session, placeId);
    final avg =
        reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    var updated = place.copyWith(reviewCount: reviews.length, ratingAvg: avg);

    final summarizer = summaryServiceFor(session);
    if (summarizer != null && reviews.length >= minReviews) {
      try {
        final s = await summarizer.summarizeReviews(place, reviews);
        if (s != null) {
          updated = updated.copyWith(
            reviewSummaryKo: s.ko,
            reviewSummaryEn: s.en,
            reviewSummaryBasis: reviews.length,
          );
        }
      } catch (e) {
        session.log('review summary failed: $e', level: LogLevel.warning);
      }
    }
    return Place.db.updateRow(session, updated);
  }
}
