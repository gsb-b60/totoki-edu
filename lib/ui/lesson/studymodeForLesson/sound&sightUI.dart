import 'dart:io';
import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/noti/lessonNoti.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/widget/choiceBtn4States.dart';
import 'package:totoki_extract/widget/progessIndicator.dart';
import 'package:totoki_extract/widget/reviewScreen.dart';
import 'package:totoki_extract/widget/skipBtn.dart';
import 'package:provider/provider.dart';

class SoundNSightUI extends StatefulWidget {
  const SoundNSightUI({super.key});

  @override
  State<SoundNSightUI> createState() => _SoundNSightUIState();
}

class _SoundNSightUIState extends State<SoundNSightUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
    provider.fetchMedia();
    List<String> list = provider.SetUpList();
    List<String> listWord = provider.SetUpListWord();
    List<ButtonState> listState = provider.GetListState();
    String img = provider.getImagePath();

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: ProgressBar(value: provider.value, inARow: provider.inARow),
        actions: [
          SkipBtn(onPressed: () => reader.skipLesson()),
        ],
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
                    "Tap to build the word.",
                    style: AppTheme.screenTitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 1),
                  // Image section
                  if (img != "")
                    Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.darkBorder, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(File(img), fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: IconButton.outlined(
                      onPressed: () => reader.playSound(),
                      iconSize: 48,
                      icon: const Icon(
                        Icons.volume_up,
                        color: AppTheme.lightText,
                      ),
                      style: IconButton.styleFrom(
                        side: const BorderSide(color: AppTheme.darkBorder, width: 2),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Built word area
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(listWord.length, (index) {
                        String value = listWord[index];
                        return Text(
                          value,
                          style: AppTheme.heroStyle.copyWith(fontFamily: 'Roboto', fontSize: 36),
                        );
                      }),
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Available letters in Thumb Zone
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Center(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: List.generate(list.length, (index) {
                            final value = list[index];
                            return ChoiceBtnStates(
                              value: value,
                              state: listState[index],
                              onChoose: () {
                                reader.CheckAnswer(value, index);
                              },
                            );
                          }),
                        ),
                      ),
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
                right: true,
                answer: provider.answer,
                onPressed: () {
                  reader.nextCard();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
