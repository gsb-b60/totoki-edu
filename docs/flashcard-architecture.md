# Flashcard Module Architecture

This document details the architecture of the Flashcard module in "Crystal of English". It serves as a guide for understanding the system and as a reference for extracting it into a standalone library or another project.

## 1. Overview
The Flashcard module provides a complete system for learning vocabulary using Spaced Repetition (SRS). It includes deck management, card CRUD operations, Anki (.apkg) import capabilities, and two implementations of the SM2 algorithm for scheduling reviews.

## 2. Core Components

### 2.1 Models
- **`Flashcard`** (`lib/flashcard/business/Flashcard.dart`): Represents a single card. Contains word, meaning, example, IPA, image path, sound paths, and SRS-related metadata (interval, reps, due date, ease factor).
- **`Deck`** (`lib/flashcard/business/Deck.dart`): Represents a collection of flashcards. Includes a `media` field which stores the directory name where its associated assets (images/audio) are stored.

### 2.2 State Management (Provider)
- **`Cardmodel`** (`lib/flashcard/business/Flashcard.dart`): Manages the list of cards for a deck. Handles fetching, adding, updating, deleting, and reviewing cards in a general context.
- **`Deckmodel`** (`lib/flashcard/business/Deck.dart`): Manages the list of decks and handles the Anki import process.
- **`LessonNoti`** (`lib/flashcard/DailyLesson/dailyLesson/noti/lessonNoti.dart`): The central state manager for the **Daily Lesson** system. It orchestrates a series of `StudyMode` steps for a set of cards, tracking accuracy, streaks, and media state.
- **Study Mode Notifiers**: Each standalone study mode (e.g., `EchoFuseNoti`, `Mindfieldnoti`) manages the specific logic (shuffling options, checking answers) for its own screen.

### 2.3 Business Logic (SRS Algorithms)
The module contains two slightly different implementations of the SuperMemo-2 (SM2) algorithm:
1.  **Standard SM2** (`lib/flashcard/business/scheduler.dart`): Used by `Cardmodel`. It calculates the next interval and ease factor based on a quality rating (0-5).
2.  **Variant SM2** (`lib/flashcard/business/supermemo.dart`): Used by `SMNoti` in daily lessons. It includes a "jitter" factor to slightly randomize due dates and handles intervals in minutes for early repetitions.

### 2.4 Data Layer
- **`DatabaseHelper`** (`lib/data/flashcard/database_helper_io_impl.dart`): The central hub for SQLite persistence. It manages the `decks` and `cards` tables and contains complex logic for:
    - Initializing and upgrading the database schema.
    - Importing data from Anki `.apkg` files.
    - Managing file system operations for media assets.
- **`Flashcard_Mapper`** (`lib/data/flashcard/flashCard_Mapper.dart`): Contains regex-based logic to parse Anki's internal field format (`flds`) and map it to the `Flashcard` model. It is model-ID (`mid`) dependent.

## 3. Data Flow

### 3.1 Anki Import Process
1.  **File Selection**: User selects an `.apkg` file via `FilePicker`.
2.  **Extraction**: The file is unzipped. `collection.anki21` (a SQLite DB) and the `media` map are extracted.
3.  **Database Import**: 
    - Decks are read from the Anki DB and created in the local `decks` table.
    - Notes are read, parsed via `Flashcard_Mapper`, and inserted into the `cards` table.
4.  **Media Migration**: Media files are renamed according to the `media` map and moved to a dedicated folder: `getApplicationDocumentsDirectory()/anki/<timestamp>/`. The `<timestamp>` folder name is saved in the `Deck.media` field.

### 3.2 Review Cycle
1.  User answers a card and provides a rating (0-5).
2.  `Cardmodel.updateCardAfterReview` (or `SMNoti`) is called.
3.  The algorithm calculates the next `interval`, `reps`, `ease_factor`, and `due` date.
4.  The card is updated in the SQLite database.

### 3.3 Provider Integration in Reviews
The review system heavily relies on `ChangeNotifier` and `Provider`:
1.  **Multi-Provider Setup**: Entry points like `LessonScreen` or `Learnlevel` initialize `LessonNoti`, `TimerNoti`, and `Questnoti`.
2.  **Reactive UI**: Screens use `Consumer` or `context.watch<LessonNoti>()` to react to state changes (e.g., `answered` status, `currentCardIdx`).
3.  **Action Dispatch**: UI interactions (taps) call methods on the provider (e.g., `reader.checkAnswerMC()`, `reader.nextCard()`).
4.  **Flow Control**: `LessonNoti` maintains a `SetUpLessonList` which maps progress to specific `StudyMode` enums, triggering UI switches in the main `Consumer` builder.

## 4. Review Screens and Study Modes

The module supports two main review workflows:

