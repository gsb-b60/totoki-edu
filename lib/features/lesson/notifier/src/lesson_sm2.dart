part of 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';

mixin LessonSm2 on LessonNotiBase {
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
    for (var c in rateCard) {
      int rate = (c["rate"] ?? 3).clamp(0, 5);
      n.updateCardAfterReview(_cards[c["idx"] ?? 0], rate);
    }
  }

  List<Map<String, int>> rateCard = [
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

    rateCard = List.generate(count, (i) => {"idx": i, "rate": 3});
  }

  void updateRateCard(bool rating) {
    if (setUpLessonList[currentLessIdx]["mode"] != StudyMode.phonemix &&
        setUpLessonList[currentLessIdx]["mode"] != StudyMode.startScreen &&
        setUpLessonList[currentLessIdx]["mode"] != StudyMode.endScreen &&
        setUpLessonList[currentLessIdx]["mode"] != StudyMode.reviewcard) {
      try {
        var updateCard = rateCard.firstWhere(
          (c) => c["idx"] == setUpLessonList[currentLessIdx]["cIdx"],
        );
        int currentRate = updateCard["rate"] ?? 0;
        updateCard["rate"] = currentRate + (rating ? 1 : -1);
      } catch (e) {
        debugPrint('$e');
      }
    }
  }
}