part of 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';

mixin LessonResult on LessonNotiBase {
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
}