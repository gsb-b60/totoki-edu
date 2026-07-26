import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/business/calendar/calendar_model.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/calendar/session_detail_sheet.dart';

class MonthView extends StatelessWidget {
  const MonthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarModel>(
      builder: (context, model, child) {
        return TableCalendar(
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2030, 12, 31),
          focusedDay: model.focusedDay,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          selectedDayPredicate: (day) =>
              isSameDay(model.selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            model.selectDay(selectedDay);
            final key = DateFormat('yyyy-MM-dd').format(selectedDay);
            final sessions = model.sessionsByDate[key];
            if (sessions != null && sessions.isNotEmpty) {
              showDaySessionsSheet(context, key, sessions);
            }
          },
          onPageChanged: (focusedDay) {
            model.selectDay(focusedDay);
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) =>
                _buildDayCell(context, day, model),
            selectedBuilder: (context, day, focusedDay) =>
                _buildDayCell(context, day, model, selected: true),
            todayBuilder: (context, day, focusedDay) =>
                _buildDayCell(context, day, model, today: true),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleVisible: false,
            leftChevronVisible: false,
            rightChevronVisible: false,
          ),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: true,
            cellMargin: EdgeInsets.all(2),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: AppTheme.lightText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            weekendStyle: TextStyle(
              color: AppTheme.lightText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    CalendarModel model, {
    bool selected = false,
    bool today = false,
  }) {
    final key = DateFormat('yyyy-MM-dd').format(day);
    final count = model.dailyCardCounts[key] ?? 0;
    final isOutsideMonth = day.month != model.focusedDay.month;

    Color bgColor = Colors.transparent;
    if (selected) {
      bgColor = AppTheme.primaryTeal.withValues(alpha: 0.35);
    } else if (today) {
      bgColor = AppTheme.primaryTeal.withValues(alpha: 0.15);
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: isOutsideMonth
                  ? AppTheme.lightText.withValues(alpha: 0.3)
                  : AppTheme.lightText,
              fontSize: 13,
              fontWeight: today ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (count > 0)
            Container(
              width: 6 + (count.clamp(0, 50) / 50.0 * 10),
              height: 4,
              decoration: BoxDecoration(
                color: _heatColor(count),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Color _heatColor(int count) {
    if (count >= 30) return AppTheme.greenPrimary;
    if (count >= 15) return AppTheme.greenBright;
    if (count >= 5) return AppTheme.greenMuted;
    return AppTheme.greenMuted.withValues(alpha: 0.5);
  }
}
