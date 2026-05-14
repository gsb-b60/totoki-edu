import 'dart:io';

import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/noti/lessonNoti.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/widget/checkBtnVertical.dart';
import 'package:totoki_extract/widget/choiceBtnVertical.dart';
import 'package:totoki_extract/widget/progessIndicator.dart';
import 'package:totoki_extract/widget/reviewScreen.dart';
import 'package:provider/provider.dart';

class NeuroPickUI extends StatefulWidget {
  const NeuroPickUI({super.key});

  @override
  State<NeuroPickUI> createState() => _NeuroPickUIState();
}

class _NeuroPickUIState extends State<NeuroPickUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
    provider.fetchMedia();
    List<String> options = provider.getOptionsShuffle;
    List<bool> states = provider.getOptionStateBool();

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppTheme.darkBorder,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: ProgressBar(value: provider.value, inARow: provider.inARow),
        backgroundColor: AppTheme.darkBase,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 40),
                  Text(
                    "Select the correct answer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (provider.getImagePath() != "")
                    Container(
                      width: 390,
                      height: 270,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(provider.getImagePath()),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 270,
                    width: 350,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: options.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Center(
                                child: ChoiceBtnVertical(
                                  value: options[index],
                                  isSelected: states[index],
                                  onPressed: () {
                                    reader.selectOption(index);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        CheckBtnVertical(
                          isChecked: provider.checkable,
                          onCheck: () {
                            reader.checkAnswerMC();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            bottom: provider.answered ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: ReviewScreen(
              right: provider.right,
              answer: provider.answer,
              onPressed: () {
                reader.nextCard();
              },
            ),
          ),
        ],
      ),
    );
  }
}





