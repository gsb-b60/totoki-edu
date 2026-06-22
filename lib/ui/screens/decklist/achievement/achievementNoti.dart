import 'package:flutter/material.dart';
import 'package:totoki_extract/business/flashcard/Flashcard.dart';
import 'package:totoki_extract/data/database_helper.dart';

class Achievementnoti extends ChangeNotifier {
  static final _dbhelper = DatabaseHelper.instance;
  static const int pageSize = 20;

  final List<Flashcard> _cards = [];
  int _currentPage = 1;
  int _totalCards = 0;
  int _totalPages = 1;
  bool isLoading = false;

  int get currentPage => _currentPage;
  int get totalCards => _totalCards;
  int get totalPages => _totalPages;
  bool get hasNext => _currentPage < _totalPages;
  bool get hasPrev => _currentPage > 1;

  List<Flashcard> getCards() => _cards;

  Future<void> fetchPage(int page) async {
    isLoading = true;
    notifyListeners();
    final total = await _dbhelper.getCardCount();
    _totalCards = total;
    _totalPages = (total / pageSize).ceil().clamp(1, 999999);
    _currentPage = page.clamp(1, _totalPages);
    final data = await _dbhelper.getCardPage(_currentPage, pageSize);
    _cards
      ..clear()
      ..addAll(data);
    isLoading = false;
    notifyListeners();
  }

  Future<void> nextPage() async {
    if (hasNext) await fetchPage(_currentPage + 1);
  }

  Future<void> prevPage() async {
    if (hasPrev) await fetchPage(_currentPage - 1);
  }

  Future<void> fetchCard() async {
    await fetchPage(1);
  }
}
