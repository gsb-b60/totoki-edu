import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/features/user/analyze_notifier.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class ActivityCalendarBlock extends StatelessWidget {
  const ActivityCalendarBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyzeNotifier>(
      builder: (context, analyzeNotifier, child) {
        final notifier = analyzeNotifier.activity;
        if (notifier.isLoading) {
          return _buildLoading();
        }

        if (notifier.error != null) {
          return _buildError(notifier.error!);
        }

        if (notifier.yearActivity.isEmpty && notifier.monthlyActivity.isEmpty) {
          return _buildEmpty();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HOẠT ĐỘNG',
                    style: TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to detail
                    },
                    child: const Text(
                      'Xem năm',
                      style: TextStyle(
                        color: AppTheme.bluePrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.local_fire_department,
                      label: 'Streak hiện tại',
                      value: '${notifier.currentStreak} ngày',
                      color: AppTheme.redPrimary,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.emoji_events,
                      label: 'Streak dài nhất',
                      value: '${notifier.longestStreak} ngày',
                      color: AppTheme.yellowPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: notifier.monthlyActivity.length,
                  itemBuilder: (context, index) {
                    final month = notifier.monthlyActivity[index];
                    return _buildMonthColumn(context, month);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightText,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthColumn(BuildContext context, dynamic month) {
    final monthName = _getMonthName(month.month);
    final activeDays = month.activeDays;
    final totalDays = _getDaysInMonth(month.year, month.month);
    final fillRatio = totalDays > 0 ? activeDays / totalDays : 0.0;
    
    // Get color based on activity level
    Color barColor;
    if (fillRatio > 0.7) {
      barColor = AppTheme.greenPrimary;
    } else if (fillRatio > 0.4) {
      barColor = AppTheme.yellowPrimary;
    } else if (fillRatio > 0.1) {
      barColor = AppTheme.bluePrimary;
    } else {
      barColor = Colors.grey[700]!;
    }

    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            monthName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(4, (weekIndex) {
                final weekActivity = _getWeekActivity(month, weekIndex);
                final weekFill = weekActivity / 7.0;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: weekFill > 0.5 
                        ? barColor 
                        : weekFill > 0.2 
                            ? barColor.withValues(alpha: 0.5)
                            : AppTheme.darkBorder,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: weekFill > 0 ? barColor : AppTheme.darkBorder,
                      width: 1,
                    ),
                  ),
                );
              }).reversed.toList(),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '$activeDays/$totalDays',
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

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  String _getMonthName(int month) {
    const names = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];
    return names[month - 1];
  }

  int _getWeekActivity(dynamic month, int weekIndex) {
    // weekIndex 0 = first week, 3 = last week
    int active = 0;
    final startDay = weekIndex * 7 + 1;
    final endDay = (weekIndex + 1) * 7;
    
    for (int day = startDay; day <= endDay; day++) {
      if (month.dayAmounts[day] != null && month.dayAmounts[day]! > 0) {
        active++;
      }
    }
    return active;
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOẠT ĐỘNG',
            style: TextStyle(
              color: AppTheme.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          Row(
            children: [
              Expanded(child: _buildStatCard(
                icon: Icons.local_fire_department,
                label: 'Streak hiện tại',
                value: '...',
                color: AppTheme.redPrimary,
              )),
              const SizedBox(width: 16.0),
              Expanded(child: _buildStatCard(
                icon: Icons.emoji_events,
                label: 'Streak dài nhất',
                value: '...',
                color: AppTheme.yellowPrimary,
              )),
            ],
          ),
          const SizedBox(height: 32.0),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 12,
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
      child: Container(
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
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.calendar_month,
                size: 48,
                color: Colors.white38,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Chưa có hoạt động',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Hãy học mỗi ngày để tạo streak',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}