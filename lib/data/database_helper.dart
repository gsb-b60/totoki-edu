import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart' as archive;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:totoki_extract/business/flashcard/Deck.dart';
import 'package:totoki_extract/business/flashcard/Flashcard.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:totoki_extract/data/flashCard_Mapper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = p.join(await getDatabasesPath(), 'flashcards.db');
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
    await _reconcileSchema(db);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE decks (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        created_at INTEGER,
        updated_at INTEGER,
        media TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY,
        created_at INTEGER,
        updated_at INTEGER,
        deck_id INTEGER,
        word TEXT,
        meaning TEXT,
        img TEXT,
        synonyms TEXT,
        sound TEXT,
        defSound TEXT,
        usageSound TEXT,
        example TEXT,
        ipa TEXT,
        complexity INTEGER DEFAULT 1,
        interval INTEGER DEFAULT 0,
        reps INTEGER DEFAULT 0,
        due INTEGER,
        last_review INTEGER,
        lapses INTEGER DEFAULT 0,
        ease_factor REAL DEFAULT 2.5,
        FOREIGN KEY (deck_id) REFERENCES decks (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _reconcileSchema(Database db) async {
    final existing = <String>{};
    for (final row in await db.rawQuery('PRAGMA table_info(cards)')) {
      final name = row['name'] as String?;
      if (name != null) existing.add(name);
    }

    final expected = <String, String>{
      'complexity': 'ALTER TABLE cards ADD COLUMN complexity INTEGER DEFAULT 1',
      'synonyms': 'ALTER TABLE cards ADD COLUMN synonyms TEXT',
      'defSound': 'ALTER TABLE cards ADD COLUMN defSound TEXT',
      'usageSound': 'ALTER TABLE cards ADD COLUMN usageSound TEXT',
      'last_review': 'ALTER TABLE cards ADD COLUMN last_review INTEGER',
      'lapses': 'ALTER TABLE cards ADD COLUMN lapses INTEGER DEFAULT 0',
      'ease_factor':
          'ALTER TABLE cards ADD COLUMN ease_factor REAL DEFAULT 2.5',
    };

    for (final entry in expected.entries) {
      if (!existing.contains(entry.key)) {
        try {
          await db.execute(entry.value);
        } catch (e) {
          debugPrint('Schema reconciliation skipped ${entry.key}: $e');
        }
      }
    }
  }

  Future<int> insertDeck(Deck deck) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final row = deck.toMap();
    row['created_at'] ??= now;
    row['updated_at'] ??= now;
    return db.insert(
      'decks',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Deck>> getDecks() async {
    final db = await database;
    final maps = await db.query('decks', orderBy: 'updated_at DESC, id DESC');
    return maps.map(Deck.fromMap).toList(growable: false);
  }

  Future<void> deleteDeck(int id) async {
    final db = await database;
    await db.delete('decks', where: 'id=?', whereArgs: [id]);
  }

  Future<List<Flashcard>> getCardForDeck(int deckId) async {
    final db = await database;
    final maps = await db.query(
      'cards',
      where: 'deck_id=?',
      whereArgs: [deckId],
      orderBy: 'due ASC, id ASC',
    );
    return maps.map(Flashcard.fromMap).toList(growable: false);
  }

  Future<List<Flashcard>> getAllCard() async {
    final db = await database;
    final maps = await db.query('cards');
    return maps.map(Flashcard.fromMap).toList(growable: false);
  }

  Future<List<Flashcard>> getCardLimit(int limit) async {
    final db = await database;
    final maps = await db.rawQuery(
      '''
      SELECT *
      FROM cards
      WHERE sound IS NOT NULL
        AND word IS NOT NULL
        AND word NOT LIKE '% %'
        AND ipa IS NOT NULL
        AND img IS NOT NULL
        AND meaning IS NOT NULL
      LIMIT ?
    ''',
      [limit],
    );
    return maps.map(Flashcard.fromMap).toList(growable: false);
  }

  Future<List<Flashcard>> getDueCardLimit(int limit) async {
    final db = await database;
    final maps = await db.rawQuery(
      '''
      SELECT *
      FROM cards
      WHERE sound IS NOT NULL
        AND word IS NOT NULL
        AND word NOT LIKE '% %'
        AND ipa IS NOT NULL
        AND img IS NOT NULL
        AND meaning IS NOT NULL
        AND (due IS NULL OR due <= ?)
      ORDER BY due ASC
      LIMIT ?
    ''',
      [DateTime.now().millisecondsSinceEpoch, limit],
    );
    return maps.map(Flashcard.fromMap).toList(growable: false);
  }

  Future<List<Flashcard>> getDueCards() async {
    final db = await database;
    final maps = await db.query(
      'cards',
      where: 'due IS NULL OR due <= ?',
      whereArgs: [DateTime.now().millisecondsSinceEpoch],
      orderBy: 'due ASC',
    );
    return maps.map(Flashcard.fromMap).toList(growable: false);
  }

  Future<List<Flashcard>> getCardByLevels(int level) async {
    final db = await database;
    final maps = await db.query(
      'cards',
      where: 'complexity=?',
      whereArgs: [level],
    );
    return maps.map(Flashcard.fromMap).toList(growable: false);
  }

  Future<List<Flashcard>> getCardByLevel(int level, int limit) async {
    final db = await database;
    final maps = await db.rawQuery(
      '''
      SELECT *
      FROM cards
      WHERE sound IS NOT NULL
        AND word IS NOT NULL
        AND word NOT LIKE '% %'
        AND ipa IS NOT NULL
        AND img IS NOT NULL
        AND meaning IS NOT NULL
        AND (due IS NULL OR due <= ?)
        AND complexity = ?
      LIMIT ?
    ''',
      [DateTime.now().millisecondsSinceEpoch, level, limit],
    );
    return maps.map(Flashcard.fromMap).toList(growable: false);
  }

  Future<int> insertCard(Flashcard card) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final row = card.toMap();
    row['created_at'] ??= now;
    row['updated_at'] ??= now;
    row['interval'] ??= 0;
    row['reps'] ??= 0;
    row['due'] ??= now;
    row['lapses'] ??= 0;
    row['ease_factor'] ??= 2.5;
    return db.insert(
      'cards',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCard(Flashcard card) async {
    if (card.id == null) return;
    final db = await database;
    await db.update(
      'cards',
      {
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'interval': card.interval,
        'reps': card.reps,
        'due': card.due?.millisecondsSinceEpoch,
        'last_review': card.lastReview?.millisecondsSinceEpoch,
        'lapses': card.lapses,
        'ease_factor': card.easeFactor,
      },
      where: 'id=?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(int cardId) async {
    final db = await database;
    await db.delete('cards', where: 'id=?', whereArgs: [cardId]);
  }

  Future<String?> pickApkgFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apkg'],
    );
    return result?.files.single.path;
  }

  Future<String?> pickAndCopyFile() async {
    final pickedFile = await pickApkgFile();
    if (pickedFile == null || pickedFile.isEmpty) return null;
    final savedPath = p.join(PathService.appDocPath, p.basename(pickedFile));
    await File(pickedFile).copy(savedPath);
    return savedPath;
  }

  Future<String?> unzipApkgFile(String apkgFilePath) async {
    if (apkgFilePath.isEmpty) return null;
    final file = File(apkgFilePath);
    final bytes = await file.readAsBytes();
    final zipArchive = archive.ZipDecoder().decodeBytes(bytes);
    final outputDir = await createUnZipFolder();

    try {
      await ZipFile.extractToDirectory(
        zipFile: file,
        destinationDir: outputDir,
        onExtracting: (zipEntry, progress) => ZipFileOperation.includeItem,
      );
    } catch (e) {
      debugPrint('APKG extract failed: $e');
    }

    final tempDir = await getTemporaryDirectory();
    for (final file in zipArchive) {
      if (file.name == 'collection.anki21' || file.name == 'collection.anki2') {
        final dbPath = p.join(tempDir.path, file.name);
        await File(dbPath).writeAsBytes(file.content as List<int>, flush: true);
        return dbPath;
      }
    }
    return null;
  }

  Future<Directory> createUnZipFolder() async {
    final outputDir = Directory(p.join(PathService.ankiPath, 'unzipAnki'));
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }
    return outputDir;
  }

  Future<Directory> CreateUnZipFolder() => createUnZipFolder();

  Future<Directory> createDeckFolder() async {
    final folderName = DateTime.now().millisecondsSinceEpoch.toString();
    final outputDir = Directory(PathService.getDeckMediaPath(folderName));
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }
    return outputDir;
  }

  Future<Directory> CreateDeckFolder() => createDeckFolder();

  Future<void> importDataFromAnki(String ankiDbPath) async {
    final ankiDb = await openDatabase(ankiDbPath, readOnly: true);
    final jsonDeck = await ankiDb.rawQuery('SELECT decks FROM col LIMIT 1');
    if (jsonDeck.isEmpty) {
      await ankiDb.close();
      return;
    }

    final deckMap =
        jsonDecode(jsonDeck.first['decks'] as String) as Map<String, dynamic>;
    final folderName = await MoveMediaFile();

    for (final deck in deckMap.entries) {
      for (final deck in deckMap.entries) {
        final deckId = int.tryParse(deck.key);

        if (deckId == null || deckId == 1) continue;

        final deckName = deck.value['name']?.toString() ?? 'Imported Deck';

        final cards = await getCardsForDeck(ankiDb, deckId);

        if (cards.isEmpty) continue;

        final myDeckId = await insertDeck(
          Deck(name: deckName, media: folderName),
        );

        for (final row in cards) {
          final newCard = mapRowToFlashcard(row, myDeckId);

          if (newCard != null) {
            await insertCard(newCard);
          }
        }
      }
    }
    await ankiDb.close();
  }

  Future<List<Map<String, Object?>>> getCardsForDeck(
    Database ankiDb,
    int ankiDeckId,
  ) async {
    return await ankiDb.rawQuery(
      '''
    SELECT DISTINCT
      n.id AS note_id,
      c.did AS deck_id,
      n.flds,
      n.mid
    FROM notes AS n
    JOIN cards AS c ON n.id = c.nid
    WHERE c.did = ?
  ''',
      [ankiDeckId],
    );
  }

  Future<String> MoveMediaFile() async {
    final unzipDir = await createUnZipFolder();
    final mediaFile = File(p.join(unzipDir.path, 'media'));
    if (!mediaFile.existsSync()) {
      throw Exception('Missing APKG media manifest');
    }

    final mediaMapRaw =
        jsonDecode(await mediaFile.readAsString()) as Map<String, dynamic>;
    final deckDir = await createDeckFolder();

    for (final entry in mediaMapRaw.entries) {
      final oldFile = File(p.join(unzipDir.path, entry.key));
      if (oldFile.existsSync()) {
        final newFile = File(p.join(deckDir.path, entry.value.toString()));
        await oldFile.copy(newFile.path);
      }
    }

    try {
      await unzipDir.delete(recursive: true);
    } catch (e) {
      debugPrint('Could not clean APKG temp folder: $e');
    }
    return p.basename(deckDir.path);
  }

  Future<String?> getMediaFile(int deckID) async {
    final db = await database;
    final result = await db.query(
      'decks',
      columns: ['media'],
      where: 'id=?',
      whereArgs: [deckID],
      limit: 1,
    );
    return result.isEmpty ? null : result.first['media'] as String?;
  }

  Future<void> importFromAssetApkg(String assetPath) async {
    final tmpDir = await getTemporaryDirectory();
    final outPath = p.join(tmpDir.path, 'demo.apkg');
    final data = await rootBundle.load(assetPath);
    await File(outPath).writeAsBytes(data.buffer.asUint8List(), flush: true);
    final dbPath = await unzipApkgFile(outPath);
    if (dbPath != null) {
      await importDataFromAnki(dbPath);
    }
  }

  Future<List<Map<String, Object?>>> getCardsTableInfo() async {
    final db = await database;
    return List<Map<String, Object?>>.from(
      await db.rawQuery('PRAGMA table_info(cards)'),
    );
  }

  Future<void> deleteLearningCardDatabase() async {
    final dbPath = p.join(await getDatabasesPath(), 'flashcards.db');
    await deleteDatabase(dbPath);
    _database = null;
  }
}
