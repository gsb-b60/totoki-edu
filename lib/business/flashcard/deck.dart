import 'package:flutter/widgets.dart';
import 'package:totoki_extract/data/database_helper.dart';

class Deck {
  final int? id;
  final String name;
  final String? description;
  DateTime? createdAt;
  DateTime? updatedAt;
  final String? media;

  Deck({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.media,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'media': media,
    };
  }

  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
      media: map["media"] as String?,
    );
  }

 static String extractCardName(String fullName) {
  final regex = RegExp(r'::(.+)$');
  final match = regex.firstMatch(fullName);
  return match?.group(1) ?? fullName;
}

  Future<int> getDueCount() async {
    if (id == null) return 0;
    return await DatabaseHelper.instance.getDueCardsCountForDeck(id!);
  }

  Future<int> getLearnedCount() async {
    if (id == null) return 0;
    return await DatabaseHelper.instance.getLearnedCardsCountForDeck(id!);
  }

  Future<int> getMasterCount() async {
    if (id == null) return 0;
    return await DatabaseHelper.instance.getMasterCardsCountForDeck(id!);
  }
}

class Deckmodel with ChangeNotifier {
  static final _dbhelper = DatabaseHelper.instance;

  final List<Deck> _decks = [];
  List<Deck> get deck => _decks;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  bool get hasError => _error != null;
  String? get error => _error;

  Future<void> fetchDecks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _dbhelper.getDecks();
      _decks.clear();
      _decks.addAll(data);
      _decks.sort((a, b) =>
          Deck.extractCardName(a.name).compareTo(Deck.extractCardName(b.name)));
    } catch (e) {
      _error = 'Failed to load decks: ${e.toString()}';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> insertDeck(String name, {String? description}) async {
    _isLoading = true;
    notifyListeners();
    Deck addDeck = Deck(name: name, description: description);
    int newId = await _dbhelper.insertDeck(addDeck);
    Deck newDeck = Deck(id: newId, name: name, description: description);
    _decks.add(newDeck);
    await fetchDecks();
  }

  Future<void> deleteDeck(int id) async {
    await _dbhelper.deleteDeck(id);
    _decks.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  Future<void> filePicker() async {
    bool haveDB = await _dbhelper.hasData();
    if (haveDB) {
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final filePath = await _dbhelper.pickAndCopyFile();
      if (filePath == null || filePath.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final ankiDbPath = await _dbhelper.unzipApkgFile(filePath);
      if (ankiDbPath == null || ankiDbPath.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      await _dbhelper.importDataFromAnki(ankiDbPath);
      await fetchDecks();
    } catch (e) {
      debugPrint("Error in filePicker: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getMediaFile(int id) async {
    final String? result = await _dbhelper.getMediaFile(id);
    return result;
  }

  Future<bool> hadDB() async {
    hadDBsync = await _dbhelper.hasData();
    return hadDBsync;
  }
  bool hadDBsync = false;
}
