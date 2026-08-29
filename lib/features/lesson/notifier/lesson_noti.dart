import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:flutter/services.dart';
import 'package:totoki_extract/features/lesson/models/storage.dart';
import 'package:totoki_extract/features/lesson/notifier/quest_noti.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/data/database_helper.dart';
import 'package:totoki_extract/business/flashcard/supermemo.dart';
import 'package:totoki_extract/services/sound_controller.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vibration/vibration.dart';

enum ButtonState { normal, selected, done, wrong }

class LessonNoti extends ChangeNotifier {
  LessonNoti({this.soundController});

  final SoundController? soundController;

  //data
  static final _dbhelper = DatabaseHelper.instance;
  final List<Flashcard> _cards = [];
  bool isLoading = false;
  int currentCardIdx = 0;
  String media = "";
  Map<int, String> mediaMap = {};
  int currentLessIdx = 0;

  int get cardIdx => SetUpLessonList[currentLessIdx]["cIdx"];
  //data

  double get value =>
      (_cards.isEmpty) ? 0 : currentLessIdx / (SetUpLessonList.length);
  bool get checkable => selectedIndex != null;
  int? selectedIndex;
  int? currentIdx;
  int currentWordIdx = 0;
  bool answered = false;
  bool right = true;
  String get answer => _cards[cardIdx].word!;
  String get meaning => _cards[cardIdx].meaning!;
  String get ipa {
    String i = _cards[cardIdx].ipa!;
    if (!i.contains('/')) {
      i = "/$i/";
    }
    return i;
  }

  List<String>? trueList;
  List<String>? list;
  List<String>? listWord;

  //list
  List<ButtonState>? states;
  List<bool>? statesBool;
  List<String>? options;
  List<ButtonState> wordState = List.filled(4, ButtonState.normal);
  List<ButtonState> ipaState = List.filled(4, ButtonState.normal);

  //lession logic
  StudyMode? mode;
  LearnMode how = LearnMode.daily;
  List<Map<String, dynamic>> SetUpLessonList = [
    {"cIdx": 0, "mode": StudyMode.StartScreen},

    {"cIdx": 0, "mode": StudyMode.meanfuse},
    {"cIdx": 1, "mode": StudyMode.wordsnap},
    {"cIdx": 2, "mode": StudyMode.mindField},

    {"cIdx": 1, "mode": StudyMode.echoSpell},
    {"cIdx": 2, "mode": StudyMode.echofuse},
    {"cIdx": 0, "mode": StudyMode.echoMatch},

    {"cIdx": 2, "mode": StudyMode.soundAndSight},
    {"cIdx": 1, "mode": StudyMode.neuropick},
    {"cIdx": 0, "mode": StudyMode.wordpulse},

    {"cIdx": 0, "mode": StudyMode.speechword},
    {"cIdx": 1, "mode": StudyMode.speechword},
    {"cIdx": 2, "mode": StudyMode.speechword},

    {"cIdx": 1, "mode": StudyMode.synonympick},
    {"cIdx": 0, "mode": StudyMode.synonympick},
    {"cIdx": 2, "mode": StudyMode.synonymfeild},

    {"cIdx": 4, "mode": StudyMode.phonemix},

    {"cIdx": 4, "mode": StudyMode.reviewcard},

    {"cIdx": 4, "mode": StudyMode.EndScreen},
  ];

  int _acc = 0;
  int inARow = 0;
  void haper() {
    if (inARow > 2) {
      Vibration.vibrate(
        pattern: [0, 12, 18, 12, 25],
        intensities: [40, 70, 40, 60, 0],
      );
    }
  }

  int totalRep = 0;
  int totalLapse = 0;
  //push information to db
  void CallQuest(BuildContext context) {
    final count = SetUpLessonList.map((e) => e["cIdx"]).toSet().length;
    context.read<Questnoti>().SetToDB(totalRep, totalRep, count);
  }

