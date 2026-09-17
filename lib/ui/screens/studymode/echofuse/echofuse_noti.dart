import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/data/card_database/database_helper.dart';

class EchoFuseNoti extends ChangeNotifier {
  List<Flashcard> _cards = [];
  String media = "";
  bool isLoading = false;
  int currentCardIdx = 0;
  double get value => (_cards.isEmpty) ? 0 : currentCardIdx / _cards.length;
  bool done = false;
  bool right = true;

  List<String>? options;
  List<bool>? states;

  int? selectedIndex;
  bool get checkable => selectedIndex != null;
  String get answer => _cards[currentCardIdx].word!;
  String? ipa;
  bool answered = false;

  Future<void> getFlashcardList(int deckId) async {
    isLoading = true;
    notifyListeners();
    if (deckId == 0) {
      final data = await DatabaseHelper.instance.getCardLimit(10);
      _cards.clear();
      _cards.addAll(data);
    } else {
      final data = await DatabaseHelper.instance.getCardForDeck(deckId);
      _cards.clear();
      _cards.addAll(data);
      _cards = _cards
          .where(
            (c) =>
                c.word != null &&
                c.meaning != null &&
                !(c.word?.contains(" ") ?? true),
          )
          .toList();
    }
    media = (await DatabaseHelper.instance.getMediaFile(_cards[0].deckId))!;
    isLoading = false;
    notifyListeners();
  }

  Future<void> setNext() async {
    if (currentCardIdx < _cards.length - 1) {
      ipa = null;
      currentCardIdx++;
      options = null;
      answered = false;
      selectedIndex = null;
      media = (await DatabaseHelper.instance.getMediaFile(
        _cards[currentCardIdx].deckId,
      ))!;
      notifyListeners();
      right = true;
      notifyListeners();
    }
  }

  String setIPA() {
    if (ipa == null) {
      ipa = _cards[currentCardIdx].ipa!;
      if (!ipa!.contains('/')) {
        ipa = "/${ipa!}/";
      }
    }
    return ipa!;
  }

  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playSound() async {
    if (media != "") {
      try {
        await audioPlayer.play(
          DeviceFileSource(
            PathService.getFilePath(media, _cards[currentCardIdx].sound ?? ""),
          ),
        );
      } catch (e) {
        debugPrint('$e');
      }
    }
  }

  List<String> getOptions() {
    if (options == null) {
      final answer = _cards[currentCardIdx].word!;

      final otherCards = _cards.where((c) => c.word != answer).toList()
        ..shuffle();

      options = [answer];
      options?.addAll(otherCards.take(3 - 1).map((c) => c.word!));

      options?.shuffle();
      states = List.generate(options!.length, (_) => false);
    }
    return options!;
  }

  List<bool> getOptionState() {
    states ??= List<bool>.filled(getOptions().length, false);
    return states!;
  }

  void checkAnswer(int selectedIndex) {
    if (options?[selectedIndex] == _cards[currentCardIdx].word) {
      answered = true;
      notifyListeners();
    } else {
      answered = true;
      right = false;
      notifyListeners();
    }
  }

  void nextCard() {
    if (currentCardIdx < _cards.length - 1) {
      currentCardIdx++;
      options = null;
      answered = false;
      selectedIndex = null;
      notifyListeners();
      right = true;
      notifyListeners();
    }
  }

  void selectOption(int index) {
    if (selectedIndex == null) {
      selectedIndex = index;
      states?[index] = true;
    } else {
      states?[selectedIndex!] = false;
      selectedIndex = index;
      states?[index] = true;
    }

    notifyListeners();
  }
}
