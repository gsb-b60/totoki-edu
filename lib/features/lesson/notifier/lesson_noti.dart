import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:totoki_extract/business/user/history_lesson.dart';
import 'package:totoki_extract/business/user/lesson_type.dart';
import 'package:totoki_extract/data/user_database/history_lesson_dao.dart';
import 'package:totoki_extract/data/user_database/user_db_helper.dart';
import 'package:totoki_extract/features/lesson/models/storage.dart';
import 'package:totoki_extract/features/lesson/notifier/quest_noti.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/data/card_database/database_helper.dart';
import 'package:totoki_extract/business/flashcard/supermemo.dart';
import 'package:totoki_extract/services/sound_controller.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vibration/vibration.dart';

part 'src/lesson_media.dart';
part 'src/lesson_options.dart';
part 'src/lesson_phonemix.dart';
part 'src/lesson_progress.dart';
part 'src/lesson_result.dart';
part 'src/lesson_sm2.dart';
part 'src/lesson_speech.dart';
part 'src/lesson_history.dart';

enum ButtonState { normal, selected, done, wrong }

abstract class LessonNotiBase extends ChangeNotifier {
  LessonNotiBase({this.soundController});

  final SoundController? soundController;

  //data
  static final _dbhelper = DatabaseHelper.instance;
  final List<Flashcard> _cards = [];
  bool isLoading = false;
  int currentCardIdx = 0;
  int currentLessIdx = 0;

  int get cardIdx => setUpLessonList[currentLessIdx]["cIdx"];
  //data

  double get value =>
      (_cards.isEmpty) ? 0 : currentLessIdx / (setUpLessonList.length);
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

  //lession logic
  StudyMode? mode;
  LearnMode how = LearnMode.daily;
  List<Map<String, dynamic>> setUpLessonList = [
    {"cIdx": 0, "mode": StudyMode.startScreen},

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

    {"cIdx": 4, "mode": StudyMode.endScreen},
  ];
}

class LessonNoti extends LessonNotiBase
    with
        LessonResult,
        LessonMedia,
        LessonSm2,
        LessonOptions,
        LessonPhonemix,
        LessonSpeech,
        LessonHistory,
        LessonProgress {
  LessonNoti({super.soundController});

  @override
  void dispose() {
    audioPlayer.dispose();
    stt.cancel();
    super.dispose();
  }
}
