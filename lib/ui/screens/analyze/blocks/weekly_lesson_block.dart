import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/features/user/analyze_notifier.dart';
import 'package:totoki_extract/features/user/analytics_models.dart';
import 'package:totoki_extract/business/user/lessonType.dart';
import 'package:totoki_extract/ui/screens/analyze/analyze_constants.dart';

class WeeklyLessonBlock extends StatelessWidget {
  const WeeklyLessonBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyzeNotifier>(
      builder: (context, analyzeNotifier, child) {
        final notifier = analyzeNotifier.lesson;
        if (notifier.isLoading) {
          return _buildLoading();
        }

        if (notifier.error != null) {
          return _buildError(notifier.error!);
        }

        if (notifier.weeklyTrend.isEmpty) {
          return _buildEmpty();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AnalyzeSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TUẦN NÀY',
                style: TextStyle(
                  color: AnalyzeColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AnalyzeSpacing.lg),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: notifier.weeklyTrend.length,
                  itemBuilder: (context, index) {
                    final day = notifier.weeklyTrend[index];
                    return _buildDayColumn(context, day);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayColumn(BuildContext context, DailyLessonAggregate day) {
    final dayName = _getDayName(day.date);
    final isToday = _isToday(day.date);
    
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: AnalyzeSpacing.sm),
      padding: const EdgeInsets.all(AnalyzeSpacing.sm),
      decoration: BoxDecoration(
        color: isToday ? AnalyzeColors.greenPrimary.withValues(alpha: 0.1) : AnalyzeColors.bgCard,
        borderRadius: BorderRadius.circular(AnalyzeSpacing.md),
        border: isToday
            ? Border.all(color: AnalyzeColors.greenPrimary, width: 2)
            : Border.all(color: AnalyzeColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isToday ? AnalyzeColors.greenPrimary : AnalyzeColors.textMuted,
            ),
          ),
          const SizedBox(height: AnalyzeSpacing.xs),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: LessonType.values.map((type) {
                final minutes = day.minutesByType[type] ?? 0;
                return _buildLessonPill(type, minutes);
              }).toList(),
            ),
          ),
          const SizedBox(height: AnalyzeSpacing.xs),
          Text(
            '${_totalMinutes(day)}m',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AnalyzeColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonPill(LessonType type, int minutes) {
    final color = AnalyzeColors.lessonColor(type);
    final initial = _getInitial(type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: minutes > 0 ? color.withValues(alpha: 0.15) : AnalyzeColors.borderLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$initial${minutes > 0 ? minutes : ''}',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: minutes > 0 ? color : AnalyzeColors.textMuted,
        ),
      ),
    );
  }

  String _getDayName(DateTime date) {
    const names = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return names[date.weekday % 7];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  String _getInitial(LessonType type) {
    switch (type) {
      case LessonType.dailyLearn: return 'D';
      case LessonType.ielts: return 'I';
    }
  }

  int _totalMinutes(DailyLessonAggregate day) {
    return day.minutesByType.values.fold(0, (a, b) => a + b);
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AnalyzeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TUẦN NÀY',
            style: TextStyle(
              color: AnalyzeColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AnalyzeSpacing.lg),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                return Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: AnalyzeSpacing.sm),
                  decoration: BoxDecoration(
                    color: AnalyzeColors.bgSecondary,
                    borderRadius: BorderRadius.circular(AnalyzeSpacing.md),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AnalyzeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TUẦN NÀY',
            style: TextStyle(
              color: AnalyzeColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AnalyzeSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AnalyzeSpacing.lg),
            decoration: BoxDecoration(
              color: AnalyzeColors.bgCard,
              borderRadius: BorderRadius.circular(AnalyzeSpacing.md),
              border: Border.all(color: AnalyzeColors.borderLight),
            ),
            child: const Text(
              'Không thể tải dữ liệu',
              style: TextStyle(
                fontSize: 14,
                color: AnalyzeColors.redPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AnalyzeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TUẦN NÀY',
            style: TextStyle(
              color: AnalyzeColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AnalyzeSpacing.lg),
          Container(
            height: 120,
            padding: const EdgeInsets.all(AnalyzeSpacing.lg),
            decoration: BoxDecoration(
              color: AnalyzeColors.bgCard,
              borderRadius: BorderRadius.circular(AnalyzeSpacing.md),
              border: Border.all(color: AnalyzeColors.borderLight),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 32,
                    color: AnalyzeColors.textMuted,
                  ),
                  const SizedBox(height: AnalyzeSpacing.md),
                  const Text(
                    'Chưa có hoạt động tuần này',
                    style: TextStyle(
                      fontSize: 14,
                      color: AnalyzeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}