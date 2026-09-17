import 'dart:math';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';
import 'package:totoki_extract/ui/widget/progress_indicator.dart';
import 'package:totoki_extract/ui/widget/review_screen.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:provider/provider.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:totoki_extract/ui/widget/skip_btn.dart';

class ReviewUI extends StatefulWidget {
  const ReviewUI({super.key});

  @override
  State<ReviewUI> createState() => _ReviewUIState();
}

class _ReviewUIState extends State<ReviewUI> {
  final controller = SwipableStackController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();
    List<Flashcard> list = provider.card;

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
                vertical: 32.0,
              ),
              child: SwipableStack(
                onSwipeCompleted: (index, direction) {
                  if (index == list.length - 1) {
                    reader.callDone();
                  }
                },
                controller: controller,
                overlayBuilder: (context, properties) {
                  final opacity = min(properties.swipeProgress, 1.0);
                  switch (properties.direction) {
                    case SwipeDirection.up:
                      return Opacity(
                        opacity: opacity,
                        child: const CardLabel(
                          color: AppTheme.redPrimary,
                          value: "Hard",
                        ),
                      );
                    case SwipeDirection.down:
                      return Opacity(
                        opacity: opacity,
                        child: const CardLabel(
                          color: AppTheme.greenPrimary,
                          value: "Easy",
                        ),
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
                detectableSwipeDirections: const {
                  SwipeDirection.up,
                  SwipeDirection.down,
                },
                builder: (context, properties) {
                  int index = (properties.index) % list.length;
                  return SizedBox.expand(
                    child: FlipCard(
                      direction: FlipDirection.VERTICAL,
                      front: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.darkBorder,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: SingleChildScrollView(
                              child: Text(
                                list[index].word ?? "",
                                style: AppTheme.heroStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      back: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.primaryTeal,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: SingleChildScrollView(
                              child: Text(
                                list[index].meaning ?? "",
                                style: AppTheme.sectionHeaderStyle.copyWith(
                                  fontSize: 28,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Actions in Thumb Zone
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48, left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      label: "HARD",
                      color: AppTheme.redPrimary,
                      onTap: () =>
                          controller.next(swipeDirection: SwipeDirection.up),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => controller.rewind(),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: const BoxDecoration(
                          color: AppTheme.darkCard,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.refresh,
                          size: 28,
                          color: AppTheme.lightText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _ActionButton(
                      label: "EASY",
                      color: AppTheme.greenPrimary,
                      onTap: () =>
                          controller.next(swipeDirection: SwipeDirection.down),
                    ),
                  ],
                ),
              ),
            ),
            // Review Overlay (Done/Next Card)
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

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppTheme.lightText,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class CardLabel extends StatelessWidget {
  final Color color;
  final String value;
  const CardLabel({super.key, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.darkBase.withValues(alpha: 0.8),
          border: Border.all(color: color, width: 4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
