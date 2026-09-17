import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onBack;
  const EmptyState({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: _buildAppBar(context, onBack),
      body: const Center(
        child: Text("No content available.", style: TextStyle(color: AppTheme.darkBorder)),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, VoidCallback onBack) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder, size: 24),
        onPressed: onBack,
      ),
      title: Text("Reading", style: AppTheme.screenTitleStyle),
      backgroundColor: AppTheme.darkBase,
      elevation: 0,
      centerTitle: true,
    );
  }
}