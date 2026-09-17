enum LessonType {
  dailyLearn,
  ielts;

  int get value => index;

  static LessonType fromValue(int value) {
    return LessonType.values[value];
  }

  @override
  String toString() {
    switch (this) {
      case LessonType.dailyLearn:
        return 'Daily Learn';
      case LessonType.ielts:
        return 'IELTS';
    }
  }
}
