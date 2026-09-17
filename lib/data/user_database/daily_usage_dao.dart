import 'package:sqflite/sqflite.dart';
import 'package:totoki_extract/business/user/daily_usage.dart';
import 'package:totoki_extract/features/user/analytics_models.dart';
import 'user_dao.dart';
import 'user_db_helper.dart';

class DailyUsageDao {
  final UserDatabaseHelper _database;
  DailyUsageDao(this._database);

  Future<Database> get _db => _database.database;

  Future<void> addUsageTime(int amount) async {
    if (amount <= 0) return;

    final userDao = UserDao(_database);
    final user = await userDao.getCurrentUser();
    if (user == null) return;

    final db = await _db;
    final today = DateTime.now();
    final date = '${today.day}/${today.month}/${today.year}';

    final existing = await db.query(
      'daily_user_usage',
      where: 'user_id = ? AND date = ?',
      whereArgs: [user.id, date],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final currentAmount = (existing.first['amount'] as int?) ?? 0;
      await db.update(
        'daily_user_usage',
        {'amount': currentAmount + amount},
        where: 'user_id = ? AND date = ?',
        whereArgs: [user.id, date],
      );
      return;
    }

    await db.insert('daily_user_usage', {
      'user_id': user.id,
      'date': date,
      'amount': amount,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

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

  Future<int> getCurrentStreak(String userId) async {
    final now = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.day}/${date.month}/${date.year}';
      final usage = await getDailyUsage(userId, dateStr);
      if (usage != null && usage.amount > 0) {
        streak++;
      } else if (i > 0) {
        // Allow today to be missed
        break;
      }
    }
    return streak;
  }

  Future<int> getLongestStreak(String userId) async {
    final db = await _db;
    final result = await db.query(
      'daily_user_usage',
      where: 'user_id = ? AND amount > 0',
      whereArgs: [userId],
      orderBy: 'date ASC',
    );

    if (result.isEmpty) return 0;

    int longest = 1;
    int current = 1;
    DateTime? prevDate;

    for (final row in result) {
      final dateStr = row['date'] as String;
      final parts = dateStr.split('/');
      if (parts.length != 3) continue;
      final date = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      if (prevDate != null) {
        final diff = date.difference(prevDate).inDays;
        if (diff == 1) {
          current++;
          longest = current > longest ? current : longest;
        } else {
          current = 1;
        }
      }
      prevDate = date;
    }
    return longest;
  }

  Future<Map<DateTime, int>> getYearActivity(String userId) async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);

    final startStr =
        '${startOfYear.day}/${startOfYear.month}/${startOfYear.year}';
    final endStr = '${endOfYear.day}/${endOfYear.month}/${endOfYear.year}';

    final usages = await getDailyUsageRange(userId, startStr, endStr);

    final activity = <DateTime, int>{};
    for (final usage in usages) {
      final parts = usage.date.split('/');
      if (parts.length != 3) continue;
      final date = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      activity[date] = usage.amount;
    }
    return activity;
  }

  Future<List<ActivityMonth>> getMonthlyActivity(
    String userId,
    int year,
  ) async {
    final months = <ActivityMonth>[];

    for (int month = 1; month <= 12; month++) {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0);

      final startStr =
          '${startOfMonth.day}/${startOfMonth.month}/${startOfMonth.year}';
      final endStr = '${endOfMonth.day}/${endOfMonth.month}/${endOfMonth.year}';

      final usages = await getDailyUsageRange(userId, startStr, endStr);

      int activeDays = 0;
      final dayAmounts = <int, int>{};
      for (final usage in usages) {
        if (usage.amount > 0) activeDays++;
        final parts = usage.date.split('/');
        if (parts.length == 3) {
          dayAmounts[int.parse(parts[0])] = usage.amount;
        }
      }

      months.add(
        ActivityMonth(
          year: year,
          month: month,
          activeDays: activeDays,
          dayAmounts: dayAmounts,
        ),
      );
    }
    return months;
  }
}
