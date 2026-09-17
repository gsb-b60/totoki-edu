import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/checkbox_widget.dart';

void main() {
  group('CheckboxWidget', () {
    Widget wrap(Widget child) =>
        MaterialApp(home: Scaffold(body: SizedBox(height: 600, child: child)));

    testWidgets('renders question and options', (tester) async {
      await tester.pumpWidget(wrap(CheckboxWidget(
        questionText: 'Which are mentioned?',
        options: const ['Alpha', 'Beta'],
        selected: const [null, null],
        quantity: 2,
        answered: false,
        questionIndex: 3,
        totalQuestions: 10,
        onSelect: (_, __) {},
      )));

      expect(find.text('Question 3/10'), findsOneWidget);
      expect(find.text('Which are mentioned?'), findsOneWidget);
      expect(find.textContaining('Alpha'), findsOneWidget);
      expect(find.textContaining('Beta'), findsOneWidget);
    });

    testWidgets('tapping an option reports the selection', (tester) async {
      int? slot;
      int? option;
      await tester.pumpWidget(wrap(CheckboxWidget(
        questionText: 'Choose',
        options: const ['One', 'Two'],
        selected: const [null, null],
        quantity: 2,
        answered: false,
        questionIndex: 1,
        totalQuestions: 1,
        onSelect: (s, o) {
          slot = s;
          option = o;
        },
      )));

      await tester.tap(find.textContaining('One'));
      expect(slot, 0);
      expect(option, 0);
    });

    testWidgets('buildReview highlights correct and missed answers',
        (tester) async {
      await tester.pumpWidget(wrap(Column(
        children: [
          CheckboxWidget.buildReview(
            questionText: 'Which are correct?',
            options: const ['Right', 'Wrong'],
            userSelected: const [1],
            correctAnswers: const [0],
            quantity: 1,
          ),
        ],
      )));

      expect(find.textContaining('Right'), findsOneWidget);
      expect(find.textContaining('Wrong'), findsOneWidget);
      // The missed correct answer is flagged.
      expect(find.text('MISSED'), findsOneWidget);
    });
  });
}
