# Migration Progress

Status: static migration / staging workspace. This repository is not being treated as a runnable Flutter product yet.

## Completed

- Copied flashcard business models and SRS logic into `lib/business/flashcard/`.
- Copied Anki data helpers into `lib/data/`.
- Copied Daily Lesson flow into `lib/ui/lesson/`.
- Copied standalone study screens into `lib/ui/screens/`.
- Copied reusable lesson widgets into `lib/widget/`.
- Wired `main.dart` to initialize `PathService` and provide `Deckmodel`.
- Replaced source package imports with `package:totoki_extract/...`.
- Removed direct Flame usage from migrated code and from `pubspec.yaml`.
- Removed `PlayerProfile`, profile, user, vocab, and original game imports from active `lib/`.
- Removed hardcoded Android media paths and routed media path construction through `PathService`.
- Replaced original mixed database helper with flashcard-only `DatabaseHelper` using `flashcards.db`.
- Added a web/stub `DatabaseHelper` that keeps flashcard-only behavior.
- Generalized `flashCard_Mapper.dart` with configurable model mappings plus fallback field guessing.
- Removed duplicated `lib/ui/lesson/libWidget/` copies after normalizing imports to `lib/widget/`.
- Removed orphan `profilescreen/accountscreen.dart` from the migrated surface.
- Cleaned `pubspec.yaml` asset declarations to a single `assets/` root.

## Static Checks Performed

- `rg` scan for forbidden imports/strings:
  - `package:mygame`
  - `package:flame`
  - `flame_audio`
  - `PlayerProfile`
  - `player_profile`
  - original profile/user/vocab/components imports
  - `/data/user/0`
  - `com.example.mygame`
- Current result: no matches in active `lib/` or `pubspec.yaml`.

No Flutter, Dart, pub, analyzer, or run commands were used in this phase after the priority correction.

## Remaining Blockers

1. `LessonNoti` still owns a lot of per-mode logic and side effects in one provider. It is migrated, but not cleanly modular.
2. `EndScreen` performs `timer.stop()`, `CallQuest()`, and `updateCard()` from `build()`. This is likely to cause repeated side effects when rendered.
3. Several standalone notifiers force unwrap media folder lookups with `!`; missing media can still crash runtime flows.
4. `CardListScreen` and several study screens still use large fixed dimensions copied from the original app; portrait UX is only partially stabilized.
5. `Achievement` is still present. It is flashcard-derived, but it is adjacent to game/progression concepts and may be better kept optional.
6. `file_picker_stub.dart` remains in `lib/data/` but is not part of the active import graph. Decide whether to delete it or keep it as reference.
7. Platform permission files have not been audited in this static pass.
8. Runtime package resolution has not been reattempted by design.

## Likely Compile Surface Risks

These are static findings, not analyzer output:

1. Side-effectful `build()` in `lib/ui/lesson/screen/endscreen.dart` can cause repeated SRS writes.
2. `Flashcard.fromMap` casts `ease_factor` directly to `double?`; SQLite may return numeric values as `int` in some cases.
3. Several notifiers assume non-empty card lists before reading `_cards[0]`.
4. Several notifiers assume `getMediaFile(...)!` is non-null.
5. `Image.file(File(path))` calls need empty-path guards in several screens.
6. `LessonNoti.nextCard()` increments `currentLessIdx` before indexing `SetUpLessonList[currentLessIdx]`.
7. Global or long-lived `AudioPlayer` instances are not consistently disposed.
8. `speech_to_text` initialization and permissions remain runtime-dependent.
9. File/folder names containing `&` work on disk but increase import/path fragility.
10. Many copied UI classes define duplicate local names such as `ChoiceBtn` and `ReviewScreen`; valid across libraries, but easy to confuse during cleanup.

## Next Blocking File

`lib/ui/lesson/screen/endscreen.dart`

Reason: it is the highest-risk static side-effect point because it writes lesson results and updates SRS state during widget build.

## Estimated Stabilization Effort

- Import/dependency cleanup: mostly complete, 0.5 day for a careful final pass.
- Compile surface cleanup without Flutter tooling: 1-2 days.
- UI portrait stabilization: 2-4 days depending on desired polish.
- Runtime dependency and permission validation later: 1-2 days once toolchain execution is allowed.
