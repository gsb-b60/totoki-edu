import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserDatabaseHelper {
  static final UserDatabaseHelper instance =
      UserDatabaseHelper._privateConstructor();
  UserDatabaseHelper._privateConstructor();

  static Future<Database>? _databaseFuture;

  Future<Database> get database {
    return _databaseFuture ??= _initDataBase();
  }

  Future<Database> _initDataBase() async {
    try {
      final dbPath = join(await getDatabasesPath(), 'user.db');
      final db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpdate,
        onConfigure: (db) async {
          await db.execute('pragma foreign_keys = ON');
        },
      );
      return db;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _onUpdate(Database db, int oldVersion, int newVersion) async {}
  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute('''
    CREATE TABLE app_user (
      id TEXT PRIMARY KEY,
      name text,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      avatar_url TEXT,
      email TEXT,
      phone_number TEXT,
      updated_at TEXT
    )
  ''');

      await txn.execute('''
    CREATE TABLE history_lesson (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      lesson_type INTEGER NOT NULL CHECK (lesson_type IN (0, 1, 2, 3)),
      accuracy INTEGER,
      time_spent INTEGER,
      FOREIGN KEY (user_id) REFERENCES app_user(id)
    )
  ''');

      await txn.execute('''
    CREATE TABLE card_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      card_id INTEGER NOT NULL,
      success INTEGER NOT NULL CHECK (success IN (0, 1)),
      FOREIGN KEY (user_id) REFERENCES app_user(id)
    )
  ''');

      await txn.execute('''
    CREATE TABLE daily_user_usage (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      date TEXT NOT NULL,
      amount INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES app_user(id),
      UNIQUE (user_id, date)
    )
  ''');
    });
  }
}
