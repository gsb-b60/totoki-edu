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
    String imgPath = provider.getImagePath();

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: ProgressBar(value: provider.value, inARow: provider.inARow),
        backgroundColor: AppTheme.darkBase,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Select the correct answer",
                    style: AppTheme.screenTitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 1),
                  // Image section
                  if (imgPath != "")
                    Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.darkBorder, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(File(imgPath), fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  const Spacer(flex: 1),
                  // Choices in Thumb Zone
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(options.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: ChoiceBtnVertical(
                              value: options[index],
                              isSelected: states[index],
                              onPressed: () => reader.selectOption(index),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: CheckBtnVertical(
                      isChecked: provider.checkable,
                      onCheck: () => reader.checkAnswerMC(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Review Overlay
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
                onPressed: () => reader.nextCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
