import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';
import 'package:totoki_extract/ui/widget/progress_indicator.dart';
import 'package:totoki_extract/ui/widget/review_screen.dart';
import 'package:totoki_extract/ui/widget/skip_btn.dart';
import 'package:provider/provider.dart';

class SpeechWordUI extends StatefulWidget {
  const SpeechWordUI({super.key});

  @override
  State<SpeechWordUI> createState() => _SpeechWordUIState();
}

class _SpeechWordUIState extends State<SpeechWordUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
    provider.initSTT();

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
                    "Speak this word",
                    style: AppTheme.screenTitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 1),
                  // Word and IPA section
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            provider.answer,
                            style: AppTheme.heroStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.ipa,
                            style: AppTheme.sectionHeaderStyle.copyWith(
                              color: AppTheme.lightText.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Mic Button in Thumb Zone
                  Center(
                    child: GestureDetector(
                      onTap: () => reader.startListening(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.bluePrimary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.bluePrimary.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.mic,
                              color: AppTheme.bluePrimary,
                              size: 64,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "TAP TO SPEAK",
                              style: AppTheme.bodyLargeStyle.copyWith(
                                color: AppTheme.bluePrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
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
                answer: provider.correctspeak,
                onPressed: () => reader.nextCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
