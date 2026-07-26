# AGENTS.md

## Context & Source Code
- This is a Flutter mobile application named **Totoki** designed for daily English vocabulary learning using the SuperMemo (SM-2) Spaced Repetition System (SRS).
- High-level project entry point: `lib/main.dart` (initializes `PathService`, registers `MultiProvider`, launches `MyApp`)
- Core data models: [Deck.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/business/flashcard/Deck.dart) (`Deckmodel` ChangeNotifier) and [Flashcard.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/business/flashcard/Flashcard.dart) (`Cardmodel` ChangeNotifier)
- Calendar session tracking: [session.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/business/calendar/session.dart) (`Session` model) and [calendar_model.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/business/calendar/calendar_model.dart) (`CalendarModel` ChangeNotifier with day/week/month format switching)
- Primary SM-2 algorithm used by `Cardmodel`: [scheduler.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/business/flashcard/scheduler.dart) (`computeSM2`); secondary alternate implementation: [supermemo.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/business/flashcard/supermemo.dart)
- SQLite Database schema and migrations: [database_helper.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/data/database_helper.dart) (includes `sessions` table since v2)
- Anki `.apkg` import pipeline: [flashCard_Mapper.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/data/flashCard_Mapper.dart) and [findComplexity.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/data/findComplexity.dart)
- File path management: [path_service.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/business/path_service.dart)
- UI Screens folder: `lib/ui/screens/` (deck list, dashboard, study modes, blank-fill, learn mode, calendar)
- Calendar UI: `lib/ui/screens/calendar/` (3 views: month, week, day + session detail sheet)
- UI Lesson system: `lib/ui/lesson/` (daily lesson config, notifiers, screens, lesson-specific study modes)
- Reusable widgets: `lib/widget/` (choice buttons, progress indicator, review screen, skip button)
- Standard color scheme and text styles: [app_theme.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/theme/app_theme.dart)

## Rules & Constraints
- **Read First**: Always read the specifications in `docs/` and `docs/00-15structure/spec/` before coding. Start with [README.md](./README.md) for the full document tree overview.
- **State Management**: Never use `setState` for global or shared states. Use `Provider` (`ChangeNotifierProvider` and `Consumer` or `Provider.of`).
- **Database Operations**: Do not write raw SQL queries directly in UI components. Use `DatabaseHelper`.
- **UI Guidelines**: Follow the Material 3 design spec. Always utilize theme tokens from `AppTheme` instead of hardcoded colors/styles.
- **Error Resilience**: Wrap all init-level I/O (paths, database, services) in try-catch. On failure, store a descriptive error, provide fallback values, and surface the error to the user instead of crashing. Use `PathService.initError` / `_dbInitError` patterns. Never throw unhandled exceptions at startup in `main()`.
- **Verification**: Run `flutter analyze` before finalizing any changes. Note: `test/` currently contains only boilerplate; add unit tests for SM-2, database, and notifiers as features stabilize.
- **Updates**: Keep this documentation updated on any architectural adjustments.

