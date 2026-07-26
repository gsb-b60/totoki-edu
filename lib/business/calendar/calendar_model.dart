import 'package:flutter/material.dart';
import 'package:totoki_extract/business/calendar/session.dart';
import 'package:totoki_extract/data/database_helper.dart';
import 'package:intl/intl.dart';

enum CalendarFormat { day, week, month }

class CalendarModel extends ChangeNotifier {
  static final _db = DatabaseHelper.instance;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _format = CalendarFormat.month;

  final Map<String, List<Session>> _sessionsByDate = {};
  final Map<String, int> _dailyCardCounts = {};
  int _currentStreak = 0;
  bool _isLoading = false;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  CalendarFormat get format => _format;
  Map<String, List<Session>> get sessionsByDate => _sessionsByDate;
  Map<String, int> get dailyCardCounts => _dailyCardCounts;
  int get currentStreak => _currentStreak;
  bool get isLoading => _isLoading;

  List<Session> get sessionsForSelectedDay {
    if (_selectedDay == null) return [];
    final key = _dateKey(_selectedDay!);
    return _sessionsByDate[key] ?? [];
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([
      _loadMonth(_focusedDay),
      _refreshStreak(),
    ]);
    _isLoading = false;
    notifyListeners();
  }

  void selectDay(DateTime day) {
    _selectedDay = day;
    _focusedDay = day;
    notifyListeners();
  }

  void setFormat(CalendarFormat format) {
    _format = format;
    _loadForCurrentFormat();
  }

  void goToToday() {
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadForCurrentFormat();
  }

  void goToPrevious() {
    switch (_format) {
      case CalendarFormat.month:
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
        break;
      case CalendarFormat.week:
        _focusedDay = _focusedDay.subtract(const Duration(days: 7));
        break;
      case CalendarFormat.day:
        _focusedDay = _focusedDay.subtract(const Duration(days: 1));
        break;
    }
    _loadForCurrentFormat();
  }

  void goToNext() {
    switch (_format) {
      case CalendarFormat.month:
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
        break;
      case CalendarFormat.week:
        _focusedDay = _focusedDay.add(const Duration(days: 7));
        break;
      case CalendarFormat.day:
        _focusedDay = _focusedDay.add(const Duration(days: 1));
        break;
    }
    _loadForCurrentFormat();
  }

  Future<void> _loadForCurrentFormat() async {
    _isLoading = true;
    notifyListeners();
    switch (_format) {
      case CalendarFormat.month:
        await _loadMonth(_focusedDay);
        break;
      case CalendarFormat.week:
        await _loadWeek(_focusedDay);
        break;
      case CalendarFormat.day:
        await _loadDay(_focusedDay);
        break;
    }
    await _refreshStreak();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadMonth(DateTime month) async {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final startKey = _dateKey(first);
    final endKey = _dateKey(last);
    final sessions = await _db.getSessionsForRange(startKey, endKey);
    _indexSessions(sessions);
    final counts = await _db.getDailyCardCounts(month.year);
    _dailyCardCounts
      ..clear()
      ..addAll(counts);
  }

  Future<void> _loadWeek(DateTime day) async {
    final weekday = day.weekday;
    final monday = day.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final sessions = await _db.getSessionsForRange(
      _dateKey(monday),
      _dateKey(sunday),
    );
    _indexSessions(sessions);
  }

  Future<void> _loadDay(DateTime day) async {
    final key = _dateKey(day);
    final sessions = await _db.getSessionsForDate(key);
    _sessionsByDate.clear();
    if (sessions.isNotEmpty) {
      _sessionsByDate[key] = sessions;
    }
  }

  void _indexSessions(List<Session> sessions) {
    _sessionsByDate.clear();
    for (final s in sessions) {
      _sessionsByDate.putIfAbsent(s.date, () => []).add(s);
    }
  }

  Future<void> logSession(Session session) async {
    await _db.insertSession(session);
    final key = session.date;
    _sessionsByDate.putIfAbsent(key, () => []).add(session);
    _dailyCardCounts.update(
      key,
      (v) => v + session.cardsStudied,
      ifAbsent: () => session.cardsStudied,
    );
    await _refreshStreak();
    notifyListeners();
  }

  Future<void> _refreshStreak() async {
    _currentStreak = await _db.getCurrentStreak();
  }

  String _dateKey(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);
}