  void ResultHandler(bool succ) {
    if (succ) {
      totalRep++;
      inARow++;
      haper();
      if (soundController?.shouldCelebrateStreak(inARow) ?? false) {
        soundController?.playStreak();
      } else {
        soundController?.playCorrect();
      }
      debugPrint("suc $_acc rep :$totalRep");
    } else {
      inARow = 0;
      soundController?.playWrong();
      debugPrint("false $_acc rep :$totalRep");
      _acc++;
      totalLapse++;
    }
  }

  //get variant
  Future<void> getFlashcardList(LearnMode fetchMode) async {
    isLoading = true;
    notifyListeners();
    List<Flashcard> data;
    switch (fetchMode) {
      case LearnMode.sm:
        how = LearnMode.sm;
        data = await _dbhelper.getDueCardLimit(10);
        SetUpLessonList = lessonNotiHelper.sm2;
        break;
      case LearnMode.daily:
        how = LearnMode.daily;
        data = await _dbhelper.getDueCardLimit(10);
        break;
      case LearnMode.all:
        how = LearnMode.all;
        data = await _dbhelper.getDueCardLimit(15);
        SetUpLessonList = lessonNotiHelper.allMode;
        break;
      case LearnMode.shuffle:
        how = LearnMode.shuffle;
        data = await _dbhelper.getDueCardLimit(15);
        SetUpLessonList = lessonNotiHelper.allMode;
        final start = SetUpLessonList.first;
        final end = SetUpLessonList.last;

        // copy pháº§n giá»¯a
        final middle = SetUpLessonList.sublist(1, SetUpLessonList.length - 1);

        // shuffle pháº§n giá»¯a
        middle.shuffle();

        // ghÃ©p láº¡i
        SetUpLessonList = [start, ...middle, end];
        break;
      case LearnMode.devMode:
        how = LearnMode.devMode;
        data = await _dbhelper.getDueCardLimit(10);
        SetUpLessonList = lessonNotiHelper.setUpDevLessonList;
        break;
    }

    _cards.clear();
    _cards.addAll(data);
    mode = SetUpLessonList[currentLessIdx]["mode"];
    for (var c in _cards) {
      debugPrint("${c.word} - ${c.due}");
    }
    await fetchMedia();
    createRateCard();
    isLoading = false;
    notifyListeners();
  }

  Future<void> getByLevel(int level) async {
    isLoading = true;
    notifyListeners();
    List<Flashcard> data;
    how = LearnMode.daily;
    data = await _dbhelper.getCardByLevel(level, 15);
    _cards.clear();
    _cards.addAll(data);
    for (var c in _cards) {
      debugPrint("${c.word} - ${c.due}");
    }
    await fetchMedia();
    mode = SetUpLessonList[currentLessIdx]["mode"];
    isLoading = false;
    createRateCard();
    notifyListeners();
  }

  Future<void> getByMode(StudyMode st) async {
    isLoading = true;
    notifyListeners();
    List<Flashcard> data;
    how = LearnMode.all;
    data = await _dbhelper.getDueCardLimit(15);
    _cards.clear();
    _cards.addAll(data);
    for (var c in _cards) {
      debugPrint("${c.word} - ${c.due}");
    }
    await fetchMedia();
    SetUpLessonList = lessonNotiHelper.createListForLevel(14, st);
    mode = SetUpLessonList[currentLessIdx]["mode"];
    isLoading = false;
    createRateCard();
    notifyListeners();
  }

  String get accuracy {
    int limitedAcc = _acc;
    if (limitedAcc > 7) limitedAcc = 7;
    int percent = 10 - limitedAcc;
    int accuracyPercent = percent * 10;

    return "$accuracyPercent%";
  }

  int get accPercent {
    int limitedAcc = _acc;
    if (limitedAcc > 7) limitedAcc = 7;
    return (10 - limitedAcc) * 10;
  }

  String get accLine => lessonNotiHelper.getAccLine(_acc);

