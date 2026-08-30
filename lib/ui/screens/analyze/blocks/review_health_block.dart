import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:totoki_extract/features/user/analyze_notifier.dart';
import 'package:totoki_extract/ui/screens/analyze/analyze_constants.dart';

class ReviewHealthBlock extends StatelessWidget {
  const ReviewHealthBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyzeNotifier>(
      builder: (context, analyzeNotifier, child) {
        final notifier = analyzeNotifier.card;
        if (notifier.isLoading) {
          return _buildLoading();
        }

        if (notifier.error != null) {
          return _buildError(notifier.error!);
        }

        final stats = notifier.reviewStats;
        if (stats == null) {
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
                    'SỨC KHỎE ÔN TẬP',
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tỷ lệ thành công',
                          style: TextStyle(
                            fontSize: 11,
                            color: AnalyzeColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AnalyzeSpacing.xs),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              stats.successRate.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AnalyzeColors.greenPrimary,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: AnalyzeSpacing.xs),
                            const Text(
                              '%',
                              style: TextStyle(
                                fontSize: 14,
                                color: AnalyzeColors.greenPrimary,
                              ),
                            ),
                            const SizedBox(width: AnalyzeSpacing.md),
                            if (stats.trend != 0) ...[
                              Icon(
                                stats.trend > 0 ? Icons.trending_up : Icons.trending_down,
                                size: 18,
                                color: stats.trend > 0 ? AnalyzeColors.greenPrimary : AnalyzeColors.redPrimary,
                              ),
                              Text(
                                '${stats.trend.abs().toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: stats.trend > 0 ? AnalyzeColors.greenPrimary : AnalyzeColors.redPrimary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AnalyzeSpacing.xl),
              Container(
                height: 80,
                padding: const EdgeInsets.all(AnalyzeSpacing.md),
                decoration: BoxDecoration(
                  color: AnalyzeColors.bgCard,
                  borderRadius: BorderRadius.circular(AnalyzeSpacing.md),
                  border: Border.all(color: AnalyzeColors.borderLight),
                ),
                child: _buildSparkline(stats.dailyRates),
              ),
              const SizedBox(height: AnalyzeSpacing.lg),
              if (notifier.leechCards.isNotEmpty) ...[
                const Text(
                  'THẺ KHÓ (CẦN ÔN LẠI)',
                  style: TextStyle(
                    fontSize: 11,
                    color: AnalyzeColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AnalyzeSpacing.md),
                ...notifier.leechCards.map((card) => _buildLeechCard(card)).toList(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSparkline(List<double> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu',
          style: TextStyle(fontSize: 12, color: AnalyzeColors.textMuted),
        ),
      );
    }

    // Take last 7 data points for weekly view
    final weeklyData = data.length > 7 ? data.sublist(data.length - 7) : data;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        minX: 0,
        maxX: (weeklyData.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: weeklyData.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AnalyzeColors.greenPrimary.withValues(alpha: 0.8),
                AnalyzeColors.greenPrimary,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AnalyzeColors.greenPrimary.withValues(alpha: 0.2),
                  AnalyzeColors.greenPrimary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeechCard(dynamic card) {
    return Container(
      margin: const EdgeInsets.only(bottom: AnalyzeSpacing.sm),
      padding: const EdgeInsets.all(AnalyzeSpacing.md),
      decoration: BoxDecoration(
        color: AnalyzeColors.bgCard,
        borderRadius: BorderRadius.circular(AnalyzeSpacing.md),
        border: Border.all(color: AnalyzeColors.redPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.word,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AnalyzeColors.textPrimary,
                  ),
                ),
                Text(
                  'Thất bại ${card.failCount} lần • Ease: ${card.easeFactor.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AnalyzeColors.redPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AnalyzeColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AnalyzeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SỨC KHỎE ÔN TẬP',
            style: TextStyle(
              color: AnalyzeColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AnalyzeSpacing.lg),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: AnalyzeColors.bgSecondary,
              borderRadius: BorderRadius.circular(AnalyzeSpacing.md),
            ),
          ),
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
                Icons.analytics,
                size: 48,
                color: AnalyzeColors.textMuted,
              ),
              const SizedBox(height: AnalyzeSpacing.md),
              const Text(
                'Chưa có dữ liệu ôn tập',
                style: TextStyle(
                  fontSize: 14,
                  color: AnalyzeColors.textSecondary,
                ),
              ),
              const SizedBox(height: AnalyzeSpacing.xs),
              const Text(
                'Hãy ôn tập thẻ để xem thống kê',
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