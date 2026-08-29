import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/widget/checkBtnVertical.dart';
import 'package:totoki_extract/ui/widget/choiceBtnVertical.dart';
import 'package:totoki_extract/ui/widget/progressIndicator.dart';
import 'package:totoki_extract/ui/widget/reviewScreen.dart';
import 'package:totoki_extract/ui/widget/skipBtn.dart';
import 'package:provider/provider.dart';

class EchoFuseUI extends StatefulWidget {
  const EchoFuseUI({super.key});

  @override
  State<EchoFuseUI> createState() => _EchoFuseUIState();
}

class _EchoFuseUIState extends State<EchoFuseUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
    provider.fetchMedia();
    final options = provider.getOptionsShuffle;
    final states = provider.getOptionStateBool();

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.darkBorder,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: ProgressBar(value: provider.value, inARow: provider.inARow),
        actions: [SkipBtn(onPressed: () => reader.skipLesson())],
        backgroundColor: AppTheme.darkBase,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Select the correct answer",
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
                            side: const BorderSide(
                              color: AppTheme.darkBorder,
                              width: 2,
                            ),
                            padding: const EdgeInsets.all(24),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap to listen",
                          style: AppTheme.captionStyle.copyWith(
                            color: AppTheme.darkBorder,
                          ),
                        ),
                      ],
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
              bottom: provider.answered
                  ? 0
                  : -MediaQuery.of(context).size.height,
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
