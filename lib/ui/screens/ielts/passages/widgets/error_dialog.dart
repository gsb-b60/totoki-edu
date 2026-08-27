import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onDismiss;
  final VoidCallback onGoBack;
  const ErrorDialog({
    super.key,
    required this.errorMessage,
    required this.onDismiss,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
          const SizedBox(width: 10),
          Text("Loading Error", style: AppTheme.sectionHeaderStyle.copyWith(color: Colors.redAccent, fontSize: 18)),
        ],
      ),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
        child: SingleChildScrollView(
          child: SelectableText(
            errorMessage,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppTheme.lightText, height: 1.5),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text("DISMISS", style: TextStyle(color: AppTheme.greenPrimary)),
        ),
        TextButton(
          onPressed: onGoBack,
          child: const Text("GO BACK", style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }
}