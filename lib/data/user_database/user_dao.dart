import 'package:sqflite/sqflite.dart';
import 'package:totoki_extract/business/user/user.dart';
import 'user_db_helper.dart';

class UserDao {
  final UserDatabaseHelper _database;
  UserDao(this._database);

  Future<Database> get _db => _database.database;

  Future<int> insertUser(User user) async {
    final db = await _db;
    return db.insert(
      'app_user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String id) async {
    final db = await _db;
    final result = await db.query(
      'app_user',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<void> updatePhoneNumber(String id, String phoneNumber) async {
    final db = await _db;
    await db.update(
      'app_user',
      {
        'phone_number': phoneNumber,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateUser(User user) async {
    final db = await _db;
    await db.update(
      'app_user',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(String id) async {
    final db = await _db;
    await db.delete('app_user', where: 'id = ?', whereArgs: [id]);
  }
}