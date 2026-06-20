# AGENTS.md

## Context & Source Code
- This is a Flutter mobile application named **Totoki** designed for daily English vocabulary learning using the SuperMemo (SM-2) Spaced Repetition System (SRS).
- High-level project entry point: `lib/main.dart`
- Spaced repetition algorithm: [supermemo.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/business/flashcard/supermemo.dart)
- SQLite Database schema and migrations: [database_helper.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/data/database_helper.dart)
- UI Screens folder: `lib/ui/screens/`
- Standard color scheme and text styles: [appTheme.dart](file:///d:/secobapCoop/totoki_seperate/totoki_extract/lib/theme/appTheme.dart)

## Rules & Constraints
- **Read First**: Always read the specifications in `docs/` and `spec/` before coding.
- **State Management**: Never use `setState` for global or shared states. Use `Provider` (`ChangeNotifierProvider` and `Consumer` or `Provider.of`).
- **Database Operations**: Do not write raw SQL queries directly in UI components. Use `DatabaseHelper`.
- **UI Guidelines**: Follow the Material 3 design spec. Always utilize theme tokens from `AppTheme` instead of hardcoded colors/styles.
- **Verification**: Run `flutter analyze` and all widget/unit tests in `test/` before finalizing any changes.
- **Updates**: Keep this documentation updated on any architectural adjustments.
