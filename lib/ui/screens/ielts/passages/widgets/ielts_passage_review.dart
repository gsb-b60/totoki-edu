import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/features/ielts/models/review_item.dart';
import 'review_question_card.dart';

class IeltsPassageReview extends StatelessWidget {
  final List<ReviewItem> items;
  final VoidCallback onContinue;
  final VoidCallback? onRetry;

  const IeltsPassageReview({
    super.key,
    required this.items,
    required this.onContinue,
    this.onRetry,
  });

  int get correctCount => items.where((i) => i.isCorrect).length;
  int get totalCount => items.length;
  double get scorePercent => totalCount > 0 ? correctCount / totalCount : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review', style: AppTheme.screenTitleStyle),
            Text(
              '$correctCount / $totalCount correct  (${(scorePercent * 100).toStringAsFixed(0)}%)',
              style: AppTheme.bodySmallStyle.copyWith(
                color: correctCount == totalCount
                    ? AppTheme.greenPrimary
                    : AppTheme.lightText.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.darkBase,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.lightText, size: 28),
          onPressed: onRetry,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ReviewQuestionCard(item: item),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onRetry != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.lightText,
                      side: BorderSide(color: AppTheme.darkBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'RETRY',
                      style: AppTheme.bodyLargeStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: AppTheme.greenPrimary,
                  ),
                  child: Text(
                    'CONTINUE',
                    style: AppTheme.bodyLargeStyle.copyWith(
                      color: AppTheme.darkBase,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
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