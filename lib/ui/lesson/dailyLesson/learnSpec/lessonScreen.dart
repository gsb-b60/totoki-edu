import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/lesson/config/storage.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/noti/lessonNoti.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/noti/questNoti.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/noti/timerNoti.dart';
import 'package:totoki_extract/ui/lesson/screen/startscreen.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/echofuseUI.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/echomathUI.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/echospellUI.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/meanfuseUI.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/mindfieldui.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/neuropickUI.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/phonemixUI.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/reviewUI.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/sound&sightUI.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/speechwordUI.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/synonymfeildUI.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/synonympickUI.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/wordpulseUI.dart';
import 'package:totoki_extract/ui/lesson/studymodeForLesson/wordsnapUI.dart';
import 'package:totoki_extract/services/sound_controller.dart';

import 'package:provider/provider.dart';
import '../../screen/endscreen.dart';

class LessonScreen extends StatefulWidget {
  LessonScreen({super.key, required this.fetchMode});
  LearnMode fetchMode;
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LessonNoti(
            soundController: context.read<SoundController>(),
          )..getFlashcardList(widget.fetchMode),
        ),
        ChangeNotifierProvider(create: (context) => TimerNoti()..start()),
        ChangeNotifierProvider(create: (context) => Questnoti()),
      ],

      child: Consumer3<LessonNoti, TimerNoti, Questnoti>(
        builder: (context, provider, timer, quest, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          switch (provider.mode) {
            case StudyMode.soundAndSight:
              return SoundNSightUI();
            case StudyMode.wordsnap:
              return WordSnapUI();
            case StudyMode.echoSpell:
              return EchospellUI();
            case StudyMode.echoMatch:
              return EchoMatchUI();
            case StudyMode.echofuse:
              return EchoFuseUI();
            case StudyMode.mindField:
              return MindFeildUI();
            case StudyMode.neuropick:
              return NeuroPickUI();
            case StudyMode.phonemix:
              return PhoneMixUI();
            case StudyMode.wordpulse:
              return WordPulseUI();
            case StudyMode.EndScreen:
              return EndScreen();
            case StudyMode.meanfuse:
              return MeanfuseUI();
            case StudyMode.StartScreen:
              return StartScreen();
            case StudyMode.synonympick:
              return SynonympickUI();
            case StudyMode.synonymfeild:
              return SynonymfeildUI();
            case StudyMode.speechword:
              return SpeechWordUI();
            case StudyMode.reviewcard:
              return ReviewUI();
            default:
              return Text("Select a Study Mode");
          }
        },
      ),
    );
  }
}


