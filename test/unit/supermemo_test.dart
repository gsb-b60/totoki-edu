import 'package:flutter_test/flutter_test.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/business/flashcard/supermemo.dart';

Flashcard _card({
  int? interval = 0,
  int? reps = 0,
  int? lapses = 0,
  double? easeFactor = 2.0,
}) {
  return Flashcard(
    id: 1,
    deckId: 1,
    word: 'hello',
    interval: interval,
    reps: reps,
    lapses: lapses,
    easeFactor: easeFactor,
    due: DateTime.now(),
  );
}

void main() {
  group('updateCardReview', () {
    test('feed 1 (forgot) marks a lapse and resets reps', () {
      final card = updateCardReview(
        _card(interval: 21, reps: 5, lapses: 0),
        1,
      );

      expect(card.reps, 0);
      expect(card.lapses, 1);
      // interval is clamped to [1,2] after halving then clamp
      expect(card.interval, inInclusiveRange(1, 2));
      expect(card.due, isNotNull);
      expect(card.due!.isAfter(DateTime.now()), isTrue);
    });

    test('feed 2 (hard) also lapses and resets reps', () {
      final card = updateCardReview(
        _card(interval: 10, reps: 3, lapses: 2),
        2,
      );

      expect(card.reps, 0);
      expect(card.lapses, 3);
      expect(card.interval, inInclusiveRange(1, 2));
    });

    test('feed 3 increments reps and grows interval', () {
      final card = updateCardReview(_card(interval: 2, reps: 1), 3);

      expect(card.reps, 2);
      expect(card.lapses, 0);
      expect(card.interval, greaterThan(0));
    });

    test('feed 5 (very easy) builds a significant interval', () {
      final card = updateCardReview(_card(interval: 6, reps: 2), 5);

      expect(card.reps, 3);
      expect(card.interval, greaterThan(6));
    });

    test('ease factor stays within [1.3, 2.3] for any feed', () {
      for (var feed = 1; feed <= 5; feed++) {
        final card = updateCardReview(_card(easeFactor: 1.5), feed);
        expect(
          card.easeFactor,
          inInclusiveRange(1.3, 2.3),
          reason: 'feed $feed should keep EF bounded',
        );
      }
    });

    test('first review defaults interval from zero to at least 1', () {
      final card = updateCardReview(_card(interval: 0, reps: 0), 3);

      expect(card.interval, greaterThanOrEqualTo(1));
      expect(card.reps, 1);
    });

    test('returns a new card copy and does not mutate input', () {
      final original = _card(interval: 5, reps: 2, lapses: 1);
      final updated = updateCardReview(original, 4);

      expect(identical(updated, original), isFalse);
      expect(original.reps, 2);
      expect(original.lapses, 1);
    });

    test('due time is always in the future after a review', () {
      for (var feed = 1; feed <= 5; feed++) {
        final card = updateCardReview(_card(), feed);
        expect(card.due!.isAfter(DateTime.now()), isTrue,
            reason: 'feed $feed should schedule a future due date');
      }
    });
  });
}
