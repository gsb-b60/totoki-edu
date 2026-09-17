import 'package:totoki_extract/business/user/lesson_type.dart';

class LessonStats {
  final LessonType type;
  final int sessions;
  final double accuracy;
  final int totalMinutes;
  final double trend;

  LessonStats({
    required this.type,
    required this.sessions,
    required this.accuracy,
    required this.totalMinutes,
    required this.trend,
  });

  double get averageAccuracy => sessions > 0 ? accuracy / sessions : 0.0;
}

class DailyLessonAggregate {
  final DateTime date;
  final Map<LessonType, int> minutesByType;

  DailyLessonAggregate({
    required this.date,
    required this.minutesByType,
  });
}

class CardReviewStats {
  final double successRate;
  final double trend;
  final List<double> dailyRates;

  CardReviewStats({
    required this.successRate,
    required this.trend,
    required this.dailyRates,
  });
}

class LeechCard {
  final int cardId;
  final String word;
  final int failCount;
  final double easeFactor;

  LeechCard({
    required this.cardId,
    required this.word,
    required this.failCount,
    required this.easeFactor,
  });
}

class ActivityMonth {
  final int year;
  final int month;
  final int activeDays;
  final Map<int, int> dayAmounts;

  ActivityMonth({
    required this.year,
    required this.month,
    required this.activeDays,
    required this.dayAmounts,
  });
}