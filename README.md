# Totoki Extract

A mobile **Flutter** application for daily English vocabulary learning. It imports **Anki `.apkg` decks**, schedules reviews with the **SuperMemo (SM-2)** spaced-repetition algorithm, and turns review into 14 interactive study mini-games plus IELTS reading and letter-writing practice.

## Features

- **Anki import** - Import `.apkg` packages; media (images/audio) extracted into per-deck folders
- **Spaced repetition (SM-2)** - Two scheduler implementations drive flashcard and lesson review timing
- **14 study modes** - Flashcard, blank-fill, mind-field, word-snap, echo-spell, speech-word, and more
- **Guided lessons** - Chained study-mode sessions with timer and accuracy tracking
- **IELTS reading** - Article + question JSON assets with 9 question types
- **Penpal game** - Scripted letter-writing practice with keyword/regex checking
- **Analytics dashboard** - Streaks, activity calendar, review stats, leech cards
- **Feedback** - Sound effects, vibration, and streak celebrations

## Tech Stack

- **Flutter 3.35.4** (stable) / **Dart 3.9.2**
- **State:** `provider`
- **Routing:** `go_router` (`StatefulShellRoute.indexedStack`)
- **Database:** `sqflite` (two SQLite DBs), `shared_preferences`
- **Files/media:** `path_provider`, `archive` + `flutter_archive`, `file_picker`, `image_picker`
- **Audio/speech:** `audioplayers`, `speech_to_text`, `vibration`
- **Charts/UI:** `fl_chart`, `flip_card`, `swipable_stack`, `intl`, `uuid`, `url_launcher`

## Requirements

- Flutter SDK **>= 3.35.4** (stable channel)
- Dart SDK **>= 3.9.2**
- Android SDK (Android builds) · Xcode (iOS builds)

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/your-org/totoki_extract.git
cd totoki_extract
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

On first launch the app shows an onboarding flow, then the main Learn / Analyze / IELTS shell.

## Testing & Static Analysis

```bash
flutter analyze                    # 0 errors / 0 warnings expected
flutter test test/unit test/widget # unit + widget suites
```

- **Unit tests:** SM-2 scheduler & supermemo invariants, Anki field mapping, complexity scoring, model round-trips
- **Widget tests:** onboarding flow, IELTS question widgets
- **CI:** GitHub Actions runs `flutter analyze` and `flutter test` on push/PR to main

## Documentation

Structured docs live under [`docs/00-15structure/`](docs/00-15structure/README.md) - architecture, database schema, SM-2 business rules, features, specs, roadmap. An IELTS parser handbook is in [`docs/parser-handbook/`](docs/parser-handbook/README.md).

## Screenshots

![ielts](screenshot\main.png)
![ielts](screenshot\side.png)
![ielts](screenshot\speed.png)
![ielts](screenshot\ielts.png)
