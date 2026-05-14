# Migration Setting & Strategy Suggestions

This document provides a roadmap and technical recommendations to ensure the successful migration of the Flashcard module from "Crystal of English" into this standalone project.

## 1. Current State Assessment

*   **Infrastructure**: `pubspec.yaml` already contains most required dependencies (Provider, Sqflite, Audioplayers, etc.).
*   **Assets**: Illustration (`illumode`) and reputation (`rep`) assets are already present in the `assets/` directory.
*   **Structure**: A clean top-level directory structure (`lib/business`, `lib/data`, `lib/ui`, `lib/widget`) has been initialized.
*   **Missing**: Core logic files, database helpers, and asset registration in `pubspec.yaml`.

## 2. Structural Recommendations

### 2.1 Clean Directory Mapping
To maintain a modular architecture, I recommend the following mapping for the files described in `flashcard-architecture.md`:

| Source Path (Original) | Target Path (Extracted) | Purpose |
| :--- | :--- | :--- |
| `lib/flashcard/business/` | `lib/business/flashcard/` | Core models (Card, Deck) and SRS logic. |
| `lib/flashcard/DailyLesson/` | `lib/ui/lesson/` | Daily lesson UI and notifiers. |
| `lib/flashcard/screen/` | `lib/ui/screens/` | Standalone study mode screens. |
| `lib/data/flashcard/` | `lib/data/` | Database and Anki mapping logic. |
| `lib/flashcard/DailyLesson/libWidget/`| `lib/widget/` | Reusable UI components. |

### 2.2 Theme Bridge
The `lib/theme/appTheme.dart` contains many game-specific colors (e.g., `greenPrimary`, `redPrimary`). 
*   **Action**: Create a `FlashcardTheme` class or extension that maps these specific colors to semantic names (e.g., `correctAnswerColor`, `wrongAnswerColor`) to decouple the logic from the game's naming convention.

## 3. Critical Technical Refactoring

### 3.1 Dynamic Path Injection (Priority 1)
As noted in the `MIGRATION_CHECKLIST.md`, hardcoded paths like `/data/user/0/...` must be removed.
*   **Suggestion**: Create a `PathService` or a `StorageConfig` class that initializes paths using `path_provider` at app startup. 
*   **Implementation**: Inject this service into the `LessonNoti` and `DatabaseHelper` instead of calling `getApplicationDocumentsDirectory()` repeatedly.

### 3.2 Database Isolation
The original `DatabaseHelper` is coupled with `player_profile`.
*   **Suggestion**: Implement a `FlashcardDatabase` helper that focuses *strictly* on the `decks` and `cards` tables. 
*   **Strategy**: Use the existing `database_helper_io_impl.dart` but strip out all logic related to inventory, player stats, and save slots.

### 3.3 Anki Mapper Generalization
The `Flashcard_Mapper.dart` is dependent on specific Anki `mid` (Model IDs).
*   **Suggestion**: If this project aims to support more than the default IELTS deck, refactor the mapper to use a configuration map or a "Guess Mapping" strategy based on field names (e.g., if a field contains `[sound:...]`, it's an audio field).

## 4. Asset Configuration

The `pubspec.yaml` needs to be updated to register the migrated assets. Add the following:

```yaml
flutter:
  assets:
    - assets/rep/
    - assets/illumode/
    # Add the sample deck once it is moved to the assets folder
    # - assets/anki-deck/
```

## 5. Implementation Roadmap

1.  **Phase 1: Foundation**: 
    *   Register assets and configure the `PathService`.
    *   Port `AppTheme` and ensure it meets the module's needs.
2.  **Phase 2: Data Layer**: 
    *   Migrate `DatabaseHelper` (Refactored) and `Flashcard_Mapper`.
    *   Verify database initialization on a fresh install.
3.  **Phase 3: Business Logic**: 
    *   Migrate `Flashcard`, `Deck`, `Cardmodel`, and `Deckmodel`.
    *   Integrate the SRS schedulers (`scheduler.dart` and `supermemo.dart`).
4.  **Phase 4: UI & Notifiers**:
    *   Migrate `LessonNoti` and the `StudyMode` notifiers.
    *   Port the UI screens one by one, starting with the `DeckListScreen`.
5.  **Phase 5: Validation**:
    *   Test Anki import.
    *   Verify audio playback and SM2 interval updates.

## 6. Success Indicators
*   [ ] Zero hardcoded absolute paths in `lib/`.
*   [ ] No imports from `package:flame` or game-related components in the Flashcard logic.
*   [ ] Anki decks import successfully with media.
*   [ ] SRS intervals are correctly persisted in the SQLite database.
