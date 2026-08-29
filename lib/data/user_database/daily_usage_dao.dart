import 'package:sqflite/sqflite.dart';
import 'package:totoki_extract/business/user/daily_usage.dart';
import 'user_db_helper.dart';

class DailyUsageDao {
  final UserDatabaseHelper _database;
  DailyUsageDao(this._database);

  Future<Database> get _db => _database.database;

  Future<int> upsertDailyUsage(DailyUsage usage) async {
    final db = await _db;
    return db.rawInsert(
      '''
      INSERT INTO daily_user_usage (user_id, date, amount)
      VALUES (?, ?, ?)
      ON CONFLICT(user_id, date) DO UPDATE SET amount = excluded.amount
      ''',
      [usage.userId, usage.date, usage.amount],
    );
  }

  Future<DailyUsage?> getDailyUsage(String userId, String date) async {
    final db = await _db;
    final result = await db.query(
      'daily_user_usage',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return DailyUsage.fromMap(result.first);
  }

  Future<List<DailyUsage>> getDailyUsageRange(
    String userId,
    String startDate,
    String endDate,
  ) async {
    final db = await _db;
    final result = await db.query(
      'daily_user_usage',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, startDate, endDate],
      orderBy: 'date ASC',
    );
    return result.map(DailyUsage.fromMap).toList(growable: false);
  }
}