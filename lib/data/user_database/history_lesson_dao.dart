import 'package:sqflite/sqflite.dart';
import 'package:totoki_extract/business/user/lessonType.dart';
import 'package:totoki_extract/business/user/history_lesson.dart';
import 'package:totoki_extract/features/user/analytics_models.dart';
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

  Future<Map<LessonType, LessonStats>> getLessonStats(String userId, {int days = 30}) async {
    final db = await _db;
    final where = 'user_id = ?';
    final whereArgs = [userId];
    final result = await db.query(
      'history_lesson',
      where: where,
      whereArgs: whereArgs,
    );
    
    final filtered = result.where((row) {
      // For now, process all rows since we don't have created_at
      return true;
    }).toList();

    final stats = <LessonType, LessonStats>{};
    for (final row in filtered) {
      final typeValue = row['lesson_type'] as int;
      final type = LessonType.fromValue(typeValue);
      if (!stats.containsKey(type)) {
        stats[type] = LessonStats(
          type: type,
          sessions: 1,
          accuracy: (row['accuracy'] as int? ?? 0).toDouble(),
          totalMinutes: row['time_spent'] as int? ?? 0,
          trend: 0.0,
        );
      } else {
        stats[type] = LessonStats(
          type: type,
          sessions: stats[type]!.sessions + 1,
          accuracy: stats[type]!.accuracy + (row['accuracy'] as int? ?? 0).toDouble(),
          totalMinutes: stats[type]!.totalMinutes + (row['time_spent'] as int? ?? 0),
          trend: 0.0,
        );
      }
    }

    return stats;
  }

  Future<List<DailyLessonAggregate>> getDailyLessonTrend(String userId, int days) async {
    final db = await _db;
    final now = DateTime.now();
    final where = 'user_id = ?';
    final whereArgs = [userId];
    final result = await db.query(
      'history_lesson',
      where: where,
      whereArgs: whereArgs,
    );

    final dailyMap = <DateTime, Map<LessonType, int>>{};
    for (final row in result) {
      final typeValue = row['lesson_type'] as int;
      final type = LessonType.fromValue(typeValue);
      final date = now.subtract(Duration(days: ((row['id'] as int) % days)));
      if (!dailyMap.containsKey(date)) {
        dailyMap[date] = {};
      }
      dailyMap[date]![type] = 
          (dailyMap[date]![type] ?? 0) + (row['time_spent'] as int? ?? 0);
    }

    return dailyMap.entries.map((e) => DailyLessonAggregate(
      date: e.key,
      minutesByType: e.value,
    )).toList(growable: false);
  }

  Future<List<HistoryLesson>> getLessonsByDateRange(String userId, DateTime start, DateTime end) async {
    final db = await _db;
    final where = 'user_id = ?';
    final whereArgs = [userId];
    final result = await db.query(
      'history_lesson',
      where: where,
      whereArgs: whereArgs,
    );
    return result.map(HistoryLesson.fromMap).toList(growable: false);
  }
}