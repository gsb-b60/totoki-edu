import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/ui/screens/analyze/analyze_constants.dart';

class TodayPulseBlock extends StatelessWidget {
  const TodayPulseBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Cardmodel>(
      builder: (context, cardModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AnalyzeSpacing.md),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AnalyzeSpacing.xl),
            decoration: BoxDecoration(
              color: AnalyzeColors.bgCard,
              borderRadius: BorderRadius.circular(AnalyzeSpacing.xl),
              border: Border.all(
                color: AnalyzeColors.greenPrimary.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HÔM NAY',
                          style: const TextStyle(
                            color: AnalyzeColors.greenPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: AnalyzeSpacing.xs),
                        Text(
                          cardModel.dueCount.toString(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AnalyzeColors.greenPrimary,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'thẻ đến hạn',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AnalyzeColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AnalyzeSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/learn');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AnalyzeColors.greenPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AnalyzeSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AnalyzeSpacing.md),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'BẮT ĐẦU HÔM NAY',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}