import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/features/user/analyze_notifier.dart';
import 'package:totoki_extract/features/user/analytics_models.dart';
import 'package:totoki_extract/business/user/lessonType.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class WeeklyLessonBlock extends StatelessWidget {
  const WeeklyLessonBlock({super.key});

  static Color _lessonColor(LessonType t) => switch (t) {
    LessonType.dailyLearn => AppTheme.primaryTeal,
    LessonType.ielts => AppTheme.bluePrimary,
  };

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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TUẦN NÀY',
                style: TextStyle(
                  color: AppTheme.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24.0),
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
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isToday ? AppTheme.greenPrimary.withValues(alpha: 0.1) : AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16.0),
        border: isToday
            ? Border.all(color: AppTheme.greenPrimary, width: 2)
            : Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isToday ? AppTheme.greenPrimary : Colors.white38,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: LessonType.values.map((type) {
                final minutes = day.minutesByType[type] ?? 0;
                return _buildLessonPill(type, minutes);
              }).toList(),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '${_totalMinutes(day)}m',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonPill(LessonType type, int minutes) {
    final color = _lessonColor(type);
    final initial = _getInitial(type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: minutes > 0 ? color.withValues(alpha: 0.15) : AppTheme.darkBorder,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$initial${minutes > 0 ? minutes : ''}',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: minutes > 0 ? color : Colors.white38,
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TUẦN NÀY',
            style: TextStyle(
              color: AppTheme.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                return Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(16.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TUẦN NÀY',
            style: TextStyle(
              color: AppTheme.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: const Text(
              'Không thể tải dữ liệu',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.redPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TUẦN NÀY',
            style: TextStyle(
              color: AppTheme.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          Container(
            height: 120,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 32,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Chưa có hoạt động tuần này',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
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