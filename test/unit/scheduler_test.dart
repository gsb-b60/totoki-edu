import 'package:flutter_test/flutter_test.dart';
import 'package:totoki_extract/business/flashcard/scheduler.dart';

void main() {
  group('computeSM2', () {
    group('failed review (quality < 3)', () {
      test('resets reps to 0 and sets interval to 1 day', () {
        final result = computeSM2(quality: 2, prevReps: 5, prevInterval: 21);

        expect(result.reps, 0);
        expect(result.intervalDays, 1);
      });

      test('quality 0 also resets reps', () {
        final result = computeSM2(quality: 0, prevReps: 3);

        expect(result.reps, 0);
        expect(result.intervalDays, 1);
      });

      test('still recomputes ease factor (never below floor)', () {
        final result = computeSM2(quality: 0, prevEF: 2.5);

        // quality 0 => EF = 2.5 + (0.1 - 5*0.18) = 1.7, clamped to >= 1.3
        expect(result.easeFactor, greaterThanOrEqualTo(1.3));
        expect(result.easeFactor, lessThan(2.5));
      });
    });

    group('first successful review (reps == 1)', () {
      test('interval is 1 day', () {
        final result = computeSM2(quality: 4);

        expect(result.reps, 1);
        expect(result.intervalDays, 1);
      });
    });

    group('second successful review (reps == 2)', () {
      test('interval is 6 days', () {
        final result = computeSM2(quality: 4, prevReps: 1, prevInterval: 1);

        expect(result.reps, 2);
        expect(result.intervalDays, 6);
      });
    });

    group('third successful review (reps >= 3)', () {
      test('interval = previous interval x ease factor (rounded)', () {
        final result = computeSM2(
          quality: 4,
          prevReps: 2,
          prevInterval: 6,
          prevEF: 2.5,
        );

        expect(result.reps, 3);
        // interval uses the ease factor AFTER the update; for quality 4 the
        // EF rises slightly above 2.5, so ~15-16.
        expect(result.intervalDays, inInclusiveRange(15, 16));
      });

      test('uses previous interval of 6 when prevInterval is 0 on reps 3', () {
        final result = computeSM2(
          quality: 5,
          prevReps: 2,
          prevInterval: 0,
          prevEF: 2.5,
        );

        expect(result.reps, 3);
        expect(result.intervalDays, greaterThanOrEqualTo(6));
      });

      test('interval never drops below 1 day', () {
        final result = computeSM2(
          quality: 3,
          prevReps: 2,
          prevInterval: 1,
          prevEF: 1.3,
        );

        expect(result.intervalDays, greaterThanOrEqualTo(1));
      });
    });

    group('ease factor behavior', () {
      test('clamps to minimum of 1.3', () {
        final result = computeSM2(quality: 0, prevEF: 1.3);

        expect(result.easeFactor, greaterThanOrEqualTo(1.3));
      });

      test('raises ease factor on a perfect review (quality 5)', () {
        final result = computeSM2(quality: 5, prevEF: 2.5);

        expect(result.easeFactor, greaterThan(2.5));
      });

      test('lowers ease factor on a quality 3 review', () {
        final result = computeSM2(quality: 3, prevEF: 2.5);

        expect(result.easeFactor, lessThan(2.5));
      });

      test('default ease factor stays finite', () {
        final result = computeSM2(quality: 4, prevReps: 1);

        expect(result.easeFactor, inInclusiveRange(1.3, 3.0));
      });
    });

    group('progression simulation', () {
      test('repeated success grows interval monotonically from day 1', () {
        var interval = 0;
        var reps = 0;
        var ef = 2.5;

        for (var q = 0; q < 6; q++) {
          final next = computeSM2(
            quality: 4,
            prevInterval: interval,
            prevReps: reps,
            prevEF: ef,
          );
          expect(next.intervalDays, greaterThanOrEqualTo(interval));
          interval = next.intervalDays;
          reps = next.reps;
          ef = next.easeFactor;
        }

        expect(interval, greaterThanOrEqualTo(6));
        expect(reps, 6);
      });
    });
  });
}
