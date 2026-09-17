import 'package:flutter/material.dart';
import 'package:totoki_extract/features/lesson/models/threshold.dart';


class TimerNoti extends ChangeNotifier {
  final stopWatch = Stopwatch();
  Duration? elapse;
  void start() {
    stopWatch.start();
  }

  Future<void> stop() async{
    stopWatch.stop();
    elapse = stopWatch.elapsed;
    stopWatch.reset();
  }

  Duration get time => elapse ?? Duration(seconds: 180);
  String get formatted =>
      "${time.inMinutes}:${(time.inSeconds % 60).toString().padLeft(2, '0')}";

  String get getThresholdString {
    Duration elapsed = elapse ?? Duration(seconds: 180);
    if (elapsed <= ThresholdTime.superDuration) {
      return ThresholdTime.superStr;
    } else if (elapsed <= ThresholdTime.quick) {
      return ThresholdTime.quickStr;
    } else if (elapsed <= ThresholdTime.moderate) {
      return ThresholdTime.moderateStr;
    } else {
      return ThresholdTime.slowStr;
    }
  }
}


