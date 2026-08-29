import 'package:sqflite/sqflite.dart';
import 'package:totoki_extract/business/user/user.dart';
import 'package:uuid/uuid.dart';
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

  Future<User?> getCurrentUser() async {
    final db = await _database.database;

    final result = await db.query('app_user', limit: 1);

    if (result.isEmpty) {
      return null;
    }

    return User.fromMap(result.first);
  }

  Future<User> createLocalUser() async {
    final db = await _database.database;

    final existing = await db.query('app_user', limit: 1);
    if (existing.isNotEmpty) {
      return User.fromMap(existing.first);
    }

    final user = User(id: const Uuid().v4(), createdAt: DateTime.now());
    await db.insert('app_user', user.toMap());

    return user;
  }

  Future<void> updatePhoneNumber(String phoneNumber) async {
    final db = await _db;
    final existing = await db.query('app_user', limit: 1);
    if (existing.isEmpty) return;
    await db.update(
      'app_user',
      {
        'phone_number': phoneNumber,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [existing.first['id']],
    );
  }

  Future<void> updateUser(User user) async {
    final db = await _db;
    final existing = await db.query('app_user', limit: 1);
    if (existing.isEmpty) return;
    await db.update(
      'app_user',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [existing.first['id']],
    );
  }

  Future<void> deleteUser() async {
    final db = await _db;
    final existing = await db.query('app_user', limit: 1);
    if (existing.isEmpty) return;
    await db.delete('app_user', where: 'id = ?', whereArgs: [existing.first['id']]);
  }

  Future<void> updateName(String name) async {
    final db = await _db;
    final existing = await db.query('app_user', limit: 1);
    if (existing.isEmpty) return;
    await db.update(
      'app_user',
      {'name': name, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [existing.first['id']],
    );
  }

  Future<void> updateEmail(String email) async {
    final db = await _db;
    final existing = await db.query('app_user', limit: 1);
    if (existing.isEmpty) return;
    await db.update(
      'app_user',
      {'email': email, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [existing.first['id']],
    );
  }

  Future<void> updateAvatar(String avatarUrl) async {
    final db = await _db;
    final existing = await db.query('app_user', limit: 1);
    if (existing.isEmpty) return;
    await db.update(
      'app_user',
      {'avatar_url': avatarUrl, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [existing.first['id']],
    );
  }
}
