import 'dart:async';

import 'package:flutter/material.dart';
import 'package:totoki_extract/data/card_database/database_helper.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechWordNoti extends ChangeNotifier {
  List<Flashcard> _cards = [];
  bool isLoading = false;

  int currentCardIdx = 0;
  bool answered = false;
  bool right = true;

  double get value => (_cards.isEmpty) ? 0 : currentCardIdx / _cards.length;
  String get word => _cards[currentCardIdx].word ?? "none";
  String get ipa {
    String i = _cards[currentCardIdx].ipa ?? "none";
    if (!i.contains('/')) {
      i = "/${i}/";
    }
    return i;
  }

  Future<void> SetNext() async {
    if (currentCardIdx >= _cards.length - 1) return;
    answered = false;
    currentCardIdx++;
    notifyListeners();
  }

  Future<void> getFlashcardList(int deck_id) async {
    isLoading = true;
    notifyListeners();
    if (deck_id == 0) {
      final data = await DatabaseHelper.instance.getCardLimit(10);
      _cards.clear();
      _cards.addAll(data);
    } else {
      final data = await DatabaseHelper.instance.getCardForDeck(deck_id);
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
    isLoading = false;
    notifyListeners();
  }

  //speech
  final SpeechToText stt = SpeechToText();

  Future<void> initSTT() async {
    bool available = await stt.initialize(
      onStatus: (status) => debugPrint('STT status: $status'),
      onError: (errorNotification) =>
          debugPrint('STT error: $errorNotification'),
    );

    if (!available) {
      debugPrint('STT not available or permission denied');
    }
  }

  String re = "";
  bool hasFinal = false; // NEW
  Timer? timeoutTimer; // NEW
  Future<void> startListening() async {
    re = "";
    hasFinal = false;

    await stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          debugPrint("user said ${result.recognizedWords}");
          re = result.recognizedWords;
          hasFinal = true;

          timeoutTimer?.cancel();
          stt.stop();
          CheckAnswer(re);
        }
      },
      localeId: "en_US",
    );

    while (!stt.isListening) {
      await Future.delayed(Duration(milliseconds: 30));
    }

    timeoutTimer = Timer(Duration(seconds: 5), () {
      if (!hasFinal) {
        stt.stop();
        CheckAnswer(re);
      }
    });
  }

  void CheckAnswer(String re) {
    re = re.toLowerCase().trim();
    var wordtrim = word.toLowerCase().trim();
    answered = true;
    if (re == wordtrim) {
      right = true;
    } else {
      right = false;
    }
    notifyListeners();
  }

  void stopListen() async {
    await stt.stop();
  }

  @override
  void dispose() {
    stt.cancel();
    super.dispose();
  }

  // void startListening() async {
  //   String re = "";
  //   await stt.listen(
  //     onResult: (result) {
  //       debugPrint("user said ${result.recognizedWords}");
  //       re = result.recognizedWords;
  //     },
  //     localeId: "en_US",
  //   );
  //   await Future.delayed(Duration(seconds: 5));
  //   await stt.stop();
  //   CheckAnswer(re);
  // }
}
