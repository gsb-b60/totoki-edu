import 'package:flutter/material.dart';
import 'package:totoki_extract/data/user_database/card_history_dao.dart';
import 'package:totoki_extract/data/user_database/user_db_helper.dart';
import 'package:totoki_extract/features/user/analytics_models.dart';

class CardAnalyticsNotifier extends ChangeNotifier {
  final CardHistoryDao _dao = CardHistoryDao(UserDatabaseHelper.instance);
  
  CardReviewStats? _reviewStats;
  List<LeechCard> _leechCards = [];
  bool _isLoading = false;
  String? _error;

  CardReviewStats? get reviewStats => _reviewStats;
  List<LeechCard> get leechCards => _leechCards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReviewStats(String userId, {int days = 30}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviewStats = await _dao.getReviewStats(userId, days: days);
      _leechCards = await _dao.getLeechCards(userId, 3);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userId) async {
    await loadReviewStats(userId);
  }
}