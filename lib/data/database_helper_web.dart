import 'package:totoki_extract/business/flashcard/Deck.dart';
import 'package:totoki_extract/business/flashcard/Flashcard.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  final List<Deck> _decks = <Deck>[];
  final Map<int, List<Flashcard>> _cards = <int, List<Flashcard>>{};
  int _nextDeckId = 1;
  int _nextCardId = 1;

  Future<int> insertDeck(Deck deck) async {
    final now = DateTime.now();
    final d = Deck(
      id: _nextDeckId++,
      name: deck.name,
      description: deck.description,
      media: deck.media,
      createdAt: deck.createdAt ?? now,
      updatedAt: deck.updatedAt ?? now,
    );
    _decks.add(d);
    return d.id!;
  }

  Future<List<Deck>> getDecks() async => List<Deck>.from(_decks);

  Future<void> deleteDeck(int id) async {
    _decks.removeWhere((d) => d.id == id);
    _cards.remove(id);
  }

  Future<List<Flashcard>> getCardForDeck(int deckId) async {
    return List<Flashcard>.from(_cards[deckId] ?? const <Flashcard>[]);
  }

  Future<List<Flashcard>> getAllCard() async {
    return _cards.values.expand((cards) => cards).toList(growable: false);
  }

  Future<List<Flashcard>> getCardLimit(int limit) async {
    return (await getAllCard()).take(limit).toList(growable: false);
  }

  Future<List<Flashcard>> getDueCardLimit(int limit) async {
    final now = DateTime.now();
    return (await getAllCard())
        .where((card) => card.due == null || !card.due!.isAfter(now))
        .take(limit)
        .toList(growable: false);
  }

  Future<List<Flashcard>> getDueCards() => getDueCardLimit(1 << 20);

  Future<List<Flashcard>> getCardByLevels(int level) async {
    return (await getAllCard())
        .where((card) => (card.complexity ?? 1) == level)
        .toList(growable: false);
  }

  Future<List<Flashcard>> getCardByLevel(int level, int limit) async {
    return (await getCardByLevels(level)).take(limit).toList(growable: false);
  }

  Future<void> updateCard(Flashcard card) async {
    final list = _cards[card.deckId];
    if (list == null) return;
    final idx = list.indexWhere((c) => c.id == card.id);
    if (idx != -1) list[idx] = card;
  }

  Future<void> deleteCard(int cardId) async {
    for (final list in _cards.values) {
      list.removeWhere((card) => card.id == cardId);
    }
  }

  Future<int> insertCard(Flashcard card) async {
    final c = Flashcard(
      id: _nextCardId++,
      deckId: card.deckId,
      createdAt: card.createdAt,
      updatedAt: card.updatedAt,
      word: card.word,
      meaning: card.meaning,
      example: card.example,
      img: card.img,
      ipa: card.ipa,
      interval: card.interval ?? 0,
      reps: card.reps ?? 0,
      due: card.due ?? DateTime.now(),
      lastReview: card.lastReview,
      lapses: card.lapses ?? 0,
      easeFactor: card.easeFactor ?? 2.5,
      sound: card.sound,
      defSound: card.defSound,
      usageSound: card.usageSound,
      complexity: card.complexity,
      synonyms: card.synonyms,
    );
    _cards.putIfAbsent(card.deckId, () => <Flashcard>[]).add(c);
    return c.id!;
  }

  Future<String?> pickApkgFile() async => null;
  Future<String?> pickAndCopyFile() async => null;
  Future<String?> unzipApkgFile(String apkgFilePath) async => null;
  Future<void> importDataFromAnki(String ankiDbPath) async {}
  Future<void> processCardForDeck(dynamic a, int b, int c) async {}
  Future<String> MoveMediaFile() async => '';
  Future<String?> getMediaFile(int deckID) async => null;
  Future<void> importFromAssetApkg(String assetPath) async {}
  Future<List<Map<String, Object?>>> getCardsTableInfo() async => const [];
  Future<void> deleteLearningCardDatabase() async {
    _decks.clear();
    _cards.clear();
  }
}
