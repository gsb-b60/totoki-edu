
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

<p align="center">
  <img src="https://github.com/user-attachments/assets/3efaaac9-d3ad-4846-ac59-879ff377c4a1" width="220" alt="Main screen">
  <img src="https://github.com/user-attachments/assets/ce7bd2da-cb04-4155-9be3-736a2b5301d3" width="220" alt="Side screen">
  <img src="https://github.com/user-attachments/assets/6891f29c-68bc-4438-88de-ce70147253f8" width="220" alt="Speaking screen">
  <img src="https://github.com/user-attachments/assets/4950404a-563d-4d71-ae4e-0a636068cfca" width="220" alt="IELTS screen">
</p>

<p align="center">
  <strong>Main</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <strong>Side</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <strong>Speak</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <strong>IELTS</strong>
</p>

