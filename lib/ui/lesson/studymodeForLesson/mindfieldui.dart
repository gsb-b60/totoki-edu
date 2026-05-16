import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/noti/lessonNoti.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/widget/checkBtnVertical.dart';
import 'package:totoki_extract/widget/choiceBtnVertical.dart';
import 'package:totoki_extract/widget/progessIndicator.dart';
import 'package:totoki_extract/widget/reviewScreen.dart';
import 'package:totoki_extract/widget/skipBtn.dart';
import 'package:provider/provider.dart';

class MindFeildUI extends StatefulWidget {
  const MindFeildUI({super.key});

  @override
  State<MindFeildUI> createState() => _MindFeildUIState();
}

class _MindFeildUIState extends State<MindFeildUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
    final options = provider.getOptionList;
    final mean = provider.meaning;
    final states = provider.getOptionStateBool();

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
                    "Select the correct answer",
                    style: AppTheme.screenTitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 1),
                  // Meaning section with scroll for long text
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.2,
                    ),
                    child: SingleChildScrollView(
                      child: Center(
                        child: Text(
                          mean,
                          style: AppTheme.sectionHeaderStyle.copyWith(
                            color: AppTheme.lightText,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
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
