import 'package:flutter_test/flutter_test.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/business/user/card_history.dart';
import 'package:totoki_extract/business/user/daily_usage.dart';
import 'package:totoki_extract/business/user/history_lesson.dart';
import 'package:totoki_extract/business/user/lessonType.dart';
import 'package:totoki_extract/business/user/user.dart';

void main() {
  group('Flashcard', () {
    test('toMap uses expected database column names', () {
      final card = Flashcard(
        deckId: 2,
        word: 'serendipity',
        interval: 5,
        reps: 2,
        lapses: 1,
        easeFactor: 2.1,
      );

      final map = card.toMap();
      expect(map['deck_id'], 2);
      expect(map['word'], 'serendipity');
      expect(map['interval'], 5);
      expect(map['reps'], 2);
      expect(map['lapses'], 1);
      expect(map['ease_factor'], 2.1);
    });

    test('fromMap round-trips a full record with timestamps', () {
      final now = DateTime(2026, 1, 15, 10, 30);
      final card = Flashcard(
        deckId: 3,
        createdAt: now,
        word: 'resilience',
        meaning: 'capacity to recover',
        interval: 21,
        reps: 4,
        due: now.add(const Duration(days: 21)),
        lastReview: now,
        lapses: 0,
        easeFactor: 2.3,
        sound: 'res.mp3',
      );

      final restored = Flashcard.fromMap(card.toMap());

      // toMap deliberately omits the DB-generated id, so it is null here.
      expect(restored.id, isNull);
      expect(restored.deckId, card.deckId);
      expect(restored.createdAt, card.createdAt);
      expect(restored.word, card.word);
      expect(restored.interval, card.interval);
      expect(restored.reps, card.reps);
      expect(restored.due, card.due);
      expect(restored.sound, card.sound);
    });

    test('fromMap defaults interval/reps to 0 when null', () {
      final restored = Flashcard.fromMap(const {'deck_id': 1, 'word': 'x'});
      expect(restored.interval, 0);
      expect(restored.reps, 0);
    });

    test('copyWith updates only provided fields', () {
      final card = Flashcard(deckId: 1, interval: 3, reps: 1, easeFactor: 2.0);
      final copy = card.copyWith(interval: 10);

      expect(copy.interval, 10);
      expect(copy.reps, 1);
      expect(copy.easeFactor, 2.0);
    });
  });

  group('User', () {
    test('toMap/fromMap round-trip', () {
      final user = User(
        id: 'u-1',
        createdAt: DateTime(2026, 3, 1),
        name: 'Totoki',
        email: 'a@b.com',
      );

      final restored = User.fromMap(user.toMap());
      expect(restored.id, 'u-1');
      expect(restored.createdAt, user.createdAt);
      expect(restored.name, 'Totoki');
      expect(restored.email, 'a@b.com');
      expect(restored.avatarUrl, isNull);
    });

    test('fromMap parses iso-8601 dates', () {
      final user = User.fromMap(const {
        'id': 'u-2',
        'created_at': '2026-05-10T08:00:00.000',
      });
      expect(user.createdAt.year, 2026);
      expect(user.createdAt.month, 5);
    });
  });

  group('DailyUsage', () {
    test('toMap/fromMap round-trip with id', () {
      final usage = DailyUsage(
        id: 4,
        userId: 'u-1',
        date: '5/3/2026',
        amount: 30,
      );

      final restored = DailyUsage.fromMap(usage.toMap());
      expect(restored.id, 4);
      expect(restored.userId, 'u-1');
      expect(restored.date, '5/3/2026');
      expect(restored.amount, 30);
    });

    test('toMap omits id when null', () {
      final usage = DailyUsage(userId: 'u', date: '1/1/2026', amount: 5);
      expect(usage.toMap().containsKey('id'), isFalse);
    });
  });

  group('HistoryLesson', () {
    test('toMap/fromMap round-trip', () {
      final lesson = HistoryLesson(
        id: 2,
        userId: 'u-1',
        lessonType: LessonType.ielts,
        accuracy: 75,
        timeSpent: 30,
      );

      final restored = HistoryLesson.fromMap(lesson.toMap());
      expect(restored.id, 2);
      expect(restored.lessonType, LessonType.ielts);
      expect(restored.accuracy, 75);
      expect(restored.timeSpent, 30);
    });
  });

  group('CardHistory', () {
    test('toMap/fromMap round-trip success', () {
      final history = CardHistory(
        id: 3,
        userId: 'u-1',
        cardId: 10,
        success: true,
      );

      final restored = CardHistory.fromMap(history.toMap());
      expect(restored.success, isTrue);
      expect(restored.cardId, 10);
    });

    test('success false maps to 0', () {
      final history = CardHistory(
        userId: 'u-1',
        cardId: 10,
        success: false,
      );
      expect(history.toMap()['success'], 0);
    });
  });
}
