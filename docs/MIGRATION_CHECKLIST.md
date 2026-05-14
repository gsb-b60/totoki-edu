# Flashcard Module Migration Checklist

This checklist tracks the tasks required to extract the Flashcard module from "Crystal of English" into a standalone project or library.

## 1. Path Refactoring (Highest Priority)
Remove all hardcoded Android absolute paths and replace them with dynamic paths using `path_provider`.

- [ ] **`lib/flashcard/DailyLesson/dailyLesson/noti/lessonNoti.dart`**
    - [ ] `getImagePath()`: Remove `/data/user/0/com.example.mygame/app_flutter/anki/`
    - [ ] `getSynonymPath()`: Remove `/data/user/0/com.example.mygame/app_flutter/anki/`
    - [ ] `playSound()`: Remove `/data/user/0/com.example.mygame/app_flutter/anki/`
- [ ] **`lib/flashcard/quizzconverter/fctoquizz.dart`**
    - [ ] `GenQuestions()`: Remove `/data/user/0/com.example.mygame/app_flutter/anki/`
- [ ] **`lib/flashcard/screen/decklist/cardlistscreen.dart`**
    - [ ] `FlashCardItem`: Remove `/data/user/0/com.example.mygame/app_flutter/anki/`
- [ ] **Standalone Study Mode Notifiers**
    - [ ] `lib/flashcard/screen/studymode/echofuse/echofuseNoti.dart`: Refactor `playSound()`
    - [ ] `lib/flashcard/screen/studymode/echomatch/echomatchNoti.dart`: Refactor `playSound()`
    - [ ] `lib/flashcard/screen/studymode/echospell/echospellNoti.dart`: Refactor `playSound()`
    - [ ] `lib/flashcard/screen/studymode/neuropick/neuropickNoti.dart`: Refactor `getImagePath()`
    - [ ] `lib/flashcard/screen/studymode/sound&sight/sound&sightNoti.dart`: Refactor `getImagePath()` and `playSound()`
    - [ ] `lib/flashcard/screen/studymode/synonymfield/synonymfieldNoti.dart`: Refactor `getImagePath()` and `playSound()`
    - [ ] `lib/flashcard/screen/studymode/synonympick/synonympickNoti.dart`: Refactor `getImagePath()`
    - [ ] `lib/flashcard/screen/studymode/wordpulse/wordpulseNoti.dart`: Refactor `getImagePath()` and `playSound()`

## 2. Database Decoupling
Separate the Flashcard SRS logic from the Game's Player Profile logic.

- [ ] **Schema Separation**
    - [ ] Create a new `FlashcardDatabase` helper that only handles `decks` and `cards`.
    - [ ] Move `player_profile` table definition out of `learning_card.db` or rename the DB to `flashcards.db`.
- [ ] **Method Migration**
    - [ ] Move profile-related methods (`savePlayerProfileSlot`, etc.) to a separate `ProfileRepository`.
- [ ] **Anki Mapping Logic**
    - [ ] Encapsulate Anki Model IDs into a configuration file or a `Map` to avoid hardcoding IDs in the logic.

## 3. UI & Theme Decoupling
The UI is currently bound to the game's theme and shared components.

- [ ] **Theming**
    - [ ] Replace `AppColor` references with a local `FlashcardTheme` class or use `Theme.of(context)`.
    - [ ] Audit `lib/flashcard/DailyLesson/libWidget/` for direct game-asset imports.
- [ ] **Component Dependencies**
    - [ ] Decouple `ProgressBar` from its reliance on game-specific haptics if necessary.
    - [ ] Check `ReviewScreen` for hardcoded game-style button designs.

## 4. Asset Management
Ensure all required binary assets are bundled with the new project.

- [ ] **Icons & Graphics**
    - [ ] Migrate `assets/rep/rep0.png` through `rep5.png`.
    - [ ] Migrate `assets/illumode/*.png` illustrations.
- [ ] **Sample Data**
    - [ ] Include the default `.apkg` in the new project's assets and update the load path in `Deckmodel`.

## 5. Platform & Permissions Setup
The following must be configured in the host project:

- [ ] **Android (`AndroidManifest.xml`)**
    - [ ] `android.permission.RECORD_AUDIO` (for `speech_to_text`)
    - [ ] `android.permission.VIBRATE` (for haptics)
- [ ] **iOS (`Info.plist`)**
    - [ ] `NSSpeechRecognitionUsageDescription`
    - [ ] `NSMicrophoneUsageDescription`
- [ ] **Dependencies**
    - [ ] Ensure all 15+ external packages are added to the new `pubspec.yaml`.

## 6. Validation
- [ ] Import a standard Anki deck.
- [ ] Verify audio plays on both iOS and Android.
- [ ] Verify SM2 interval updates in the SQLite database after a review session.
- [ ] Test "Undo" functionality in `Cardmodel`.
