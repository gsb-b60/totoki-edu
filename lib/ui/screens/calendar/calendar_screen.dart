import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/business/calendar/calendar_model.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/calendar/month_view.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarModel>(
      builder: (context, model, child) {
        return Column(
          children: [
            _CalendarHeader(model: model),
            _FormatToggle(model: model),
            const Divider(height: 1, color: AppTheme.darkBorder),
            Expanded(child: _buildBody(model)),
          ],
        );
      },
    );
  }

  Widget _buildBody(CalendarModel model) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (model.format) {
      case CalendarFormat.month:
        return const MonthView();
      case CalendarFormat.week:
        return const Center(
          child: Text(
            'Week View',
            style: TextStyle(color: AppTheme.lightText, fontSize: 18),
          ),
        );
      case CalendarFormat.day:
        return const Center(
          child: Text(
            'Day View',
            style: TextStyle(color: AppTheme.lightText, fontSize: 18),
          ),
        );
    }
  }
}

class _CalendarHeader extends StatelessWidget {
  final CalendarModel model;
  const _CalendarHeader({required this.model});

  @override
  Widget build(BuildContext context) {
    final title = DateFormat('MMMM yyyy').format(model.focusedDay);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: model.goToPrevious,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Expanded(
            child: GestureDetector(
              onTap: model.goToToday,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (model.currentStreak > 0)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${model.currentStreak}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            onPressed: model.goToNext,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _FormatToggle extends StatelessWidget {
  final CalendarModel model;
  const _FormatToggle({required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _ToggleChip(
            label: 'Day',
            selected: model.format == CalendarFormat.day,
            onTap: () => model.setFormat(CalendarFormat.day),
          ),
          const SizedBox(width: 8),
          _ToggleChip(
            label: 'Week',
            selected: model.format == CalendarFormat.week,
            onTap: () => model.setFormat(CalendarFormat.week),
          ),
          const SizedBox(width: 8),
          _ToggleChip(
            label: 'Month',
            selected: model.format == CalendarFormat.month,
            onTap: () => model.setFormat(CalendarFormat.month),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: model.goToToday,
            icon: const Icon(Icons.today, size: 16, color: AppTheme.primaryTeal),
            label: const Text(
              'Today',
              style: TextStyle(color: AppTheme.primaryTeal, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryTeal : AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppTheme.primaryTeal
                : AppTheme.darkBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.lightText.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