  Future<void> nextCard() async {
    updateRateCard(right);
    if (currentLessIdx < SetUpLessonList.length - 1) {
      _resetTaskState();
      currentLessIdx++;
      mode = SetUpLessonList[currentLessIdx]["mode"];
      await fetchMedia();
      notifyListeners();
    }
  }

  Future<void> skipLesson() async {
    if (currentLessIdx < SetUpLessonList.length - 1) {
      inARow = 0; // Reset streak on skip
      _resetTaskState();
      currentLessIdx++;
      mode = SetUpLessonList[currentLessIdx]["mode"];
      await fetchMedia();
      notifyListeners();
    }
  }

  void _resetTaskState() {
    trueList = null;
    listWord = null;
    list = null;
    states = null;
    currentWordIdx = 0;
    answered = false;
    selectedIndex = null;
    options = null;
    statesBool = null;
    listWI = null;
    listIPA = null;
    listWordPhone = null;
    selectedIPAIDX = null;
    selectedWordIDX = null;
    wordState = List.filled(4, ButtonState.normal);
    ipaState = List.filled(4, ButtonState.normal);
    right = true;
  }

  List<String> get getOptionsShuffle {
    options ??= genOptionsShuffle();
    return options!;
  }

  List<String> genOptionsShuffle() {
    List<String> re = lessonNotiHelper.genOptionsShuffleHelp(_cards, cardIdx);
    statesBool = List.generate(re.length, (_) => false);
    return re;
  }

  String getImagePath() {
    if (File(
      PathService.getFilePath(media, _cards[cardIdx].img ?? ""),
    ).existsSync()) {
      return PathService.getFilePath(media, _cards[cardIdx].img ?? "");
    }
    return "";
  }

  String getSynonymPath() {
    if (File(
      PathService.getFilePath(media, _cards[cardIdx].synonyms ?? ""),
    ).existsSync()) {
      return PathService.getFilePath(media, _cards[cardIdx].synonyms ?? "");
    }
    if (File(
      PathService.getFilePath(media, _cards[cardIdx].img ?? ""),
    ).existsSync()) {
      return PathService.getFilePath(media, _cards[cardIdx].img ?? "");
    }
    return "";
  }

  void CheckAnswer(String letter, int index) {
    if (letter == trueList![currentWordIdx]) {
      states![index] = ButtonState.done;
      listWord![currentWordIdx] = trueList![currentWordIdx];
      notifyListeners();
      currentWordIdx++;
    } else {
      ResultHandler(false);
      inARow = 0;
      states![index] = ButtonState.wrong;
      notifyListeners();
      Future.delayed(Duration(milliseconds: 100), () {
        states![index] = ButtonState.normal;
        notifyListeners();
      });
    }
    if (currentWordIdx == list!.length) {
      answered = true;
      ResultHandler(true);
      notifyListeners();
    }
  }

  List<ButtonState> GetListState() {
    states ??= List.generate(list!.length, (_) => ButtonState.normal);
    return states!;
  }

  List<String> SetUpList() {
    if (list == null && _cards.isNotEmpty) {
      list = _cards[cardIdx].word?.split("");
      trueList = _cards[cardIdx].word!.split("");

      if (list!.length > 1) {
        do {
          list!.shuffle();
        } while (listEquals(list, trueList));
      }
    }
    return list!;
  }

  List<String> SetUpListWord() {
    listWord ??= List.filled(list!.length, "_");
    return listWord!;
  }

  void checkAnswerMC() {
    if (options?[selectedIndex!] == _cards[cardIdx].word) {
      answered = true;
      ResultHandler(true);
      notifyListeners();
    } else {
      answered = true;
      right = false;
      ResultHandler(false);
      inARow = 0;
      notifyListeners();
    }
  }

  void selectOption(int index) {
    if (selectedIndex == null) {
      selectedIndex = index;
      statesBool?[index] = true;
    } else {
      statesBool?[selectedIndex!] = false;
      selectedIndex = index;
      statesBool?[index] = true;
    }

    notifyListeners();
  }

  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void dispose() {
    audioPlayer.dispose();
    stt.cancel();
    super.dispose();
  }

