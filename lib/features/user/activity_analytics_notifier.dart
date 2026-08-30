import 'package:flutter/material.dart';
import 'package:totoki_extract/data/user_database/daily_usage_dao.dart';
import 'package:totoki_extract/data/user_database/user_db_helper.dart';
import 'package:totoki_extract/features/user/analytics_models.dart';

class ActivityAnalyticsNotifier extends ChangeNotifier {
  final DailyUsageDao _dao = DailyUsageDao(UserDatabaseHelper.instance);
  
  int _currentStreak = 0;
  int _longestStreak = 0;
  Map<DateTime, int> _yearActivity = {};
  List<ActivityMonth> _monthlyActivity = [];
  bool _isLoading = false;
  String? _error;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  Map<DateTime, int> get yearActivity => _yearActivity;
  List<ActivityMonth> get monthlyActivity => _monthlyActivity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActivityData(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentStreak = await _dao.getCurrentStreak(userId);
      _longestStreak = await _dao.getLongestStreak(userId);
      _yearActivity = await _dao.getYearActivity(userId);
      _monthlyActivity = await _dao.getMonthlyActivity(userId, DateTime.now().year);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userId) async {
    await loadActivityData(userId);
  }
}