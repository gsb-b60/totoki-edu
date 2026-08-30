import 'package:flutter_test/flutter_test.dart';
import 'package:totoki_extract/business/user/card_history.dart';
import 'package:totoki_extract/business/user/history_lesson.dart';
import 'package:totoki_extract/business/user/lessonType.dart';

void main() {
  group('LessonType', () {
    test('fromValue maps dailyLearn to 0 and ielts to 1', () {
      expect(LessonType.dailyLearn.value, 0);
      expect(LessonType.ielts.value, 1);
      expect(LessonType.fromValue(0), LessonType.dailyLearn);
      expect(LessonType.fromValue(1), LessonType.ielts);
    });

    test('toString returns display labels', () {
      expect(LessonType.dailyLearn.toString(), 'Daily Learn');
      expect(LessonType.ielts.toString(), 'IELTS');
    });
  });

  group('HistoryLesson', () {
    const userId = 'user-1';

    test('toMap uses column names expected by the database', () {
      final lesson = HistoryLesson(
        id: 7,
        userId: userId,
        lessonType: LessonType.dailyLearn,
        accuracy: 80,
        timeSpent: 120,
      );

      final map = lesson.toMap();

      expect(map['id'], 7);
      expect(map['user_id'], userId);
      expect(map['lesson_type'], 0);
      expect(map['accuracy'], 80);
      expect(map['time_spent'], 120);
    });

    test('toMap omits id when null', () {
      final lesson = HistoryLesson(
        userId: userId,
        lessonType: LessonType.ielts,
      );

      final map = lesson.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map['lesson_type'], 1);
      expect(map['accuracy'], isNull);
      expect(map['time_spent'], isNull);
    });

    test('fromMap round-trips a full record', () {
      final lesson = HistoryLesson(
        id: 3,
        userId: userId,
        lessonType: LessonType.ielts,
        accuracy: 70,
        timeSpent: 45,
      );

      final restored = HistoryLesson.fromMap(lesson.toMap());

      expect(restored.id, lesson.id);
      expect(restored.userId, lesson.userId);
      expect(restored.lessonType, lesson.lessonType);
      expect(restored.accuracy, lesson.accuracy);
      expect(restored.timeSpent, lesson.timeSpent);
    });

    test('fromMap handles null accuracy and timeSpent', () {
      final lesson = HistoryLesson(
        userId: userId,
        lessonType: LessonType.dailyLearn,
      );

      final restored = HistoryLesson.fromMap(lesson.toMap());

      expect(restored.accuracy, isNull);
      expect(restored.timeSpent, isNull);
    });
  });

  group('CardHistory', () {
    const userId = 'user-1';

    test('toMap stores success as 1 and 0', () {
      final success = CardHistory(
        userId: userId,
        cardId: 5,
        success: true,
      );
      final failed = CardHistory(
        userId: userId,
        cardId: 5,
        success: false,
      );

      expect(success.toMap()['success'], 1);
      expect(failed.toMap()['success'], 0);
    });

    test('fromMap round-trips success as bool', () {
      final success = CardHistory.fromMap(const {
        'id': 1,
        'user_id': userId,
        'card_id': 5,
        'success': 1,
      });
      final failed = CardHistory.fromMap(const {
        'id': 2,
        'user_id': userId,
        'card_id': 6,
        'success': 0,
      });

      expect(success.userId, userId);
      expect(success.cardId, 5);
      expect(success.success, isTrue);

      expect(failed.success, isFalse);
    });
  });
}