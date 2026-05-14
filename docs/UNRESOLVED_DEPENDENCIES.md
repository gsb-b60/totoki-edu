# Unresolved Dependencies

This document lists remaining dependency and coupling risks after static migration. It does not reflect runtime validation.

## Active Package Requirements

Current imports require these packages:

- `flutter`
- `provider`
- `sqflite`
- `path`
- `path_provider`
- `file_picker`
- `archive`
- `flutter_archive`
- `intl`
- `audioplayers`
- `flip_card`
- `swipable_stack`
- `speech_to_text`
- `vibration`

`flame`, `flame_tiled`, and `flame_audio` are no longer required by the migrated flashcard module.

## Runtime-Dependent Packages

- `file_picker`: required for APKG import. Needs platform picker support.
- `sqflite`: required for `flashcards.db` and reading Anki collection databases.
- `flutter_archive` and `archive`: required for APKG extraction.
- `audioplayers`: required for card audio playback.
- `speech_to_text`: required for Speech Word mode. Needs microphone and speech permissions.
- `vibration`: used by lesson feedback. Needs platform support; should degrade gracefully.

## Isolated Game/Profile Couplings

### Quest/Stats

- Current file: `lib/ui/lesson/dailyLesson/noti/questNoti.dart`
- Previous coupling: original user database and quest stats.
- Current state: replaced with an in-memory lesson stats notifier.
- Recommendation: rename to `LessonStatsNoti` later. Keep as adapter until UI imports are cleaned.
- Difficulty: low.

### Achievement

- Current files:
  - `lib/ui/screens/decklist/achievement/achievement.dart`
  - `lib/ui/screens/decklist/achievement/achievementNoti.dart`
  - `lib/ui/screens/decklist/achievement/achievementUI.dart`
- Coupling type: not currently connected to game services, but conceptually derived from progression/reputation UI.
- Current state: retained because it only reads flashcard reps/complexity and uses `assets/rep/`.
- Recommendation: optional module. Remove from first product shell if pure SRS scope is preferred.
- Difficulty: low to medium.

### Profile/User Systems

- Previous files/imports: original profile, user, quest, vocab, and `PlayerProfile` references.
- Current state: removed from active import graph.
- Recommendation: do not reintroduce; any user progress should be flashcard-specific.
- Difficulty: complete for current static surface.

## Files Needing Rewrite Or Adapter

- `lib/ui/lesson/screen/endscreen.dart`
  - Needs lifecycle-safe result submission, probably via `initState` or provider method guarded by a completion flag.

- `lib/ui/lesson/dailyLesson/noti/lessonNoti.dart`
  - Needs smaller mode-specific controllers or adapters.
  - Needs bounds checks and null-safe media access.

- `lib/ui/screens/decklist/cardlistscreen.dart`
  - Needs portrait layout rewrite and better media existence checks.

- `lib/ui/screens/studymode/*/*Noti.dart`
  - Needs consistent `PathService` media helpers and null-safe media handling.

- `lib/business/flashcard/Flashcard.dart`
  - `Cardmodel` currently owns DB persistence directly. This is acceptable for staging but should eventually move behind a repository.

- `lib/business/flashcard/Deck.dart`
  - `Deckmodel` delegates import to `DatabaseHelper`, but import workflow should eventually become a dedicated `AnkiImportService`.

## Pubspec Notes

- No git dependencies found.
- No local path dependencies found.
- No duplicate dependency keys found by inspection.
- Asset declaration is normalized to:

```yaml
flutter:
  assets:
    - assets/
```

## Platform Configuration Still Unverified

The following should be checked later when runtime validation resumes:

- Android `RECORD_AUDIO` for `speech_to_text`.
- Android `VIBRATE` for `vibration`.
- iOS microphone and speech recognition usage descriptions.
- File picker platform behavior for APKG selection.
- Audio playback behavior from app documents directory.

## Estimated Difficulty

- Dependency isolation: low, mostly complete.
- Runtime permission cleanup: medium.
- Replacing `Questnoti` naming/API: low.
- Separating Anki import from database helper: medium.
- Hardening all media/audio modes: medium to high.
