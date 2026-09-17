# Testing

This document describes the automated test suite and the CI workflow for Totoki Extract.

## Running the tests

```bash
# Static analysis (expected: 0 errors, 0 warnings)
flutter analyze

# Unit + widget suites (device-independent, used by CI)
flutter test test/unit test/widget

# A single suite or file
flutter test test/unit/scheduler_test.dart
flutter test test/widget/onboarding_test.dart

# All tests including top-level files
flutter test test/unit test/widget test/history_lesson_test.dart test/ielts_parsing_test.dart
```

Integration tests (`test/integration/`) require a device/emulator and are not part of the CI unit/widget run.

## Suite layout

| Path | Type | Coverage |
|---|---|---|
| `test/unit/scheduler_test.dart` | unit | `computeSM2` invariants (interval, reps, ease factor). |
| `test/unit/supermemo_test.dart` | unit | `updateCardReview` lapse/interval/ease/due logic. |
| `test/unit/flashcard_mapper_test.dart` | unit | Anki note-model field mapping (`mapRowToFlashcard`). |
| `test/unit/find_complexity_test.dart` | unit | Complexity scoring (`findComplexity`, syllable/length/suffix rules). |
| `test/unit/question_normalizer_test.dart` | unit | IELTS question-group normalization helpers. |
| `test/unit/models_roundtrip_test.dart` | unit | `toMap`/`fromMap` round-trips for `Flashcard`, `User`, `DailyUsage`, `HistoryLesson`, `CardHistory`. |
| `test/widget/onboarding_test.dart` | widget | Onboarding flow, `MyApp` onboarding gate. |
| `test/widget/ielts_question_widgets_test.dart` | widget | IELTS question widgets (checkbox render/select, review display). |
| `test/history_lesson_test.dart` | unit | Lesson-history model/logic. |
| `test/ielts_parsing_test.dart` | unit | IELTS asset parsing. |
| `test/integration/ielts_reading_integration_test.dart` | integration | End-to-end IELTS reading flow on a device. |

The `test/dbTest.dart` and `test/questionPaserTest.dart` scratch files are not `*_test.dart` suites and are not run by `flutter test`.

## Conventions

- Pure-Dart logic (schedulers, mappers, parsing, models) is covered by plain unit tests.
- UI behavior is covered with widget tests (`testWidgets`) under `test/widget/`.
- Database-backed screens (deck list, cards, lesson end, IELTS passages) are not unit-tested here; they are exercised through integration/device testing.
- Keep `flutter analyze` at 0 errors / 0 warnings and keep the deterministic suites green.

## CI

`.github/workflows/ci.yml` runs on push/PR to `main`/`master`:

1. Setup Flutter `3.35.4` (stable) via `subosito/flutter-action`.
2. `flutter pub get`.
3. `flutter analyze` — fails the build on any error or warning.
4. `flutter test test/unit test/widget` — runs the deterministic suites.
