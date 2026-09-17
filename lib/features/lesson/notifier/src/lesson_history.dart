part of 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';

mixin LessonHistory {
  Future<void> saveLession(
    String userId,
    LessonType type, {
    required int accuracy,
    required int timeSpent,
  }) async {
    final dao = HistoryLessonDao(UserDatabaseHelper.instance);
    await dao.insertHistoryLesson(
      HistoryLesson(
        userId: userId,
        lessonType: type,
        accuracy: accuracy,
        timeSpent: timeSpent,
      ),
    );
  }
}