import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/business/calendar/calendar_model.dart';
import 'package:totoki_extract/business/calendar/session.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class WeekView extends StatelessWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarModel>(
      builder: (context, model, child) {
        final weekDays = _getWeekDays(model.focusedDay);
        return Column(
          children: [
            _WeekHeader(weekDays: weekDays, model: model),
            const Divider(height: 1, color: AppTheme.darkBorder),
            Expanded(
              child: _WeekSessionList(weekDays: weekDays, model: model),
            ),
          ],
        );
      },
    );
  }

  List<DateTime> _getWeekDays(DateTime focusedDay) {
    final weekday = focusedDay.weekday;
    final monday = focusedDay.subtract(Duration(days: weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }
}

class _WeekHeader extends StatelessWidget {
  final List<DateTime> weekDays;
  final CalendarModel model;

  const _WeekHeader({required this.weekDays, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: weekDays.map((day) {
          final key = DateFormat('yyyy-MM-dd').format(day);
          final count = model.dailyCardCounts[key] ?? 0;
          final isToday = isSameDay(day, DateTime.now());
          final isSelected = isSameDay(day, model.selectedDay);
          final dayName = DateFormat('E').format(day).substring(0, 3);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                model.selectDay(day);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryTeal.withValues(alpha: 0.25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        color: AppTheme.lightText.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isToday ? AppTheme.primaryTeal : AppTheme.lightText,
                        fontSize: 16,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (count > 0)
                      Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.greenPrimary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    else
                      const SizedBox(height: 3),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _WeekSessionList extends StatelessWidget {
  final List<DateTime> weekDays;
  final CalendarModel model;

  const _WeekSessionList({required this.weekDays, required this.model});

  @override
  Widget build(BuildContext context) {
    final sessions = <Session>[];
    for (final day in weekDays) {
      final key = DateFormat('yyyy-MM-dd').format(day);
      final daySessions = model.sessionsByDate[key] ?? [];
      sessions.addAll(daySessions);
    }

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy,
                size: 48,
                color: AppTheme.lightText.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text(
              'No study sessions this week',
              style: TextStyle(
                color: AppTheme.lightText.withValues(alpha: 0.4),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final session = sessions[index];
        final dateStr = DateFormat('EEE, MMM d').format(
          DateTime.parse(session.date),
        );
        return _SessionCard(session: session, dateStr: dateStr);
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Session session;
  final String dateStr;

  const _SessionCard({required this.session, required this.dateStr});

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: session.durationSeconds);
    final minutes = duration.inMinutes;
    final accPct = (session.accuracy * 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    color: AppTheme.lightText.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.cardsStudied} cards studied',
                  style: const TextStyle(
                    color: AppTheme.lightText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _StatBadge(
                      icon: Icons.check_circle,
                      label: '${session.correctCount}',
                      color: AppTheme.greenPrimary,
                    ),
                    const SizedBox(width: 8),
                    _StatBadge(
                      icon: Icons.cancel,
                      label: '${session.wrongCount}',
                      color: AppTheme.redPrimary,
                    ),
                    const SizedBox(width: 8),
                    _StatBadge(
                      icon: Icons.timer,
                      label: '${minutes}m',
                      color: AppTheme.bluePrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accPct >= 80
                  ? AppTheme.greenPrimary.withValues(alpha: 0.15)
                  : accPct >= 50
                      ? AppTheme.yellowPrimary.withValues(alpha: 0.15)
                      : AppTheme.redPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$accPct%',
              style: TextStyle(
                color: accPct >= 80
                    ? AppTheme.greenPrimary
                    : accPct >= 50
                        ? AppTheme.yellowPrimary
                        : AppTheme.redPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
