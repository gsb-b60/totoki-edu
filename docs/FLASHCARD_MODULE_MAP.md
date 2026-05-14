# Flashcard Module Map

## Module Boundaries

### App Shell

- `lib/main.dart`
  - Initializes `PathService`.
  - Provides `Deckmodel`.
  - Opens `DeckListScreen`.

### Path Ownership

- `lib/business/path_service.dart`
  - Owns app document path.
  - Owns `anki/` media root.
  - Exposes deck media and file path helpers.

All flashcard media paths should flow through this service.

### Business Layer

- `lib/business/flashcard/Deck.dart`
  - `Deck` model.
  - `Deckmodel` provider for deck list and import actions.

- `lib/business/flashcard/Flashcard.dart`
  - `Flashcard` model.
  - `Cardmodel` provider for deck cards, review updates, and undo.

- `lib/business/flashcard/scheduler.dart`
  - Standard SM2 scheduler used by `Cardmodel`.

- `lib/business/flashcard/supermemo.dart`
  - Variant SM2 scheduler used by Daily Lesson flow.

### Data Layer

- `lib/data/database_helper.dart`
  - Conditional export.

- `lib/data/database_helper_io_impl.dart`
  - Owns SQLite database initialization.
  - Owns `decks` and `cards` tables only.
  - Owns APKG extraction/import flow.
  - Owns media migration into `PathService.ankiPath`.

- `lib/data/database_helper_web.dart`
  - In-memory flashcard-only stub for non-IO surfaces.

- `lib/data/flashCard_Mapper.dart`
  - Maps Anki note fields to `Flashcard`.
  - Keeps known model IDs configurable via `defaultAnkiMappings`.
  - Falls back to generic field guessing.

- `lib/data/findComplexity.dart`
  - Word complexity heuristic.

### Reusable Widgets

- `lib/widget/checkBtn.dart`
- `lib/widget/checkBtnVertical.dart`
- `lib/widget/choiceBtn.dart`
- `lib/widget/choiceBtn4States.dart`
- `lib/widget/choiceBtnVertical.dart`
- `lib/widget/progessIndicator.dart`
- `lib/widget/reviewScreen.dart`

These are shared by Daily Lesson mode screens.

## Provider Ownership Map

- `Deckmodel`
  - Owner: app shell and deck list.
  - Responsibilities: fetch decks, create/delete deck, trigger APKG import.

- `Cardmodel`
  - Owner: deck card list and standalone review.
  - Responsibilities: fetch cards, CRUD cards, due cards, SM2 review update, undo.

- `LessonNoti`
  - Owner: Daily Lesson flow.
  - Responsibilities: current lesson card/mode, answer checking, media lookup, speech mode, mode progression, lesson SRS ratings.

- `TimerNoti`
  - Owner: Daily Lesson flow.
  - Responsibilities: stopwatch timing only.

- `Questnoti`
  - Owner: temporary lesson stats adapter.
  - Responsibilities: in-memory aggregate counts. Should be renamed or replaced.

- Standalone mode notifiers
  - Owners: individual study mode screens under `lib/ui/screens/studymode/`.
  - Responsibilities: fetch deck cards, shuffle options, validate answers, play media.

## Screen Flow Map

### Main Flow

1. `main.dart`
2. `DeckListScreen`
3. `CardListScreen`
4. Standalone mode picker in `CardListScreen`

### Standalone Practice Modes

- `Newwayreview`
- `BlankWordScreen`
- `Meanfuse`
- `WordSnap`
- `MindFeild`
- `EchoFuse`
- `EchoMatch`
- `Echospell`
- `NeuroPick`
- `WordPulse`
- `SoundNSight`
- `Synonymfield`
- `Synonympick`
- `PhoneMix`
- `Speechword`

### Daily Lesson Flow

1. `LearnModeScreen`
2. `LessonScreen`, `Learnlevel`, or `LessLearnMode`
3. `StartScreen`
4. Study mode switcher:
   - `MeanfuseUI`
   - `WordSnapUI`
   - `MindFeildUI`
   - `EchoSpellUI`
   - `EchoFuseUI`
   - `EchoMatchUI`
   - `NeuroPickUI`
   - `WordPulseUI`
   - `SoundNSightUI`
   - `SynonympickUI`
   - `SynonymfeildUI`
   - `SpeechWordUI`
   - `PhoneMixUI`
   - `ReviewUI`
5. `EndScreen`

## Database Ownership Map

### `decks`

- Owner: `DatabaseHelper`.
- Provider facade: `Deckmodel`.
- Used by: deck list, card media lookup, APKG import.

### `cards`

- Owner: `DatabaseHelper`.
- Provider facade: `Cardmodel` and `LessonNoti`.
- Used by: all study modes, SRS scheduling, achievements.

### Excluded Tables

The standalone database intentionally excludes:

- `player_profile`
- inventory
- RPG stats
- XP/gold storage
- quest tables

## Current Folder Structure

```text
lib/
  business/
    path_service.dart
    flashcard/
  data/
  theme/
  ui/
    lesson/
    screens/
  widget/
```

## Remaining Structure Decisions

- Consider moving APKG import from `DatabaseHelper` to `lib/data/anki_import_service.dart`.
- Consider renaming `Questnoti` to `LessonStatsNoti`.
- Consider moving `Achievement` under an optional `ui/screens/progress/` boundary or removing it from MVP.
- Consider renaming files with typos for long-term maintainability:
  - `progessIndicator.dart`
  - `mindfeild.dart`
  - `synonymfeildUI.dart`
  - `echomath.dart`

## Difficulty Estimate

- Boundary cleanup: medium.
- Provider split: medium to high.
- Portrait UI pass: high if all study modes must be polished.
- Runtime import/audio/speech validation: medium once tooling is allowed.
