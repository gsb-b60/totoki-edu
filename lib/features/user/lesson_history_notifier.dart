import 'package:flutter/material.dart';
import 'package:totoki_extract/business/user/history_lesson.dart';
import 'package:totoki_extract/business/user/lessonType.dart';
import 'package:totoki_extract/data/user_database/history_lesson_dao.dart';
import 'package:totoki_extract/data/user_database/user_db_helper.dart';

class LessonHistoryNotifier extends ChangeNotifier {
  final HistoryLessonDao lessonDao = HistoryLessonDao(
    UserDatabaseHelper.instance,
  );

  Future<int> insertHistoryLesson(HistoryLesson lesson) {
    return lessonDao.insertHistoryLesson(lesson);
  }

  Future<List<HistoryLesson>> getHistoryLessons(
    String userId, {
    LessonType? type,
  }) {
    return lessonDao.getHistoryLessons(userId, type: type);
  }
}
