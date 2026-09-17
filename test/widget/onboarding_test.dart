import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totoki_extract/main.dart';
import 'package:totoki_extract/ui/screens/onboarding/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingScreen', () {
    testWidgets('renders the first welcome page', (tester) async {
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(onComplete: () => completed = true),
        ),
      );

      expect(find.text('Welcome to Totoki!'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(completed, isFalse);
    });

    testWidgets('walks through all four pages with Next', (tester) async {
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(onComplete: () => completed = true),
        ),
      );

      const pageTitles = [
        'Welcome to Totoki!',
        'Create & Import Decks',
        'Interactive Study Modes',
        'Ready to Start?',
      ];

      for (var i = 0; i < pageTitles.length; i++) {
        expect(find.text(pageTitles[i]), findsOneWidget,
            reason: 'page $i should be visible');
        if (i < pageTitles.length - 1) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
        }
      }

      // On the last page the button becomes "Get Started".
      expect(find.text('Get Started'), findsOneWidget);
      expect(completed, isFalse);
    });

    testWidgets('Get Started completes onboarding and calls onComplete',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(onComplete: () => completed = true),
        ),
      );

      // Navigate to the last page.
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboardingCompleted'), isTrue);
    });

    testWidgets('Skip completes onboarding immediately', (tester) async {
      SharedPreferences.setMockInitialValues({});
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(onComplete: () => completed = true),
        ),
      );

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });
  });

  group('MyApp onboarding gate', () {
    testWidgets('shows onboarding when not completed', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        const MyApp(onboardingCompleted: false),
      );

      expect(find.text('Welcome to Totoki!'), findsOneWidget);
    });
  });
}
