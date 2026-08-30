import 'package:flutter/material.dart';
import 'package:totoki_extract/features/user/lesson_analytics_notifier.dart';
import 'package:totoki_extract/features/user/card_analytics_notifier.dart';
import 'package:totoki_extract/features/user/activity_analytics_notifier.dart';

class AnalyzeNotifier extends ChangeNotifier {
  final LessonAnalyticsNotifier _lessonNotifier = LessonAnalyticsNotifier();
  final CardAnalyticsNotifier _cardNotifier = CardAnalyticsNotifier();
  final ActivityAnalyticsNotifier _activityNotifier = ActivityAnalyticsNotifier();
  
  bool _isLoading = false;
  String? _error;

  LessonAnalyticsNotifier get lesson => _lessonNotifier;
  CardAnalyticsNotifier get card => _cardNotifier;
  ActivityAnalyticsNotifier get activity => _activityNotifier;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAll(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _lessonNotifier.loadLessonStats(userId),
        _cardNotifier.loadReviewStats(userId),
        _activityNotifier.loadActivityData(userId),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userId) async {
    await loadAll(userId);
  }

  @override
  void dispose() {
    _lessonNotifier.dispose();
    _cardNotifier.dispose();
    _activityNotifier.dispose();
    super.dispose();
  }
}