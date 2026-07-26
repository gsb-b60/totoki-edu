import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/business/calendar/calendar_model.dart';
import 'package:totoki_extract/business/calendar/session.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/calendar/session_detail_sheet.dart';

const double _hourHeight = 60.0;
const double _leftMargin = 50.0;

class DayView extends StatefulWidget {
  const DayView({super.key});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    final scrollTarget = (now.hour * _hourHeight) +
        (now.minute / 60.0 * _hourHeight) -
        100;
    if (scrollTarget > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            scrollTarget.clamp(0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });

    return Consumer<CalendarModel>(
      builder: (context, model, child) {
        final sessions = model.sessionsForSelectedDay;
        return SingleChildScrollView(
          controller: _scrollController,
          child: SizedBox(
            height: 24 * _hourHeight,
            child: Stack(
              children: [
                ..._buildHourMarkers(),
                if (sessions.isEmpty)
                  Positioned(
                    top: 12 * _hourHeight,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_busy,
                              size: 40,
                              color: AppTheme.lightText.withValues(alpha: 0.2)),
                          const SizedBox(height: 8),
                          Text(
                            'No sessions today',
                            style: TextStyle(
                              color: AppTheme.lightText.withValues(alpha: 0.4),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._buildSessionBlocks(sessions),
                _buildCurrentTimeLine(),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildHourMarkers() {
    final widgets = <Widget>[];
    for (int h = 0; h < 24; h++) {
      final top = h * _hourHeight;
      widgets.add(
        Positioned(
          top: top,
          left: 0,
          right: 0,
          child: SizedBox(
            height: _hourHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _leftMargin,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, right: 8),
                    child: Text(
                      '${h.toString().padLeft(2, '0')}:00',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppTheme.lightText.withValues(alpha: 0.35),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppTheme.darkBorder.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _buildSessionBlocks(List<Session> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final widgets = <Widget>[];

    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final startTime = _sessionStart(session, today);
      final endTime = _sessionEnd(session, today);
      final startMinutes = startTime.hour * 60.0 + startTime.minute;
      final durationMinutes = endTime.difference(startTime).inMinutes.clamp(5, 1440);
      final top = (startMinutes / 60.0) * _hourHeight;
      final height = (durationMinutes / 60.0) * _hourHeight;

      widgets.add(
        Positioned(
          top: top,
          left: _leftMargin + 8,
          right: 8,
          height: height.clamp(24, height),
          child: GestureDetector(
            onTap: () => showSessionDetailSheet(context, session),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${session.cardsStudied} cards',
                    style: const TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (height > 36)
                    Text(
                      '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                      style: TextStyle(
                        color: AppTheme.lightText.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget? _buildCurrentTimeLine() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final minutesSinceMidnight = now.difference(today).inMinutes;
    final top = (minutesSinceMidnight / 60.0) * _hourHeight;

    return Positioned(
      top: top,
      left: _leftMargin,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.redPrimary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: AppTheme.redPrimary,
            ),
          ),
        ],
      ),
    );
  }

  DateTime _sessionStart(Session session, DateTime today) {
    if (session.createdAt != null && session.durationSeconds > 0) {
      return session.createdAt!
          .subtract(Duration(seconds: session.durationSeconds));
    }
    return session.createdAt ?? today;
  }

  DateTime _sessionEnd(Session session, DateTime today) {
    final start = _sessionStart(session, today);
    return start.add(Duration(seconds: session.durationSeconds));
  }

  String _formatTime(DateTime dt) {
    return DateFormat('HH:mm').format(dt);
  }
}
