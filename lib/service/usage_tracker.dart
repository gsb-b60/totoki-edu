import 'package:flutter/material.dart';
import 'package:totoki_extract/data/user_database/daily_usage_dao.dart';
import 'package:totoki_extract/data/user_database/user_db_helper.dart';

class UsageTracker with WidgetsBindingObserver {
  DateTime? _sessionStart;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _sessionStart = DateTime.now();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onResumed();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _onPaused();
        break;

      default:
        break;
    }
  }

  void _onResumed() {
    // Don't create another session if we're already tracking one.
    if (_sessionStart != null) return;

    _sessionStart = DateTime.now();
  }

  Future<void> _onPaused() async {
    if (_sessionStart == null) return;

    final startedAt = _sessionStart!;
    final duration = DateTime.now().difference(startedAt);

    _sessionStart = null;

    if (duration.inSeconds > 0) {
      await saveUsage(
        startedAt: startedAt,
        durationSeconds: duration.inSeconds,
      );
    }
  }

  Future<void> saveUsage({
    required DateTime startedAt,
    required int durationSeconds,
  }) async {
    DailyUsageDao dao = DailyUsageDao(UserDatabaseHelper.instance);
    final minutes = (durationSeconds / 60).ceil();
    await dao.addUsageTime(minutes);
  }
}
