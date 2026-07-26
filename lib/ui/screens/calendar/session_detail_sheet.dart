import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totoki_extract/business/calendar/session.dart';
import 'package:totoki_extract/theme/app_theme.dart';

void showSessionDetailSheet(BuildContext context, Session session) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _SessionDetailSheet(session: session),
  );
}

void showDaySessionsSheet(
    BuildContext context, String dateKey, List<Session> sessions) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _DaySessionsSheet(dateKey: dateKey, sessions: sessions),
  );
}

class _SessionDetailSheet extends StatelessWidget {
  final Session session;
  const _SessionDetailSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: session.durationSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final accPct = (session.accuracy * 100).round();

    String durationStr;
    if (hours > 0) {
      durationStr = '${hours}h ${minutes}m';
    } else {
      durationStr = '${minutes}m';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            session.date,
            style: TextStyle(
              color: AppTheme.lightText.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricTile(
                value: '${session.cardsStudied}',
                label: 'Cards',
                icon: Icons.menu_book,
                color: AppTheme.bluePrimary,
              ),
              const SizedBox(width: 12),
              _MetricTile(
                value: '${session.correctCount}',
                label: 'Correct',
                icon: Icons.check_circle,
                color: AppTheme.greenPrimary,
              ),
              const SizedBox(width: 12),
              _MetricTile(
                value: '${session.wrongCount}',
                label: 'Wrong',
                icon: Icons.cancel,
                color: AppTheme.redPrimary,
              ),
              const SizedBox(width: 12),
              _MetricTile(
                value: durationStr,
                label: 'Duration',
                icon: Icons.timer,
                color: AppTheme.primaryTeal,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Accuracy',
            style: TextStyle(
              color: AppTheme.lightText.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: session.accuracy,
              minHeight: 8,
              backgroundColor: AppTheme.darkBase,
              valueColor: AlwaysStoppedAnimation<Color>(
                accPct >= 80
                    ? AppTheme.greenPrimary
                    : accPct >= 50
                        ? AppTheme.yellowPrimary
                        : AppTheme.redPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$accPct%',
              style: TextStyle(
                color: accPct >= 80
                    ? AppTheme.greenPrimary
                    : accPct >= 50
                        ? AppTheme.yellowPrimary
                        : AppTheme.redPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (session.studyMode != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.sports_esports,
                    size: 14,
                    color: AppTheme.lightText.withValues(alpha: 0.5)),
                const SizedBox(width: 6),
                Text(
                  'Mode: ${session.studyMode}',
                  style: TextStyle(
                    color: AppTheme.lightText.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DaySessionsSheet extends StatelessWidget {
  final String dateKey;
  final List<Session> sessions;
  const _DaySessionsSheet({
    required this.dateKey,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMMM d, yyyy')
        .format(DateTime.parse(dateKey));
    final totalCards =
        sessions.fold(0, (sum, s) => sum + s.cardsStudied);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            dateStr,
            style: const TextStyle(
              color: AppTheme.lightText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalCards cards studied across ${sessions.length} session${sessions.length > 1 ? 's' : ''}',
            style: TextStyle(
              color: AppTheme.lightText.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ...sessions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MiniSessionCard(session: s),
              )),
        ],
      ),
    );
  }
}

class _MiniSessionCard extends StatelessWidget {
  final Session session;
  const _MiniSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final accPct = (session.accuracy * 100).round();
    final duration = Duration(seconds: session.durationSeconds);
    final minutes = duration.inMinutes;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${session.cardsStudied} cards',
                      style: const TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (session.studyMode != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          session.studyMode!,
                          style: const TextStyle(
                            color: AppTheme.primaryTeal,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 12, color: AppTheme.greenPrimary),
                    const SizedBox(width: 3),
                    Text(
                      '${session.correctCount}',
                      style: TextStyle(
                          color: AppTheme.greenPrimary, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.cancel,
                        size: 12, color: AppTheme.redPrimary),
                    const SizedBox(width: 3),
                    Text(
                      '${session.wrongCount}',
                      style:
                          TextStyle(color: AppTheme.redPrimary, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.timer,
                        size: 12,
                        color: AppTheme.lightText.withValues(alpha: 0.5)),
                    const SizedBox(width: 3),
                    Text(
                      '${minutes}m',
                      style: TextStyle(
                        color: AppTheme.lightText.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '$accPct%',
            style: TextStyle(
              color: accPct >= 80
                  ? AppTheme.greenPrimary
                  : accPct >= 50
                      ? AppTheme.yellowPrimary
                      : AppTheme.redPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.darkBase,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.lightText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.lightText.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
