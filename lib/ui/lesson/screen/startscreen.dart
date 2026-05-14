import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/noti/lessonNoti.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.watch<LessonNoti>();
    provider.countLearn();
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Lesson Overview",
            style: TextStyle(
              color: AppTheme.yellowPrimary,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
          inforRow(
            line: "Understand New Words",
            mode: "Learn",
            count: provider.learn,
          ),
          inforRow(
            line: "Build Recognition w Images & Audio & Synonym",
            mode: "Practice",
            count: provider.practice,
          ),
          inforRow(
            line: "Improve Pronunciation Accuracy",
            mode: "Speak",
            count: provider.speak,
          ),
          inforRow(
            line: "Reinforce Memory with Review",
            mode: "Review",
            count: provider.learn,
          ),
          Text(
            "estimate learn time: ${provider.estimate} min",
            style: TextStyle(
              color: AppTheme.yellowPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => {reader.nextCard()},
            child: Container(
              width: 470,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppTheme.bluePrimary,
              ),
              child: Center(
                child: Text(
                  "START",
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

class inforRow extends StatelessWidget {
  inforRow({
    super.key,
    required this.line,
    required this.mode,
    required this.count,
  });
  String line;
  String mode;
  int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 150),
        Container(
          width: 130,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  color: AppTheme.yellowPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 20),
              Text(
                mode,
                style: TextStyle(
                  color: AppTheme.yellowPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
        Text(
          line,
          style: TextStyle(
            color: AppTheme.lightText,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


