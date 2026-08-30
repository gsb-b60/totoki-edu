import 'package:flutter/material.dart';
import 'package:totoki_extract/data/user_database/history_lesson_dao.dart';
import 'package:totoki_extract/data/user_database/user_db_helper.dart';
import 'package:totoki_extract/features/user/analytics_models.dart';
import 'package:totoki_extract/business/user/lessonType.dart';

class LessonAnalyticsNotifier extends ChangeNotifier {
  final HistoryLessonDao _dao = HistoryLessonDao(UserDatabaseHelper.instance);
  
  Map<LessonType, LessonStats> _lessonStats = {};
  List<DailyLessonAggregate> _weeklyTrend = [];
  bool _isLoading = false;
  String? _error;

  Map<LessonType, LessonStats> get lessonStats => _lessonStats;
  List<DailyLessonAggregate> get weeklyTrend => _weeklyTrend;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLessonStats(String userId, {int days = 30}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lessonStats = await _dao.getLessonStats(userId, days: days);
      _weeklyTrend = await _dao.getDailyLessonTrend(userId, 7);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userId) async {
    await loadLessonStats(userId);
  }
}