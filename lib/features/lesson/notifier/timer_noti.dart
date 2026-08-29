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
    if (elapsed <= ThresholdTime.Super) {
      return ThresholdTime.SuperStr;
    } else if (elapsed <= ThresholdTime.Quick) {
      return ThresholdTime.QuickStr;
    } else if (elapsed <= ThresholdTime.Moderate) {
      return ThresholdTime.ModerateStr;
    } else {
      return ThresholdTime.SlowStr;
    }
  }
}


