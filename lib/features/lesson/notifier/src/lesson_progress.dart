part of 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';

mixin LessonProgress
    on
        LessonNotiBase,
        LessonResult,
        LessonOptions,
        LessonPhonemix,
        LessonSm2,
        LessonMedia {
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

  //get variant
  Future<void> getFlashcardList(LearnMode fetchMode) async {
    isLoading = true;
    notifyListeners();
    List<Flashcard> data;
    switch (fetchMode) {
      case LearnMode.sm:
        how = LearnMode.sm;
        data = await LessonNotiBase._dbhelper.getDueCardLimit(10);
        SetUpLessonList = lessonNotiHelper.sm2;
        break;
      case LearnMode.daily:
        how = LearnMode.daily;
        data = await LessonNotiBase._dbhelper.getDueCardLimit(10);
        break;
      case LearnMode.all:
        how = LearnMode.all;
        data = await LessonNotiBase._dbhelper.getDueCardLimit(15);
        SetUpLessonList = lessonNotiHelper.allMode;
        break;
      case LearnMode.shuffle:
        how = LearnMode.shuffle;
        data = await LessonNotiBase._dbhelper.getDueCardLimit(15);
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
        data = await LessonNotiBase._dbhelper.getDueCardLimit(10);
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
    data = await LessonNotiBase._dbhelper.getCardByLevel(level, 15);
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
    data = await LessonNotiBase._dbhelper.getDueCardLimit(15);
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
}