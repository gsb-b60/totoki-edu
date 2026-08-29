import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';
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
    provider.countLearn();

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Lesson Overview",
                style: AppTheme.screenTitleStyle.copyWith(
                  color: AppTheme.yellowPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _InfoCard(
                        mode: "Learn",
                        count: provider.learn,
                        description: "New Words",
                        color: FlashcardTheme.getStudyModeColor("meanfuse"),
                      ),
                      _InfoCard(
                        mode: "Practice",
                        count: provider.practice,
                        description: "Recognition w Images & Audio",
                        color: FlashcardTheme.getStudyModeColor("wordsnap"),
                      ),
                      _InfoCard(
                        mode: "Speak",
                        count: provider.speak,
                        description: "Pronunciation Accuracy",
                        color: FlashcardTheme.getStudyModeColor("echospell"),
                      ),
                      _InfoCard(
                        mode: "Review",
                        count: provider.learn,
                        description: "",
                        color: FlashcardTheme.getStudyModeColor("neuropick"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "estimate learn time: ${provider.estimate} min",
                style: AppTheme.bodyLargeStyle.copyWith(
                  color: AppTheme.yellowPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // START Button in Thumb Zone
              ElevatedButton(
                onPressed: () => context.read<LessonNoti>().nextCard(),
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
                  "START",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String mode;
  final int count;
  final String description;
  final Color color;

  const _InfoCard({
    required this.mode,
    required this.count,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "$count ",
                      style: AppTheme.sectionHeaderStyle.copyWith(
                        color: AppTheme.yellowPrimary,
                      ),
                    ),
                    Text(mode, style: AppTheme.sectionHeaderStyle),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.bodyMediumStyle.copyWith(
                    color: AppTheme.lightText.withValues(alpha: 0.7),
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
