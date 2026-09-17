# AGENTS.md

## Context & Source Code
- This is a Flutter mobile application named **Totoki Extract** designed for daily English vocabulary learning using the SuperMemo (SM-2) Spaced Repetition System (SRS).
- High-level project entry point: `lib/main.dart` (initializes `PathService`, registers global `MultiProvider`, launches `MyApp`; onboarding gate via `SharedPreferences`).
- Routing: `lib/router/app_router.dart` (`go_router`, `StatefulShellRoute.indexedStack` 3-tab shell: Learn / Analyze / IELTS).
- Core data models: `lib/business/flashcard/deck.dart` (`Deckmodel` ChangeNotifier) and `lib/business/flashcard/flashcard.dart` (`Cardmodel` ChangeNotifier).
- Primary SM-2 algorithm used by `Cardmodel`: `lib/business/flashcard/scheduler.dart` (`computeSM2`); secondary implementation used by the lesson flow: `lib/business/flashcard/supermemo.dart` (`updateCardReview`).
- Card/deck SQLite schema and Anki import: `lib/data/card_database/database_helper.dart`, `lib/data/card_database/flashCard_Mapper.dart`, and `lib/data/card_database/findComplexity.dart`.
- User/profile SQLite schema and DAOs: `lib/data/user_database/user_db_helper.dart`, `lib/data/user_database/{user,history_lesson,daily_usage,card_history}_dao.dart`.
- File path management: `lib/business/path_service.dart`.
- Study-modes (mini-games): `lib/ui/screens/studymode/` (per-mode `{name}.dart` + `{name}Noti.dart`) and the per-deck routing switch in `lib/router/app_router.dart` (`_buildStudyModeScreen`).
- Guided lesson system: `lib/features/lesson/` (models, `notifier/` with part-file mixins, `ui/` screens and study-mode widgets).
- IELTS reading feature: `lib/features/ielts/` (models, parsers, notifier, helpers, parser-handbook) and `lib/ui/screens/ielts/`.
- Penpal letter-writing feature: `lib/features/penpal/`.
- User/analytics notifiers: `lib/features/user/` (`UserNotifier`, `AnalyzeNotifier`, analytics sub-notifiers).
- Services: `lib/services/sound_controller.dart` (sound effects), `lib/service/usage_tracker.dart` (session usage tracking).
- Standard color scheme and text styles: `lib/theme/app_theme.dart`.

## Rules & Constraints
- **Read First**: Always read the specifications in `docs/` and `docs/00-15structure/` before coding. Start with [README.md](./README.md) for the full document tree overview.
- **State Management**: Avoid `setState` for global or shared states. Use `Provider` (`ChangeNotifierProvider`, `Consumer`, or `Provider.of`).
- **Database Operations**: Do not write raw SQL queries directly in UI components. Use the `DatabaseHelper` / `UserDatabaseHelper` helpers and DAOs.
- **UI Guidelines**: Follow the Material 3 design spec. Always use theme tokens from `AppTheme` instead of hardcoded colors/styles.
- **Error Resilience**: Wrap all init-level I/O (paths, database, services) in try-catch. On failure, store a descriptive error, provide fallback values, and surface the error to the user instead of crashing. Use `PathService.initError` / `_dbInitError` patterns. Never throw unhandled exceptions at startup in `main()`.
- **Verification**: Run `flutter analyze` before finalizing any changes (expected result: 0 errors and 0 warnings). Run `flutter test test/unit test/widget` and keep the suites green. See `docs/00-15structure/docs/13-testing.md` for the current test layout.
- **Updates**: Keep this documentation updated on any architectural adjustments.
