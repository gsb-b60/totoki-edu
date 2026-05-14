# Migration Checkpoint

Checkpoint date: 2026-05-14

Status: static migration checkpoint. The flashcard extraction is staged as a standalone Flutter project, but this checkpoint does not claim runtime or analyzer validation.

## Purpose

This checkpoint consolidates the current migration documents and records what has been completed, what remains risky, and how the next migration pass should proceed.

## Source Documents Reviewed

- `docs/ARCHITECTURE.md`
  - Original Crystal of English architecture.
  - Identifies the original Flutter plus Flame hybrid app and the flashcard module's former dependencies.
- `docs/flashcard-architecture.md`
  - Original flashcard module architecture.
  - Defines models, providers, SRS algorithms, Anki import flow, database schema, media layout, and extraction risks.
- `docs/migrationsettingsuggest.md`
  - Initial migration strategy and target folder mapping.
  - Defines the recommended extraction phases from foundation through validation.
- `docs/MIGRATION_CHECKLIST.md`
  - Original migration checklist.
  - Tracks required path, database, UI, asset, platform, dependency, and validation work.
- `docs/FLASHCARD_MODULE_MAP.md`
  - Current extracted module map.
  - Defines active app shell, path ownership, business/data/UI boundaries, provider ownership, screen flows, and structure decisions.
- `docs/UNRESOLVED_DEPENDENCIES.md`
  - Current dependency and coupling risk register.
  - Lists active package requirements, runtime-dependent packages, isolated game/profile couplings, and files needing rewrite or adapters.
- `docs/MIGRATION_PROGRESS.md`
  - Current migration status.
  - Records completed static cleanup, static checks performed, remaining blockers, likely compile risks, and next blocking file.

## Migration Scope

The migration extracts the flashcard learning system from the original Crystal of English game into this standalone project.

Included scope:

- Deck and card models.
- Card CRUD behavior.
- Anki `.apkg` import.
- Local media migration and lookup.
- Flashcard-only SQLite database.
- Standard and Daily Lesson SRS scheduling logic.
- Deck list, card list, standalone study modes, and Daily Lesson screens.
- Reusable flashcard widgets.
- Required assets under `assets/`.

Excluded scope:

- Flame game engine.
- RPG player profile.
- Inventory, gold, XP, battle, map, NPC, and quest persistence.
- Original game audio systems.
- Original game profile/user/vocab imports.

## Current Architecture Checkpoint

Current top-level ownership:

- `lib/main.dart`
  - Initializes `PathService`.
  - Provides `Deckmodel`.
  - Opens `DeckListScreen`.
- `lib/business/path_service.dart`
  - Owns document-directory and Anki media path construction.
- `lib/business/flashcard/`
  - Owns `Deck`, `Deckmodel`, `Flashcard`, `Cardmodel`, and SRS schedulers.
- `lib/data/`
  - Owns flashcard-only database helpers, web stub, Anki mapper, and complexity helper.
- `lib/ui/lesson/`
  - Owns Daily Lesson flow, lesson providers, and mode screens.
- `lib/ui/screens/`
  - Owns deck/card screens and standalone study modes.
- `lib/widget/`
  - Owns reusable lesson widgets.

Current database ownership:

- `decks` table remains owned by `DatabaseHelper` and surfaced through `Deckmodel`.
- `cards` table remains owned by `DatabaseHelper` and surfaced through `Cardmodel` and `LessonNoti`.
- `player_profile`, inventory, RPG stats, XP/gold storage, and quest tables are excluded from the standalone database.

## Completed Migration Work

The current static migration has completed these major items:

- Flashcard business models and SRS logic copied into `lib/business/flashcard/`.
- Anki data helpers copied into `lib/data/`.
- Daily Lesson flow copied into `lib/ui/lesson/`.
- Standalone study screens copied into `lib/ui/screens/`.
- Reusable lesson widgets copied into `lib/widget/`.
- `main.dart` wired to initialize `PathService` and provide `Deckmodel`.
- Source package imports replaced with `package:totoki_extract/...`.
- Direct Flame usage removed from migrated code and `pubspec.yaml`.
- `PlayerProfile`, profile, user, vocab, and original game imports removed from active `lib/`.
- Hardcoded Android media path construction routed through `PathService`.
- Original mixed database helper replaced with flashcard-only `DatabaseHelper` using `flashcards.db`.
- Web/stub `DatabaseHelper` added for flashcard-only behavior on non-IO surfaces.
- `flashCard_Mapper.dart` generalized with configurable model mappings plus fallback field guessing.
- Duplicate `lib/ui/lesson/libWidget/` copies removed after imports were normalized to `lib/widget/`.
- Orphan `profilescreen/accountscreen.dart` removed from the migrated surface.
- `pubspec.yaml` asset declarations cleaned to a single `assets/` root.

## Static Verification Already Performed

The documented static scan checked for these forbidden imports and strings:

- `package:mygame`
- `package:flame`
- `flame_audio`
- `PlayerProfile`
- `player_profile`
- Original profile/user/vocab/components imports
- `/data/user/0`
- `com.example.mygame`

Current documented result: no matches in active `lib/` or `pubspec.yaml`.

Important limitation: no Flutter, Dart, pub, analyzer, or runtime commands were used during this checkpoint phase.

## Active Dependencies

The extracted module currently depends on:

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

Removed dependencies:

- `flame`
- `flame_tiled`
- `flame_audio`

## Runtime-Dependent Areas

These areas cannot be signed off by static review alone:

