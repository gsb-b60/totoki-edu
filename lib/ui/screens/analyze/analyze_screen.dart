import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/features/user/user_notifier.dart';
import 'package:totoki_extract/features/user/analyze_notifier.dart';
import 'package:totoki_extract/ui/screens/analyze/blocks/today_pulse_block.dart';
import 'package:totoki_extract/ui/screens/analyze/blocks/weekly_lesson_block.dart';
import 'package:totoki_extract/ui/screens/analyze/blocks/lesson_progress_block.dart';
import 'package:totoki_extract/ui/screens/analyze/blocks/review_health_block.dart';
import 'package:totoki_extract/ui/screens/analyze/blocks/activity_calendar_block.dart';
import 'package:totoki_extract/ui/screens/analyze/analyze_constants.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: const SizedBox.shrink(),
        title: const Text(
          'PHÂN TÍCH',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Consumer<UserNotifier>(
        builder: (context, userNotifier, child) {
          final user = userNotifier.user;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF009688)),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFF95D332),
            backgroundColor: Colors.grey[100],
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AnalyzeSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AnalyzeSpacing.lg),
                    
                    // Block 1: Today's Pulse
                    const TodayPulseBlock(),
                    
                    const SizedBox(height: AnalyzeSpacing.xxl),
                    
                    // Block 2: This Week
                    const WeeklyLessonBlock(),
                    
                    const SizedBox(height: AnalyzeSpacing.xxl),
                    
                    // Block 3: Lesson Progress
                    const LessonProgressBlock(),
                    
                    const SizedBox(height: AnalyzeSpacing.xxl),
                    
                    // Block 4: Review Health
                    const ReviewHealthBlock(),
                    
                    const SizedBox(height: AnalyzeSpacing.xxl),
                    
                    // Block 5: Activity Calendar
                    const ActivityCalendarBlock(),
                    
                    const SizedBox(height: AnalyzeSpacing.xxl),
                  ],
                ),
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