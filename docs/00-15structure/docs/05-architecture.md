# Architecture

## Layer Overview

The project mixes layered separation with feature folders:

```
┌──────────────────────────────────────────────┐
│                 ui/  (screens, widgets)      │
└──────────────────────┬───────────────────────┘
                       │   provider (ChangeNotifier)
┌──────────────────────┴───────────────────────┐
│              business/  (models, SRS logic)  │
└──────────────────────┬───────────────────────┘
                       │   DAOs / helpers
┌──────────────────────┴───────────────────────┐
│         data/  (SQLite DBs, import, DAOs)    │
└──────────────────────────────────────────────┘
```

State flows through `ChangeNotifier` models/notifiers (`provider`), screens are wired with `go_router` (a `StatefulShellRoute.indexedStack` shell for the 3-tab layout plus standalone routes), and persistence is split across two SQLite databases.

## Directory structure inside `lib/`

- **`lib/business/`** — Domain models and business logic.
  - `flashcard/`: `deck.dart` (`Deck` + `Deckmodel`), `flashcard.dart` (`Flashcard` + `Cardmodel`), `scheduler.dart` (`computeSM2` SM-2), `supermemo.dart` (`updateCardReview` + `SMNoti`).
  - `user/`: `user.dart`, `history_lesson.dart`, `daily_usage.dart`, `card_history.dart`, `lessonType.dart`.
  - `path_service.dart`: resolves app-document and per-deck media folders.

- **`lib/data/`** — Persistence.
  - `card_database/`: `database_helper.dart` (`flashcards.db`), `flashCard_Mapper.dart` (Anki note-model → `Flashcard`), `findComplexity.dart` (complexity scoring).
  - `user_database/`: `user_db_helper.dart` (`user.db`), plus `user_dao.dart`, `history_lesson_dao.dart`, `daily_usage_dao.dart`, `card_history_dao.dart`.

- **`lib/features/`** — Feature modules.
  - `lesson/`: `models/storage.dart` (`StudyMode`, `LearnMode`, `FetchMode`), `notifier/` (`LessonNoti` + part-file mixins, `TimerNoti`, `Questnoti`), `ui/` (`lesson_screen.dart`, `learn_level.dart`, `learn_mode.dart`, `start_screen.dart`, `end_screen.dart`, `studymode/*`).
  - `ielts/`: `models/`, `parsers/` (`article_parser`, `question_parser`, `question_normalizer`, `answer_parser`, `reading_passage_parser`), `notifier/reading_notifier.dart`, `helpers/`, `parser-handbook/`.
  - `penpal/`: `models/`, `data/`, `notifier/`, `ui/`.
  - `user/`: `user_notifier.dart`, `analyze_notifier.dart`, `lesson_history_notifier.dart`, `lesson_analytics_notifier.dart`, `card_analytics_notifier.dart`, `activity_analytics_notifier.dart`, `analytics_models.dart`.

- **`lib/router/`** — `app_router.dart` (`AppRouter.router`).
- **`lib/services/` + `lib/service/`** — `sound_controller.dart`, `usage_tracker.dart`.
- **`lib/theme/`** — `app_theme.dart` (`AppTheme` design tokens).
- **`lib/ui/`** — `screens/` (home, decklist, learnmode, analyze, dashboard, history, profile, ielts, onboarding, studymode), `widget/` (reusable widgets), and `lesson/` (legacy lesson config under `lib/ui/lesson/`).

## State Management

- Managed with the `provider` package. Models/notifiers extend `ChangeNotifier` and expose getters/methods; screens consume them via `Consumer`, `Provider.of`, or `context.read`.
- Global scope (`lib/main.dart` `MultiProvider`): `Deckmodel` (auto-fetches decks), `Cardmodel`, `SoundController`, `ReadingNoti` (IELTS), `UserNotifier` (auto-initializes), `AnalyzeNotifier`.
- Per-lesson scope: `LessonNoti`, `TimerNoti`, `Questnoti` wrapped via `MultiProvider` inside the lesson screens.

## Navigation

`lib/router/app_router.dart` uses `go_router`:

- Shell branches (tabs): `/learn` (`LearnModeScreen`), `/analyze` (`AnalyzeScreen`), `/ielts` (`IeltsTraining`).
- Standalone routes: `/decks`, `/stats`, `/dashboard`, `/history`, `/profile`, `/penpal`, `/ielts/reading`, `/ielts/reading/:series/:test/:part/:group`, `/decks/:deckId/cards`, `/decks/:deckId/cards/study/:mode`, `/learn/lesson`, `/learn/level/:level`, `/learn/mode`, `/stats/card`.
- Most non-shell routes use a fade transition (`_fadeTransition`). Study-mode routing is resolved by `_buildStudyModeScreen(mode, deckId)`.

## Data Flow (high level)

```
UsageTracker  → writes → DailyUsageDao          → reads → ActivityAnalyticsNotifier
Lesson EndScreen → writes → HistoryLessonDao    → reads → LessonAnalyticsNotifier
DatabaseHelper → reads → Deckmodel, Cardmodel, LessonNoti, Achievementnoti, study-mode notifiers
CardHistoryDao <-> reads → CardAnalyticsNotifier
```
