import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class IeltsCard extends StatelessWidget {
  const IeltsCard({
    super.key,
    required this.co,
    required this.line,
    required this.aPath,
    this.onTap,
  });

  final Color co;
  final String line;
  final String aPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 120,
      child: GestureDetector(
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$line — coming soon"),
              backgroundColor: co,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: co,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (aPath.isNotEmpty)
                Positioned(
                  right: -20,
                  top: -20,
                  bottom: -20,
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      aPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    line.toUpperCase(),
                    style: AppTheme.sectionHeaderStyle.copyWith(
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [
                        const Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
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
