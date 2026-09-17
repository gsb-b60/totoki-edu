import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:totoki_extract/data/card_database/database_helper.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/ui/screens/studymode/echospell/echospell_ui.dart';

class MeanfuseNoti extends ChangeNotifier {
  static final _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _cards = [];
  String media = "";
  bool isLoading = false;

  int currentCardIdx = 0;

  String? ipa;
  List<String>? trueList;
  List<String>? list;
  List<String>? listWord;
  List<ButtonState>? listState;
  int currentIndex = 0;
  bool answered = false;
  double get value => (_cards.isEmpty) ? 0 : currentCardIdx / _cards.length;
  String get mean => _cards[currentCardIdx].meaning ?? "";
  bool done = false;

  Future<void> getFlashcardList(int deckId) async {
    isLoading = true;
    notifyListeners();
    if (deckId == 0) {
      final data = await _dbhelper.getCardLimit(10);
      _cards.clear();
      _cards.addAll(data);
      media = (await _dbhelper.getMediaFile(_cards[0].deckId)) ?? "";
    } else {
      final data = await _dbhelper.getCardForDeck(deckId);
      media = (await _dbhelper.getMediaFile(deckId)) ?? "";
      _cards.clear();
      _cards.addAll(data);
    }

    _cards = _cards
        .where((c) => c.sound != null && !(c.word?.contains(" ") ?? true))
        .toList();
    isLoading = false;
    notifyListeners();
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

  void checkAnswer(String letter, int index) {
    if (letter == trueList![currentIndex]) {
      listState![index] = ButtonState.done;
      listWord![currentIndex] = trueList![currentIndex];
      notifyListeners();
      currentIndex++;
    } else {
      listState![index] = ButtonState.wrong;
      notifyListeners();
      Future.delayed(Duration(milliseconds: 100), () {
        listState![index] = ButtonState.normal;
        notifyListeners();
      });
    }
    if (currentIndex == list!.length) {
      answered = true;
      notifyListeners();
    }
  }

  Future<void> setNext() async {
    if (currentCardIdx >= _cards.length - 1) return;
    ipa = null;
    trueList = null;
    listWord = null;
    list = null;
    listState = null;
    currentIndex = 0;
    answered = false;
    currentCardIdx++;
    media = (await _dbhelper.getMediaFile(_cards[currentCardIdx].deckId)) ?? "";
    notifyListeners();
  }

  List<String> setupList() {
    if (list == null) {
      list = _cards[currentCardIdx].word?.split("");
      trueList = _cards[currentCardIdx].word!.split("");

      if (list!.length > 1) {
        do {
          list!.shuffle();
        } while (listEquals(list, trueList));
      }
    }
    return list!;
  }

  List<String> setupListWord() {
    listWord ??= List.filled(list!.length, "_");
    return listWord!;
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

  List<ButtonState> getListState() {
    listState ??= List.generate(list!.length, (_) => ButtonState.normal);
    return listState!;
  }
}
