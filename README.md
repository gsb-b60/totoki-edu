# Totoki Extract

A mobile Flutter application for daily English vocabulary learning built on **Anki-imported decks** and the **SuperMemo (SM-2)** spaced-repetition system. It combines guided lessons, 14 interactive study mini-games, IELTS reading practice, letter-writing practice, and usage analytics.

## Tech Stack

- **Flutter** 3.35.4 (stable) / **Dart** 3.9.2
- **State management:** `provider` (`ChangeNotifier` models / notifiers)
- **Navigation:** `go_router` (`StatefulShellRoute.indexedStack` 3-tab shell)
- **Persistence:** `sqflite` (two SQLite DBs), `shared_preferences` (onboarding flag)
- **Media / files:** `path_provider`, `archive` + `flutter_archive` (Anki `.apkg` import), `file_picker`, `image_picker`
- **Audio / speech:** `audioplayers`, `speech_to_text`, `vibration`
- **Other:** `fl_chart` (analytics charts), `intl`, `uuid`, `url_launcher`, `flip_card`, `swipable_stack`

## Project Layout

Top-level source entry point is `lib/main.dart`. The project is organized into layered and feature-based folders under `lib/`:

| Folder | Role |
|--------|------|
| `lib/main.dart` | App bootstrap: `PathService.init()`, `SharedPreferences`, `UsageTracker`, global `MultiProvider`, onboarding gate. |
| `lib/router/` | `go_router` configuration and all routes. |
| `lib/business/` | Domain models & SRS logic: `flashcard/` (`Deck`, `Flashcard`, `scheduler.dart`, `supermemo.dart`), `user/` (profile, history, usage), `path_service.dart`. |
| `lib/data/` | Persistence: `card_database/` (`flashcards.db`, Anki import, mappers), `user_database/` (`user.db`, DAOs). |
| `lib/features/` | Feature modules: `lesson/` (notifier + UI + study-mode widgets), `ielts/` (models, parsers, notifier), `penpal/`, `user/` (notifiers + analytics). |
| `lib/ui/screens/` | Screen-level widgets: home shell, deck list, card list, learn mode, analyze, dashboard, history, profile, IELTS, onboarding, study modes. |
| `lib/ui/widget/` | Reusable widgets (choice buttons, progress indicator, review screen, skip button, etc.). |
| `lib/theme/` | `AppTheme` design tokens (colors, typography, dark theme). |
| `lib/services/` + `lib/service/` | `SoundController`, `UsageTracker`. |

## Key Concepts

- **Decks & cards** are imported from Anki `.apkg` packages. Media (images/audio) is extracted into per-deck folders under the app documents `anki/` directory; the folder basename is stored on the deck. Card content is mapped from Anki note models via `lib/data/card_database/flashCard_Mapper.dart`.
- **Two SQLite databases:** `flashcards.db` (decks + cards + SRS scheduling fields) and `user.db` (profile, history lessons, card review history, daily usage). See [`docs/00-15structure/docs/06-database.md`](docs/00-15structure/docs/06-database.md).
- **Spaced repetition (SM-2):** `computeSM2` in `lib/business/flashcard/scheduler.dart` drives `Cardmodel.updateCardAfterReview`. A second implementation, `updateCardReview` in `lib/business/flashcard/supermemo.dart`, drives per-card rating through the lesson flow. See [`docs/00-15structure/docs/08-business-rules.md`](docs/00-15structure/docs/08-business-rules.md).
- **Study modes:** 14 routable mini-games (flashcard, blank-fill, mind-field, word-snap, word-pulse, phone-mix, synonym-field, synonym-pick, echo-spell, echo-match, echo-fuse, sound-and-sight, neuro-pick, speech-word). Mode routing lives in `lib/router/app_router.dart` (`_buildStudyModeScreen`).
- **Lessons:** guided sessions that chain study-mode steps over a set of cards, with per-mode fetchers, a timer, an accuracy tracker, and SM-2 rating. See [`docs/00-15structure/docs/03-features.md`](docs/00-15structure/docs/03-features.md).
- **IELTS:** a reading-exercise module with article, question, and answer JSON assets under `assets/ielts/`. Only the Reading flow is wired end-to-end. See [`docs/00-15structure/docs/10-ielts.md`](docs/00-15structure/docs/10-ielts.md) and the in-tree [`lib/ui/screens/ielts/IELTS_GUIDE.md`](lib/ui/screens/ielts/IELTS_GUIDE.md).

## Quick Start

```bash
flutter pub get
flutter run
```

The app shows an onboarding flow on first launch, then the main 3-tab shell (Learn / Analyze / IELTS).

## Testing & Static Analysis

```bash
flutter analyze            # 0 errors / 0 warnings expected
flutter test test/unit test/widget   # unit + widget suites
```

- **Unit tests** (`test/unit/`): SM-2 scheduler and supermemo invariants, Anki field mapping, complexity scoring, question normalization, model round-trips.
- **Widget tests** (`test/widget/`): onboarding flow, IELTS question widgets.
- **Top-level tests** (`test/history_lesson_test.dart`, `test/ielts_parsing_test.dart`) and **integration tests** (`test/integration/`) cover parsing and device-dependent flows.
- **CI:** `.github/workflows/ci.yml` runs `flutter analyze` (fails on errors/warnings) and `flutter test test/unit test/widget` on push/PR.

See [`docs/00-15structure/docs/13-testing.md`](docs/00-15structure/docs/13-testing.md) for details.

## Documentation

Structured project documentation lives under [`docs/00-15structure/`](docs/00-15structure/README.md) (architecture, database, business rules, features, specs, roadmap). An IELTS question-JSON parser handbook lives in [`docs/parser-handbook/`](docs/parser-handbook/README.md).
