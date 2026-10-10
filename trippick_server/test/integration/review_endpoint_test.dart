import 'package:test/test.dart';
import 'package:trippick_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Review endpoint', (sessionBuilder, endpoints) {
    late Place place;

    setUp(() async {
      place = await Place.db.insertRow(
        sessionBuilder.build(),
        Place(
          sourceId: 'tour:test',
          name: '테스트 해변',
          category: 'sight',
          address: '부산 해운대구',
          lat: 35.1587,
          lng: 129.1604,
        ),
      );
    });

    test('when adding reviews then count and average rating update', () async {
      await endpoints.review.add(
        sessionBuilder,
        place.id!,
        '민지',
        5,
        '바다가 정말 예뻐요',
      );
      final updated = await endpoints.review.add(
        sessionBuilder,
        place.id!,
        'Alex',
        3,
        'Crowded on weekends',
      );

      expect(updated.reviewCount, 2);
      expect(updated.ratingAvg, 4.0);
      // Below the 3-review threshold: no AI review summary yet.
      expect(updated.reviewSummaryKo, isNull);

      final list = await endpoints.review.list(sessionBuilder, place.id!);
      expect(list.map((r) => r.author), ['Alex', '민지']);
    });

    test('when author is blank then it is saved as Guest', () async {
      await endpoints.review.add(sessionBuilder, place.id!, '  ', 4, '좋은 곳이에요');
      final list = await endpoints.review.list(sessionBuilder, place.id!);
      expect(list.single.author, 'Guest');
    });

    test(
      'when review is too short or rating is out of range then it fails',
      () async {
        expect(
          () => endpoints.review.add(sessionBuilder, place.id!, 'a', 5, 'hi'),
          throwsA(anything),
        );
        expect(
          () => endpoints.review.add(
            sessionBuilder,
            place.id!,
            'a',
            6,
            '별점이 이상해요',
          ),
          throwsA(anything),
        );
        final list = await endpoints.review.list(sessionBuilder, place.id!);
        expect(list, isEmpty);
      },
    );

    test('when place does not exist then it fails', () async {
      expect(
        () => endpoints.review.add(sessionBuilder, 999999, 'a', 5, '없는 장소 리뷰'),
        throwsA(anything),
      );
    });
  });
}