  Future<void> playSound() async {
    if (media != "") {
      try {
        await audioPlayer.play(
          DeviceFileSource(
            PathService.getFilePath(media, _cards[cardIdx].sound ?? ""),
          ),
        );
      } catch (e) {
        debugPrint('$e');
      }
    }
  }

  List<bool> getOptionStateBool() {
    statesBool ??= List<bool>.filled(3, false);
    return statesBool!;
  }

  List<String> genOptions() {
    final List<String> strs = [];
    String word = _cards[cardIdx].word!;
    final rand = Random();
    strs.add(word);

    const String alphabet = 'abcdefghijklmnopqrstuvwxyz';

    while (strs.length < 3) {
      String mixed;
      int attempts = 0;

      if (strs.length == 1) {
        do {
          mixed = generateVariant(word, rand);
          attempts++;
        } while ((mixed == word || strs.contains(mixed)) && attempts < 10);
      } else {
        // Second distractor: full shuffle
        final letters = word.split('');
        do {
          final shuffled = List.from(letters)..shuffle(rand);
          mixed = shuffled.join('');
          attempts++;
        } while ((mixed == word || strs.contains(mixed)) && attempts < 10);
      }

      // Fallback if max attempts reached and no unique variant found
      if (mixed == word || strs.contains(mixed)) {
        int fallbackAttempts = 0;
        do {
          if (word.isNotEmpty) {
            final chars = word.split('');
            int i = rand.nextInt(chars.length);
            chars[i] = alphabet[rand.nextInt(alphabet.length)];
            mixed = chars.join('');
          } else {
            mixed = alphabet[rand.nextInt(alphabet.length)];
          }
          fallbackAttempts++;
          if (fallbackAttempts > 50) {
            // Absolute last resort
            mixed = "${word}_${rand.nextInt(1000)}";
          }
        } while (mixed == word || strs.contains(mixed));
      }

      strs.add(mixed);
    }
    List<String> shuffle = List.from(strs)..shuffle(rand);
    statesBool = List.generate(shuffle.length, (_) => false);
    debugPrint('$shuffle');
    return shuffle;
  }

  String generateVariant(String word, Random rand) {
    if (word.length < 2) return word;

    final chars = word.split('');

    int i = rand.nextInt(chars.length);
    int j = rand.nextInt(chars.length);

    if (i == j) j = (j + 1) % chars.length;

    final temp = chars[i];
    chars[i] = chars[j];
    chars[j] = temp;

    return chars.join('');
  }

  List<String> get getOptionList {
    options ??= genOptions();
    return options!;
  }

  //function

  Future<String> fetchMedia() async {
    try {
      int deckId = _cards[cardIdx].deckId;
      if (mediaMap.containsKey(deckId)) {
        media = mediaMap[deckId] ?? "";
        return mediaMap[deckId]!;
      } else {
        String md = await _dbhelper.getMediaFile(deckId) ?? "";
        mediaMap[deckId] = md;
        media = mediaMap[deckId] ?? "";
        return md;
      }
    } catch (e) {
      debugPrint('$e');
      return "";
    }
  }

  List<WordIPA>? listWI;
  List<String>? listIPA;
  List<String>? listWordPhone;
  int? selectedIPAIDX;
  int? selectedWordIDX;
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

