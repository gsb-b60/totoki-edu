import 'package:sqflite/sqflite.dart';
import 'package:totoki_extract/business/user/card_history.dart';
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
}