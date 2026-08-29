import 'package:totoki_extract/business/user/lessonType.dart';

class HistoryLesson {
  final int? id;
  final String userId;
  final LessonType lessonType;
  final int? accuracy;
  final int? timeSpent;

  HistoryLesson({
    this.id,
    required this.userId,
    required this.lessonType,
    this.accuracy,
    this.timeSpent,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'lesson_type': lessonType.value,
      'accuracy': accuracy,
      'time_spent': timeSpent,
    };
  }

  factory HistoryLesson.fromMap(Map<String, dynamic> map) {
    return HistoryLesson(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      lessonType: LessonType.fromValue(map['lesson_type'] as int),
      accuracy: map['accuracy'] as int?,
      timeSpent: map['time_spent'] as int?,
    );
  }
}