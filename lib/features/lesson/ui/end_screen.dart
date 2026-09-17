import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/business/user/lesson_type.dart';
import 'package:totoki_extract/features/user/user_notifier.dart';
import 'package:totoki_extract/services/sound_controller.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';
import 'package:totoki_extract/features/lesson/notifier/timer_noti.dart';

class EndScreen extends StatefulWidget {
  const EndScreen({super.key});

  @override
  State<EndScreen> createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen> {
  bool _didCompleteLesson = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _didCompleteLesson) return;

      _didCompleteLesson = true;
      context.read<TimerNoti>().stop();

      final lesson = context.read<LessonNoti>();
      lesson.callQuest(context);
      lesson.updateCard();
      context.read<SoundController>().playFinish();

      final user = context.read<UserNotifier>().user;
      if (user != null) {
        final timer = context.read<TimerNoti>();
        try {
          await lesson.saveLession(
            user.id,
            LessonType.dailyLearn,
            accuracy: lesson.accPercent,
            timeSpent: timer.time.inSeconds,
          );
        } catch (e) {
          debugPrint('Failed to save lesson history: $e');
        }
      }
    });
  }
  

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerNoti>();
    final elipse = timer.formatted;
    final less = context.watch<LessonNoti>();

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Lesson complete!",
                    style: AppTheme.screenTitleStyle.copyWith(
                      color: AppTheme.yellowPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    elipse,
                    style: AppTheme.bodyMediumStyle.copyWith(
                      color: AppTheme.lightText.withValues(alpha:0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight * 0.56,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnalystWidget(
                              co: AppTheme.yellowPrimary,
                              line: "DONE",
                              width: width,
                              list: [
                                const Icon(
                                  Icons.bolt,
                                  color: AppTheme.yellowPrimary,
                                  size: 30,
                                ),
                                Text(
                                  "25",
                                  style: AppTheme.heroStyle.copyWith(
                                    color: AppTheme.yellowPrimary,
                                    fontSize: 40,
                                  ),
                                ),
                              ],
                            ),
                            AnalystWidget(
                              co: AppTheme.greenPrimary,
                              line: less.accLine,
                              width: width,
                              list: [
                                const Icon(
                                  Icons.my_location,
                                  color: AppTheme.greenPrimary,
                                  size: 30,
                                ),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0,
                                    end: less.accPercent.toDouble(),
                                  ),
                                  duration: const Duration(seconds: 2),
                                  builder: (context, value, child) {
                                    final current = "${value.toInt()} %";
                                    return Text(
                                      current,
                                      style: AppTheme.heroStyle.copyWith(
                                        color: AppTheme.greenPrimary,
                                        fontSize: 40,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            AnalystWidget(
                              co: AppTheme.bluePrimary,
                              line: timer.getThresholdString,
                              width: width,
                              list: [
                                const Icon(
                                  Icons.timer,
                                  color: AppTheme.bluePrimary,
                                  size: 30,
                                ),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0,
                                    end: timer.time.inSeconds.toDouble(),
                                  ),
                                  duration: const Duration(seconds: 2),
                                  builder: (context, value, child) {
                                    final current = Duration(
                                      seconds: value.toInt(),
                                    );
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
                                      style: AppTheme.heroStyle.copyWith(
                                        color: AppTheme.bluePrimary,
                                        fontSize: 40,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bluePrimary,
                      foregroundColor: AppTheme.lightText,
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AnalystWidget extends StatelessWidget {
  const AnalystWidget({
    super.key,
    required this.co,
    required this.line,
    required this.list,
    required this.width,
  });

  final String line;
  final Color co;
  final double width;
  final List<Widget> list;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            line,
            style: AppTheme.sectionHeaderStyle.copyWith(color: co),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: width < 360 ? 72 : 84),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.darkBase,
                    border: Border.all(color: co.withValues(alpha:0.45)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < list.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        list[i],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
