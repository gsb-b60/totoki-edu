# Pull Request: Merge `fix/naming-conventions` into `master`

## Summary

Major refactoring + new features across 189 lib files (+14,837 / -2,669 lines). Reorganizes codebase into feature-based architecture, adds IELTS reading practice, penpal writing simulator, user analytics, and cleans up naming conventions throughout.

## What it does

### Architecture & Refactoring
- **Naming conventions** — Renamed PascalCase files to snake_case (`Deck.dart` → `deck.dart`, `appTheme.dart` → `app_theme.dart`)
- **Feature-based structure** — Moved `lib/ui/lesson/` → `lib/features/lesson/`, split monolithic `lessonNoti.dart` (789 lines) into 8 focused modules (`lesson_progress`, `lesson_media`, `lesson_options`, `lesson_sm2`, etc.)
- **Database split** — Separated `lib/data/database_helper.dart` into `card_database/` and `user_database/` with proper DAOs
- **Navigation** — Migrated to `go_router` (`lib/router/app_router.dart`)
- **Widgets relocated** — Moved `lib/widget/` → `lib/ui/widget/`

### New Features
- **IELTS reading system** — Passage parser, question parser, answer parser, multiple question types (checkbox, table input, diagram, summary selection), full-screen review with continue navigation
- **Penpal writing simulator** — Letter stages, friend models, typing indicators, reply input at `lib/features/penpal/`
- **User analytics** — Activity calendar, lesson progress, review health, today's pulse, weekly stats at `lib/features/user/`
- **Lesson history** — Save-on-complete flow at `lib/ui/screens/history/`
- **New screens** — Onboarding, Home, Profile, Analyze tab (white theme), Decklist (replaces `deckwelcome.dart`)
- **Sound system** — `SoundController` service + 5 audio assets
- **User database** — DAOs for user, card history, daily usage, history lesson

### Deleted
- `lib/ui/lesson/dailyLesson/noti/lessonNoti.dart` (789 lines — replaced by split modules)
- `lib/ui/lesson/dailyLesson/learnSpec/` (3 files — replaced by `features/lesson/ui/`)
- `lib/ui/screens/decklist/deckwelcome.dart` (replaced by `decklist_screen.dart`)
- Old docs (`ARCHITECTURE.md`, `MIGRATION_*.md`, `flashcard-architecture.md`, etc.)

## Where it touches

| Area | Files | Key changes |
|------|-------|-------------|
| `lib/features/` | ~60 | New feature dirs: `ielts/`, `lesson/`, `penpal/`, `user/` |
| `lib/data/` | 8 | Split into `card_database/` + `user_database/` with DAOs |
| `lib/business/` | 6 | User models added, file renames |
| `lib/ui/` | ~80 | New screens, widget relocations, studymode refactors |
| `lib/router/` | 1 | New `app_router.dart` (go_router) |
| `lib/services/` | 1 | New `sound_controller.dart` |
| `assets/ielts/` | ~200 | 20 test JSONs, question JSONs, answer JSONs, images, dictionary |
| `assets/sound/` | 5 | Audio files (correct, wrong, finish, in_a_row) |
| `test/` | 11 | Unit, widget, and integration tests |
| `docs/` | ~25 | Structure docs, parser handbook, session notes |
| `pubspec.yaml` | 1 | New dependencies (go_router, etc.) |

## Breaking Changes

- File paths changed for lesson module, widgets, and database helpers — update all imports accordingly
- `deckwelcome.dart` removed — use `decklist_screen.dart` instead
- `lessonNoti.dart` removed — use `features/lesson/notifier/lesson_noti.dart` and sub-modules