  int learn = 0;
  int practice = 0;
  int speak = 0;
  int review = 0;
  int estimate = 0;
  //count learn mode //start screen provider
  void countLearn() {
    learn = 0;
    practice = 0;
    speak = 0;

    for (int i = 0; i < SetUpLessonList.length; i++) {
      switch (SetUpLessonList[i]["mode"]) {
        case StudyMode.soundAndSight:
          practice++;
          break;
        case StudyMode.wordsnap:
          learn++;
          break;
        case StudyMode.echoSpell:
          practice++;
          break;
        case StudyMode.echoMatch:
          practice++;
          break;
        case StudyMode.echofuse:
          practice++;
          break;
        case StudyMode.mindField:
          learn++;
          break;
        case StudyMode.neuropick:
          practice++;
          break;
        case StudyMode.phonemix:
          practice++;
          break;
        case StudyMode.wordpulse:
          practice++;
          break;
        case StudyMode.meanfuse:
          learn++;
          break;
        case StudyMode.synonympick:
          practice++;
          break;
        case StudyMode.synonymfeild:
          practice++;
          break;
        case StudyMode.speechword:
          speak++;
          break;
      }
    }
    estimate = ((learn + practice + speak) * 0.2).round();
  }

  //
  Future<void> initSTT() async {
    try {
      bool available = await stt.initialize(
        onStatus: (status) => debugPrint('STT status: $status'),
        onError: (errorNotification) =>
            debugPrint('STT error: $errorNotification'),
      );
      if (!available) {
        debugPrint('STT not available or permission denied');
      }
    } catch (e) {
      print(e);
    }
  }

  String re = "";
  final SpeechToText stt = SpeechToText();

  bool hasFinal = false;
  Timer? timeoutTimer;
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
          CheckAnswerSpeech(re);
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
        CheckAnswerSpeech(re);
      }
    });
  }

  void CheckAnswerSpeech(String re) {
    re = re.toLowerCase().trim();
    var wordtrim = answer.toLowerCase().trim();
    answered = true;
    if (normalize(re) == normalize(wordtrim)) {
      right = true;
      ResultHandler(true);
    } else {
      ResultHandler(false);
      right = false;
    }
    notifyListeners();
  }

  void stopListen() async {
    await stt.stop();
  }

  void callDone() {
    answered = true;
    debugPrint("answer up");
    notifyListeners();
  }

  String get correctspeak {
    String str = "right is: $answer";
    if (re != "") {
      str += "  you said: $re";
    }
    return str;
  }

  List<Flashcard> get card {
    switch (how) {
      case LearnMode.shuffle:
        return _cards.take(14).toList();
      case LearnMode.all:
        return _cards.take(14).toList();
      case LearnMode.daily:
        return _cards.take(3).toList();
      case LearnMode.sm:
        return _cards.take(5).toList();

      case LearnMode.devMode:
        return _cards.take(5).toList();
    }
  }

  //sm2
  void updateCard() {
    SMNoti n = SMNoti();
    for (var c in RateCard) {
      int rate = (c["rate"] ?? 3).clamp(0, 5);
      n.updateCardAfterReview(_cards[c["idx"] ?? 0], rate);
    }
  }

  List<Map<String, int>> RateCard = [
    {"idx": 0, "rate": 3},
    {"idx": 1, "rate": 3},
    {"idx": 2, "rate": 3},
  ];
  void createRateCard() {
    int count;

    switch (how) {
      case LearnMode.shuffle:
      case LearnMode.all:
        count = 15;
        break;
      case LearnMode.daily:
        count = 3;
        break;
      case LearnMode.sm:
        count = 5;
        break;

      case LearnMode.devMode:
        count = 5;
        break;
    }

    RateCard = List.generate(count, (i) => {"idx": i, "rate": 3});
  }

  void updateRateCard(bool rating) {
    if (SetUpLessonList[currentLessIdx]["mode"] != StudyMode.phonemix &&
        SetUpLessonList[currentLessIdx]["mode"] != StudyMode.StartScreen &&
        SetUpLessonList[currentLessIdx]["mode"] != StudyMode.EndScreen &&
        SetUpLessonList[currentLessIdx]["mode"] != StudyMode.reviewcard) {
      try {
        var updateCard = RateCard.firstWhere(
          (c) => c["idx"] == SetUpLessonList[currentLessIdx]["cIdx"],
        );
        int currentRate = updateCard["rate"] ?? 0;
        updateCard["rate"] = currentRate + (rating ? 1 : -1);
      } catch (e) {
        debugPrint('$e');
      }
    }
  }
}
