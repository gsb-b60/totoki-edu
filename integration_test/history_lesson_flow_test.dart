import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totoki_extract/business/user/history_lesson.dart';
import 'package:totoki_extract/business/user/lesson_type.dart';
import 'package:totoki_extract/data/user_database/history_lesson_dao.dart';
import 'package:totoki_extract/data/user_database/user_dao.dart';
import 'package:totoki_extract/data/user_database/user_db_helper.dart';
import 'package:totoki_extract/main.dart' as app;

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('lesson history: empty state, saved row, detail modal', (tester) async {
    SharedPreferences.setMockInitialValues({'onboardingCompleted': true});

    app.main();
    await _settle(tester);

    final db = await UserDatabaseHelper.instance.database;
    await db.delete('history_lesson');

    final userDao = UserDao(UserDatabaseHelper.instance);
    var user = await userDao.getCurrentUser();
    user ??= await userDao.createLocalUser();
    final userId = user.id;

    await tester.tap(find.byIcon(Icons.menu));
    await _settle(tester);

    await tester.tap(find.text('Lesson History'));
    await _settle(tester);

    expect(find.text('No lesson history found'), findsOneWidget);

    await tester.pageBack();
    await _settle(tester);

    await HistoryLessonDao(UserDatabaseHelper.instance).insertHistoryLesson(
      HistoryLesson(
        userId: userId,
        lessonType: LessonType.dailyLearn,
        accuracy: 90,
        timeSpent: 72,
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await _settle(tester);

    await tester.tap(find.text('Lesson History'));
    await _settle(tester);

    expect(find.text('Daily Learn'), findsOneWidget);
    expect(find.text('Accuracy: 90% | Time: 72s'), findsOneWidget);

    await tester.tap(find.text('Daily Learn'));
    await _settle(tester);

    expect(find.text('Lesson Detail'), findsOneWidget);
    expect(find.text('90%'), findsWidgets);
    expect(find.text('72s'), findsWidgets);

    await tester.tap(find.text('Close'));
    await _settle(tester);

    expect(find.text('Lesson Detail'), findsNothing);
    expect(find.text('Daily Learn'), findsOneWidget);
  });
}