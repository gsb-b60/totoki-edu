import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class ErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onBack;
  final VoidCallback onDismiss;
  const ErrorState({
    super.key,
    required this.errorMessage,
    required this.onBack,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: _buildAppBar(context, onBack),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                "Failed to load passage",
                style: AppTheme.sectionHeaderStyle.copyWith(
                  fontSize: 18,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 300,
                  maxWidth: 400,
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    errorMessage,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: AppTheme.lightText,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text(
                      "DISMISS",
                      style: TextStyle(color: AppTheme.greenPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onBack,
                    child: const Text(
                      "GO BACK",
                      style: TextStyle(color: Colors.redAccent),
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

  AppBar _buildAppBar(BuildContext context, VoidCallback onBack) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppTheme.darkBorder,
          size: 24,
        ),
        onPressed: onBack,
      ),
      title: Text("Reading", style: AppTheme.screenTitleStyle),
      backgroundColor: AppTheme.darkBase,
      elevation: 0,
      centerTitle: true,
    );
  }
}
