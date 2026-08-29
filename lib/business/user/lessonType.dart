enum LessonType {
  vocabulary,
  grammar,
  listening,
  speaking,
  reading;

  int get value => index;

  static LessonType fromValue(int value) {
    return LessonType.values[value];
  }
}
