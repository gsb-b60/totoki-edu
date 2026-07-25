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
                        icon: Icons.lightbulb_outline,
                        mode: "Learn",
                        count: provider.learn,
                        description: "Understand New Words",
                        color: FlashcardTheme.getStudyModeColor("meanfuse"),
                      ),
                      _InfoCard(
                        icon: Icons.psychology_outlined,
                        mode: "Practice",
                        count: provider.practice,
                        description: "Build Recognition w Images & Audio",
                        color: FlashcardTheme.getStudyModeColor("wordsnap"),
                      ),
                      _InfoCard(
                        icon: Icons.record_voice_over_outlined,
                        mode: "Speak",
                        count: provider.speak,
                        description: "Improve Pronunciation Accuracy",
                        color: FlashcardTheme.getStudyModeColor("echospell"),
                      ),
                      _InfoCard(
                        icon: Icons.history,
                        mode: "Review",
                        count: provider.learn,
                        description: "Reinforce Memory with Review",
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
  final IconData icon;
  final String mode;
  final int count;
  final String description;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.mode,
    required this.count,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
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
                    Text(
                      mode,
                      style: AppTheme.sectionHeaderStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.bodyMediumStyle.copyWith(
                    color: AppTheme.lightText.withOpacity(0.7),
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