- APKG file selection through `file_picker`.
- SQLite behavior through `sqflite`.
- APKG extraction through `archive` and `flutter_archive`.
- Media copy and lookup through app documents storage.
- Audio playback through `audioplayers`.
- Speech recognition through `speech_to_text`.
- Haptic feedback through `vibration`.
- Android and iOS permissions.

## Remaining Blockers

1. `lib/ui/lesson/screen/endscreen.dart`
   - Highest-risk file.
   - It currently performs timer stop, quest/stat updates, and SRS updates from `build()`.
   - This can repeat side effects across rebuilds.
2. `lib/ui/lesson/dailyLesson/noti/lessonNoti.dart`
   - Still owns too much per-mode logic and side effects.
   - Needs smaller mode-specific controllers or adapters.
   - Needs bounds checks and null-safe media access.
3. Standalone study mode notifiers
   - Several force unwrap media folder lookups.
   - Missing media can still crash runtime flows.
4. `lib/ui/screens/decklist/cardlistscreen.dart`
   - Still uses large fixed dimensions copied from the original app.
   - Needs portrait-first layout stabilization and media guards.
5. `Achievement`
   - Still present as a flashcard-derived progress feature.
   - Should remain optional or be removed from a pure SRS MVP.
6. `lib/data/file_picker_stub.dart`
   - Present but not part of the active import graph.
   - Decide whether to delete it or keep it as reference.
7. Platform permission files
   - Not yet audited.
8. Runtime package resolution
   - Not reattempted by design in the static phase.

## Likely Compile And Runtime Risks

- `EndScreen` may perform repeated SRS writes because side effects happen during widget build.
- `Flashcard.fromMap` casts `ease_factor` directly to `double?`; SQLite can return numeric values as `int`.
- Several notifiers assume card lists are non-empty before reading `_cards[0]`.
- Several notifiers assume `getMediaFile(...)!` is non-null.
- `Image.file(File(path))` calls need empty-path or missing-file guards.
- `LessonNoti.nextCard()` increments `currentLessIdx` before indexing `SetUpLessonList[currentLessIdx]`.
- Global or long-lived `AudioPlayer` instances are not consistently disposed.
- `speech_to_text` initialization and permission handling remain runtime-dependent.
- File and folder names containing `&` work on disk but increase import/path fragility.
- Duplicate local class names such as `ChoiceBtn` and `ReviewScreen` are legal across libraries but increase cleanup confusion.

## Next Migration Pass

Recommended order:

1. Fix `EndScreen` lifecycle side effects.
   - Move result submission out of `build()`.
   - Guard completion with a one-time flag.
   - Ensure timer, stats, and SRS writes run once per lesson completion.
2. Harden card and media access.
   - Add empty-list guards before indexing cards.
   - Replace force unwrap media calls with null-safe fallbacks.
   - Add missing-file handling for image and audio paths.
3. Harden data mapping.
   - Normalize SQLite numeric values before assigning `ease_factor`.
   - Keep Anki mapper fallback behavior intact.
4. Stabilize Daily Lesson provider boundaries.
   - Split or adapt per-mode logic out of `LessonNoti` where practical.
   - Keep API compatibility until UI cleanup is complete.
5. Stabilize main deck and study UI.
   - Prioritize portrait layouts.
   - Remove large fixed dimensions where they block normal phone UX.
6. Audit platform configuration.
   - Android: `RECORD_AUDIO` and `VIBRATE`.
   - iOS: microphone and speech recognition usage descriptions.
7. Run tooling validation when allowed.
   - `flutter pub get`
   - `dart analyze`
   - targeted widget/unit tests if available
   - manual APKG import test
   - audio playback test
   - speech mode permission test
   - SM2 persistence check in SQLite

## Validation Gates

Gate 1: Static isolation

- No `package:flame`, `flame_audio`, or game package imports in active flashcard code.
- No `PlayerProfile`, `player_profile`, or original game persistence references.
- No hardcoded `/data/user/0` media paths.
- `pubspec.yaml` has no Flame dependencies and uses normalized asset declarations.

Current status: documented as passed.

Gate 2: Compile readiness

- `flutter pub get` resolves dependencies.
- `dart analyze` reports no blocking errors.
- Conditional database export works on supported targets.
- Platform stubs do not break compilation.

Current status: not yet run.

Gate 3: Data flow validation

- A standard Anki deck imports successfully.
- Deck and card records are written into `flashcards.db`.
- Media files are copied to the `PathService` Anki root.
- Imported image and audio references resolve from deck media folders.

Current status: not yet run.

Gate 4: Study flow validation

- Deck list opens.
- Card list opens.
- Standalone review updates SRS data.
- Daily Lesson completes once without repeated writes.
- Undo behavior still works through `Cardmodel`.

Current status: not yet run.

Gate 5: Platform behavior validation

- Audio plays on Android and iOS.
- Speech recognition initializes only after permissions are granted.
- Vibration degrades gracefully on unsupported platforms.
- File picker can select APKG files on target platforms.

Current status: not yet run.

## Checkpoint Decision

The migration is past the initial extraction and static decoupling phase. The project should now be treated as a staged standalone flashcard app that needs compile hardening, lifecycle cleanup, media safety, and runtime validation.

Do not reintroduce original game systems to make missing behavior compile. Any required progress, stats, or profile behavior should be flashcard-specific and should live behind flashcard-owned providers or repositories.

## Immediate Next File

Start with:

```text
lib/ui/lesson/screen/endscreen.dart
```

Reason: it is the highest-risk point for repeated writes because it performs lesson completion side effects during widget build.
