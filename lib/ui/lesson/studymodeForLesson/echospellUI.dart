import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/noti/lessonNoti.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/widget/choiceBtn4States.dart';
import 'package:totoki_extract/widget/progessIndicator.dart';
import 'package:totoki_extract/widget/reviewScreen.dart';
import 'package:provider/provider.dart';

class EchospellUI extends StatefulWidget {
  const EchospellUI({super.key});

  @override
  State<EchospellUI> createState() => _EchospellUIState();
}

class _EchospellUIState extends State<EchospellUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
    provider.fetchMedia();
    final list = provider.SetUpList();
    final listWord = provider.SetUpListWord();
    final listState = provider.GetListState();

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
                    "Tap to build the word.",
                    style: AppTheme.screenTitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 1),
                  Center(
                    child: Column(
                      children: [
                        IconButton.outlined(
                          onPressed: () => reader.playSound(),
                          iconSize: 64,
                          icon: const Icon(
                            Icons.volume_up,
                            color: AppTheme.lightText,
                          ),
                          style: IconButton.styleFrom(
                            side: const BorderSide(color: AppTheme.darkBorder, width: 2),
                            padding: const EdgeInsets.all(24),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap to listen",
                          style: AppTheme.captionStyle.copyWith(color: AppTheme.darkBorder),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Built word area
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(listWord.length, (index) {
                        String value = listWord[index];
                        return Text(
                          value,
                          style: AppTheme.heroStyle.copyWith(fontFamily: 'Roboto'),
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
                  const SizedBox(height: 32),
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