### 4.1 Daily Lesson Workflow
Located in `lib/flashcard/DailyLesson/`, this system uses a unified UI switcher (`LessonScreen`) to cycle through different challenges:
- **`StartScreen`**: Overview of the lesson.
- **`EndScreen`**: Summary of performance (XP, accuracy, time).
- **Core Study Modes**:
    - `MeanfuseUI`: Meaning to word construction (tapping letters).
    - `WordSnapUI`: Meaning to word selection (multiple choice).
    - `MindFeildUI`: Meaning to shuffled word variants.
    - `EchoSpellUI` / `EchoFuseUI` / `EchoMatchUI`: Sound/IPA based challenges.
    - `NeuroPickUI` / `WordPulseUI` / `SoundNSightUI`: Image based recognition.
    - `SynonympickUI` / `SynonymfeildUI`: Synonym based challenges.
    - `SpeechWordUI`: Pronunciation practice using Speech-to-Text.
    - `PhoneMixUI`: Matching words to their IPA.
    - `ReviewUI`: Traditional SRS card flipping with swipe-to-rate logic.

### 4.2 Standalone / Deck Practice
Located in `lib/flashcard/screen/studymode/`, these screens can be launched independently for a specific deck:
- **`Newwayreview`**: A stack-based review interface using `swipable_stack` and `flip_card`.
- **`BlankWordScreen`**: Fill-in-the-blank word construction.
- **Individual Mode Screens**: Standalone versions of the Daily Lesson modes (e.g., `MindFeild`, `Echospell`, `NeuroPick`), each with their own dedicated notifier.

## 5. Database Schema

### `decks` table
- `id`: INTEGER PRIMARY KEY
- `name`: TEXT
- `description`: TEXT
- `media`: TEXT (Folder name for assets)
- `created_at`, `updated_at`: INTEGER (Timestamps)

### `cards` table
- `id`: INTEGER PRIMARY KEY
- `deck_id`: INTEGER (FK)
- `word`, `meaning`, `example`, `ipa`: TEXT
- `img`, `sound`, `defSound`, `usageSound`: TEXT (Filenames relative to deck media folder)
- `complexity`: INTEGER
- `interval`: INTEGER (Days until next review)
- `reps`: INTEGER (Number of successful repetitions)
- `due`: INTEGER (Timestamp of next review)
- `ease_factor`: REAL
- `lapses`: INTEGER (Number of times forgotten)

## 5. Media Management
Flashcard assets (images and audio) are stored in the application's documents directory. Each deck has its own subfolder. 
- Path pattern: `AppDocsDir/anki/<deck_media_field>/<filename>`
- **Warning**: Several files currently contain hardcoded Android-specific paths (e.g., `/data/user/0/com.example.mygame/app_flutter/anki/...`). These MUST be refactored to use `path_provider` dynamically during extraction.

## 6. Dependencies
- **State**: `provider`
- **Database**: `sqflite`
- **File System**: `path`, `path_provider`
- **Compression**: `archive`, `flutter_archive`
- **Pickers**: `file_picker`
- **Audio**: `audioplayers`, `flame_audio`
- **UI Components**: `flip_card`, `swipable_stack`
- **Special Features**: `speech_to_text` (pronunciation), `vibration` (haptics), `intl` (date formatting)

## 7. Extraction Strategy & Critical Notes

### 7.1 Essential Assets
Beyond the code, the following assets are required for the module to function as designed:
- **Reputation Icons**: `assets/rep/rep0.png` through `rep5.png` (used in Achievement UI).
- **Mode Illustrations**: `assets/illumode/*.png` (used in the Learn Mode selection screen).
- **Sample Deck**: `assets/anki-deck/IELTS - Advanced__Unit 02 - Time for a change.apkg` (used for initial setup).

### 7.2 Anki Mapping Constraints
The `Flashcard_Mapper.dart` is currently hardcoded to specific Anki Model IDs:
- `1470756627995`
- `1434531251879`
If importing decks from other Anki sources, these IDs must be updated or the mapping logic made more generic.

### 7.3 Path Refactoring
The following files require immediate attention to remove hardcoded paths:
- `lib/flashcard/DailyLesson/dailyLesson/noti/lessonNoti.dart`
- `lib/flashcard/quizzconverter/fctoquizz.dart`
- `lib/flashcard/screen/studymode/echofuse/echofuseNoti.dart` (and other study mode notifiers)

### 7.4 Implementation Separation
- **`DatabaseHelper`**: Currently combines flashcard logic with `player_profile`. These tables and their associated methods should be split into separate service classes.
- **Platform Support**: The database implementation is split into `database_helper_io_impl.dart` and `database_helper_web.dart`. The extraction agent must ensure the conditional export logic is preserved.
