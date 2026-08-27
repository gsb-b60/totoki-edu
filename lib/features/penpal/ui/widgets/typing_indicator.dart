import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class TypingIndicator extends StatefulWidget {
  final String senderName;

  const TypingIndicator({super.key, required this.senderName});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.senderName} is writing',
                style: AppTheme.bodySmallStyle.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    children: List.generate(3, (index) {
                      final delay = index * 0.15;
                      final value = (_controller.value - delay).clamp(0.0, 1.0);
                      final opacity = (1 - (value * 2 - 1).abs()).clamp(0.3, 1.0);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.sciSpark.withValues(alpha: opacity),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}