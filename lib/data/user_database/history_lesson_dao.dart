import 'package:sqflite/sqflite.dart';
import 'package:totoki_extract/business/user/lessonType.dart';
import 'package:totoki_extract/business/user/history_lesson.dart';
import 'user_db_helper.dart';

class HistoryLessonDao {
  final UserDatabaseHelper _database;
  HistoryLessonDao(this._database);

  Future<Database> get _db => _database.database;

  Future<int> insertHistoryLesson(HistoryLesson lesson) async {
    final db = await _db;
    return db.insert(
      'history_lesson',
      lesson.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HistoryLesson>> getHistoryLessons(String userId, {LessonType? type}) async {
    final db = await _db;
    final whereArgs = <Object>[userId];
    String where = 'user_id = ?';
    if (type != null) {
      where += ' AND lesson_type = ?';
      whereArgs.add(type.value);
    }
    final result = await db.query(
      'history_lesson',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'id DESC',
    );
    return result.map(HistoryLesson.fromMap).toList(growable: false);
  }
}