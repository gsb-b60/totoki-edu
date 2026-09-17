import 'package:sqflite/sqflite.dart';
import 'package:totoki_extract/business/user/card_history.dart';
import 'package:totoki_extract/features/user/analytics_models.dart';
import 'user_db_helper.dart';

class CardHistoryDao {
  final UserDatabaseHelper _database;
  CardHistoryDao(this._database);

  Future<Database> get _db => _database.database;

  Future<int> insertCardHistory(CardHistory history) async {
    final db = await _db;
    return db.insert(
      'card_history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CardHistory>> getCardHistory(String userId, {int? cardId}) async {
    final db = await _db;
    final whereArgs = <Object>[userId];
    String where = 'user_id = ?';
    if (cardId != null) {
      where += ' AND card_id = ?';
      whereArgs.add(cardId);
    }
    final result = await db.query(
      'card_history',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'id DESC',
    );
    return result.map(CardHistory.fromMap).toList(growable: false);
  }

  Future<CardReviewStats> getReviewStats(String userId, {int days = 30}) async {
    final db = await _db;
    final where = 'user_id = ?';
    final whereArgs = [userId];
    final result = await db.query(
      'card_history',
      where: where,
      whereArgs: whereArgs,
    );

    if (result.isEmpty) {
      return CardReviewStats(
        successRate: 0.0,
        trend: 0.0,
        dailyRates: List.filled(7, 0.0),
      );
    }

    // Group by day (mock implementation)
    final dailyMap = <int, _DayStats>{}; // day -> DayStats
    for (final row in result) {
      // Using id as a proxy for date (in production, add created_at column)
      final day = (row['id'] as int) % days;
      final success = (row['success'] as int) == 1 ? 1 : 0;
      if (!dailyMap.containsKey(day)) {
        dailyMap[day] = _DayStats();
      }
      if (success == 1) {
        dailyMap[day]!.success++;
      }
      dailyMap[day]!.total++;
    }

    // Calculate daily rates
    final dailyRates = <double>[];
    for (int i = 0; i < days; i++) {
      if (dailyMap.containsKey(i) && dailyMap[i]!.total > 0) {
        dailyRates.add((dailyMap[i]!.success / dailyMap[i]!.total) * 100);
      } else {
        dailyRates.add(0.0);
      }
    }

    // Overall success rate
    final totalReviews = result.length;
    final successfulReviews = result.where((r) => (r['success'] as int) == 1).length;
    final successRate = totalReviews > 0 ? (successfulReviews / totalReviews) * 100 : 0.0;

    // Trend: compare last 7 days vs previous 7 days
    double trend = 0.0;
    if (dailyRates.length >= 14) {
      final recent = dailyRates.sublist(dailyRates.length - 7);
      final previous = dailyRates.sublist(dailyRates.length - 14, dailyRates.length - 7);
      final recentAvg = recent.reduce((a, b) => a + b) / 7;
      final previousAvg = previous.reduce((a, b) => a + b) / 7;
      if (previousAvg > 0) {
        trend = ((recentAvg - previousAvg) / previousAvg) * 100;
      }
    }

    return CardReviewStats(
      successRate: successRate,
      trend: trend,
      dailyRates: dailyRates,
    );
  }

  Future<List<LeechCard>> getLeechCards(String userId, int limit) async {
    final db = await _db;
    final where = 'user_id = ? AND success = 0';
    final whereArgs = [userId];
    final result = await db.query(
      'card_history',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'id DESC',
    );

    // Count failures per card
    final failCounts = <int, int>{};
    for (final row in result) {
      final cardId = row['card_id'] as int;
      failCounts[cardId] = (failCounts[cardId] ?? 0) + 1;
    }

    // Sort by fail count descending and take top limit
    final sorted = failCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((e) => LeechCard(
      cardId: e.key,
      word: 'Card ${e.key}', // In production, join with card table
      failCount: e.value,
      easeFactor: 1.3, // Mock value
    )).toList(growable: false);
  }

  Future<List<CardHistory>> getCardHistoryByDateRange(String userId, DateTime start, DateTime end) async {
    final db = await _db;
    final where = 'user_id = ?';
    final whereArgs = [userId];
    final result = await db.query(
      'card_history',
      where: where,
      whereArgs: whereArgs,
    );
    return result.map(CardHistory.fromMap).toList(growable: false);
  }
}

class _DayStats {
  int success = 0;
  int total = 0;
}