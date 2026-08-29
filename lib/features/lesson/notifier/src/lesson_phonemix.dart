part of 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';

mixin LessonPhonemix on LessonNotiBase, LessonResult {
  List<WordIPA>? listWI;
  List<String>? listIPA;
  List<String>? listWordPhone;
  int? selectedIPAIDX;
  int? selectedWordIDX;
  List<ButtonState> wordState = List.filled(4, ButtonState.normal);
  List<ButtonState> ipaState = List.filled(4, ButtonState.normal);

  List<WordIPA> getOptionListPhone() {
    List<WordIPA> list = [];
    List<Flashcard> listCard = _cards.take(4).toList();
    for (var c in listCard) {
      final currentCard = c;
      String ipaCheck = c.ipa!;
      if (!ipaCheck.contains('/')) {
        ipaCheck = "/$ipaCheck/";
      }
      list.add(WordIPA(word: currentCard.word ?? "", ipa: ipaCheck));
    }
    list.shuffle();
    return list;
  }

  List<String> getIPA() {
    if (listWI != null && listIPA == null) {
      listIPA = listWI?.map((e) => e.ipa).toList();
      listIPA?.shuffle();
    }
    return listIPA!;
  }

  List<String> getWord() {
    if (listWI != null && listWordPhone == null) {
      listWordPhone = listWI?.map((e) => e.word).toList();
      listWordPhone?.shuffle();
    }
    return listWordPhone!;
  }

  List<WordIPA> setOptionListPhone() {
    listWI ??= getOptionListPhone();
    return listWI!;
  }

  void selectWord(int index) {
    if (selectedWordIDX == index) {
      wordState[index] = ButtonState.normal;
      selectedWordIDX = null;
    } else {
      if (selectedWordIDX != null) {
        wordState[selectedWordIDX!] = ButtonState.normal;
      }
      selectedWordIDX = index;
      wordState[index] = ButtonState.selected;
    }
    notifyListeners();
    _checkMath();
  }

  void selectIPA(int index) {
    if (selectedIPAIDX == index) {
      ipaState[index] = ButtonState.normal;
      selectedIPAIDX = null;
    } else {
      if (selectedIPAIDX != null) {
        ipaState[selectedIPAIDX!] = ButtonState.normal;
      }
      selectedIPAIDX = index;
      ipaState[index] = ButtonState.selected;
    }
    notifyListeners();
    _checkMath();
  }

  void _checkMath() {
    if (selectedIPAIDX != null && selectedWordIDX != null) {
      final correctIPA = listWI!
          .firstWhere((o) => o.word == listWordPhone![selectedWordIDX!])
          .ipa;

      if (correctIPA == listIPA![selectedIPAIDX!]) {
        ipaState[selectedIPAIDX!] = ButtonState.done;
        wordState[selectedWordIDX!] = ButtonState.done;

        selectedWordIDX = null;
        selectedIPAIDX = null;

        answered = !wordState.contains(ButtonState.normal);
        if (answered) {
          haper();
        }
        notifyListeners();
      } else {
        ipaState[selectedIPAIDX!] = ButtonState.wrong;
        wordState[selectedWordIDX!] = ButtonState.wrong;
        notifyListeners();

        final currentWordIdx = selectedWordIDX!;
        final currentIpaIdx = selectedIPAIDX!;

        selectedWordIDX = null;
        selectedIPAIDX = null;

        Future.delayed(Duration(milliseconds: 300), () {
          if (wordState[currentWordIdx] == ButtonState.wrong) {
            wordState[currentWordIdx] = ButtonState.normal;
          }
          if (ipaState[currentIpaIdx] == ButtonState.wrong) {
            ipaState[currentIpaIdx] = ButtonState.normal;
          }
          notifyListeners();
        });
      }
    }
  }
}