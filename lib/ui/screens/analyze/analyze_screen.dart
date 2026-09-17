import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/features/user/user_notifier.dart';
import 'package:totoki_extract/features/user/analyze_notifier.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/analyze/blocks/today_pulse_block.dart';
import 'package:totoki_extract/ui/screens/analyze/blocks/weekly_lesson_block.dart';
import 'package:totoki_extract/ui/screens/analyze/blocks/lesson_progress_block.dart';
import 'package:totoki_extract/ui/screens/analyze/blocks/review_health_block.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userNotifier = context.read<UserNotifier>();
      final analyzeNotifier = context.read<AnalyzeNotifier>();
      final user = userNotifier.user;

      if (user != null) {
        analyzeNotifier.loadAll(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      body: Consumer<UserNotifier>(
        builder: (context, userNotifier, child) {
          final user = userNotifier.user;

          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.greenPrimary),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.greenPrimary,
            backgroundColor: Colors.grey[800],
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const _AnalyzeContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    final userNotifier = context.read<UserNotifier>();
    final analyzeNotifier = context.read<AnalyzeNotifier>();
    final user = userNotifier.user;

    if (user != null) {
      await analyzeNotifier.refresh(user.id);
    }
  }
}

class _AnalyzeContent extends StatelessWidget {
  const _AnalyzeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24.0),
        const TodayPulseBlock(),
        const SizedBox(height: 48.0),
        const WeeklyLessonBlock(),
        const SizedBox(height: 48.0),
        const LessonProgressBlock(),
        const SizedBox(height: 48.0),
        const ReviewHealthBlock(),
        const SizedBox(height: 48.0),
      ],
    );
  }
}