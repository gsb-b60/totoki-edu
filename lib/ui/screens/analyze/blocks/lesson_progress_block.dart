import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/features/user/analyze_notifier.dart';
import 'package:totoki_extract/features/user/analytics_models.dart';
import 'package:totoki_extract/business/user/lessonType.dart';
import 'package:totoki_extract/ui/screens/analyze/analyze_constants.dart';

class LessonProgressBlock extends StatelessWidget {
  const LessonProgressBlock({super.key});

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

        if (notifier.lessonStats.isEmpty) {
          return _buildEmpty();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AnalyzeSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TIẾN ĐỘ BÀI HỌC',
                    style: TextStyle(
                      color: AnalyzeColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to detail
                    },
                    child: const Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        color: AnalyzeColors.bluePrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AnalyzeSpacing.lg),
              ...LessonType.values.map((type) {
                final stats = notifier.lessonStats[type];
                return _buildLessonRow(type, stats);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLessonRow(LessonType type, LessonStats? stats) {
    final color = AnalyzeColors.lessonColor(type);
    final label = _getLabel(type);
    final progress = stats?.averageAccuracy ?? 0.0;
    final trend = stats?.trend ?? 0.0;
    final sessions = stats?.sessions ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AnalyzeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AnalyzeColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  if (trend != 0) ...[
                    Icon(
                      trend > 0 ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: trend > 0 ? AnalyzeColors.greenPrimary : AnalyzeColors.redPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trend.abs().toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: trend > 0 ? AnalyzeColors.greenPrimary : AnalyzeColors.redPrimary,
                      ),
                    ),
                    const SizedBox(width: AnalyzeSpacing.sm),
                  ],
                  Text(
                    '$sessions sessions',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AnalyzeColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AnalyzeSpacing.sm),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AnalyzeColors.borderLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (progress / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AnalyzeSpacing.xs),
          Text(
            '${progress.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getLabel(LessonType type) {
    switch (type) {
      case LessonType.dailyLearn:
        return 'Học mỗi ngày';
      case LessonType.ielts:
        return 'IELTS';
    }
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AnalyzeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TIẾN ĐỘ BÀI HỌC',
            style: TextStyle(
              color: AnalyzeColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AnalyzeSpacing.lg),
          ...List.generate(2, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AnalyzeSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AnalyzeColors.bgSecondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AnalyzeSpacing.sm),
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AnalyzeColors.bgSecondary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AnalyzeSpacing.md),
      child: Container(
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
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AnalyzeSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AnalyzeSpacing.xl),
        decoration: BoxDecoration(
          color: AnalyzeColors.bgCard,
          borderRadius: BorderRadius.circular(AnalyzeSpacing.md),
          border: Border.all(color: AnalyzeColors.borderLight),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.school,
                size: 48,
                color: AnalyzeColors.textMuted,
              ),
              const SizedBox(height: AnalyzeSpacing.md),
              const Text(
                'Chưa có dữ liệu bài học',
                style: TextStyle(
                  fontSize: 14,
                  color: AnalyzeColors.textSecondary,
                ),
              ),
              const SizedBox(height: AnalyzeSpacing.xs),
              const Text(
                'Hãy bắt đầu học để xem tiến độ',
                style: TextStyle(
                  fontSize: 11,
                  color: AnalyzeColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}