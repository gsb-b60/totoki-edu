import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import '../../notifier/penpal_notifier.dart';

class ResultOverlay extends StatelessWidget {
  final GameStatus status;
  final int friendship;
  final VoidCallback onRestart;
  final VoidCallback onBackToMenu;

  const ResultOverlay({
    super.key,
    required this.status,
    required this.friendship,
    required this.onRestart,
    required this.onBackToMenu,
  });

  @override
  Widget build(BuildContext context) {
    final isWon = status == GameStatus.won;
    final title = isWon ? 'Correspondence Completed' : 'Correspondence Discontinued';
    final subtitle = isWon
        ? 'You have successfully established a lifelong intellectual bond with your penpal friend.'
        : 'Your letters drifted apart. The flow of deep knowledge has ceased.';
    final iconColor = isWon ? AppTheme.greenPrimary : AppTheme.redPrimary;
    final icon = isWon ? Icons.drafts : Icons.mail_lock;

    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 80, color: iconColor),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTheme.heroStyle.copyWith(
                  color: iconColor,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: AppTheme.bodyLargeStyle.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      'Friendship Level',
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$friendship%',
                      style: AppTheme.heroStyle.copyWith(
                        fontSize: 36,
                        color: isWon ? AppTheme.greenPrimary : AppTheme.redPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onRestart,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Start Correspondence Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.sciSpark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: onBackToMenu,
                      icon: const Icon(Icons.menu_book),
                      label: const Text('Return to Mailbox Selection'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}