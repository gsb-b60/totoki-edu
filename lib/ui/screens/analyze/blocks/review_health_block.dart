import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:totoki_extract/features/user/analyze_notifier.dart';
import 'package:totoki_extract/theme/app_theme.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SỨC KHỎE ÔN TẬP',
                    style: TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     // Navigate to detail
                  //   },
                  //   child: const Text(
                  //     'Xem chi tiết',
                  //     style: TextStyle(
                  //       color: AppTheme.bluePrimary,
                  //       fontSize: 11,
                  //       fontWeight: FontWeight.w600,
                  //       letterSpacing: 0.5,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tỷ lệ thành công',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              stats.successRate.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.greenPrimary,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            const Text(
                              '%',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.greenPrimary,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            if (stats.trend != 0) ...[
                              Icon(
                                stats.trend > 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                size: 18,
                                color: stats.trend > 0
                                    ? AppTheme.greenPrimary
                                    : AppTheme.redPrimary,
                              ),
                              Text(
                                '${stats.trend.abs().toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: stats.trend > 0
                                      ? AppTheme.greenPrimary
                                      : AppTheme.redPrimary,
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
              const SizedBox(height: 32.0),
              Container(
                height: 80,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: _buildSparkline(stats.dailyRates),
              ),
              const SizedBox(height: 24.0),
              if (notifier.leechCards.isNotEmpty) ...[
                const Text(
                  'THẺ KHÓ (CẦN ÔN LẠI)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12.0),
                ...notifier.leechCards
                    .map((card) => _buildLeechCard(card))
                    .toList(),
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
          style: TextStyle(fontSize: 12, color: Colors.white),
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
                AppTheme.greenPrimary.withValues(alpha: 0.8),
                AppTheme.greenPrimary,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.greenPrimary.withValues(alpha: 0.2),
                  AppTheme.greenPrimary.withValues(alpha: 0.0),
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
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.redPrimary.withValues(alpha: 0.3)),
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
                    color: AppTheme.lightText,
                  ),
                ),
                Text(
                  'Thất bại ${card.failCount} lần • Ease: ${card.easeFactor.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.redPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white38, size: 20),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SỨC KHỎE ÔN TẬP',
            style: TextStyle(
              color: AppTheme.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(16.0),
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
          color: AppTheme.darkBase,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: const Text(
          'Không thể tải dữ liệu',
          style: TextStyle(fontSize: 14, color: AppTheme.redPrimary),
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
              Icon(Icons.analytics, size: 48, color: Colors.white38),
              const SizedBox(height: 16.0),
              const Text(
                'Chưa có dữ liệu ôn tập',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Hãy ôn tập thẻ để xem thống kê',
                style: TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
