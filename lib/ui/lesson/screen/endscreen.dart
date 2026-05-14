import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/noti/lessonNoti.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/noti/timerNoti.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:provider/provider.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerNoti>();
    final reader = context.read<TimerNoti>();
    
    reader.stop();
    final elipse = timer.formatted;

    final less = context.watch<LessonNoti>();
    final lessReader=context.watch<LessonNoti>();
    lessReader.CallQuest(context);
    less.updateCard();
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Lesson complete!",
            style: TextStyle(
              color: AppTheme.yellowPrimary,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnalystWidget(
                co: AppTheme.yellowPrimary,
                line: "DONE",
                list: [
                  Icon(Icons.bolt, color: AppTheme.yellowPrimary, size: 30),
                  Text(
                  "25",
                    style: TextStyle(
                      color: AppTheme.yellowPrimary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              AnalystWidget(
                co: AppTheme.greenPrimary,
                line: less.accLine,
                list: [
                  Icon(
                    Icons.my_location,
                    color: AppTheme.greenPrimary,
                    size: 30,
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: less.accPercent.toDouble()),
                    duration: Duration(seconds: 2),
                    builder: (context, value, child) {
                      final current = "${value.toInt()} %";
                      return Text(
                        current,
                        style: TextStyle(
                          color: AppTheme.greenPrimary,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
              AnalystWidget(
                co: AppTheme.bluePrimary,
                line: timer.getThresholdString,
                list: [
                  Icon(Icons.timer, color: AppTheme.bluePrimary, size: 30),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: timer.time.inSeconds.toDouble(),
                    ),
                    duration: const Duration(
                      seconds: 2,
                    ), // tốc độ chạy animation
                    builder: (context, value, child) {
                      final current = Duration(seconds: value.toInt());
                      final mm = current.inMinutes
                          .remainder(60)
                          .toString()
                          .padLeft(2, "0");
                      final ss = current.inSeconds
                          .remainder(60)
                          .toString()
                          .padLeft(2, "0");

                      return Text(
                        "$mm:$ss",
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.bluePrimary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () => {Navigator.pop(context)},
            child: Container(
              width: 470,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppTheme.bluePrimary,
              ),
              child: Center(
                child: Text(
                  "Continue",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnalystWidget extends StatelessWidget {
  AnalystWidget({
    super.key,
    required this.co,
    required this.line,
    required this.list,
  });
  final String line;
  final Color co;
  List<Widget> list;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: co,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            line,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 80,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.darkBase,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: list,
            ),
          ),
        ],
      ),
    );
  }
}


