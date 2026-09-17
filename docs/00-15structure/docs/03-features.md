# Core Features

## 1. Deck Import System
- Imports Anki `.apkg` packages `.apkg` files (picked via `file_picker`, or a bundled asset in testing mode).
- Unzips the package, opens the embedded Anki `collection` SQLite DB, and reads note `flds` mapped to `Flashcard` objects by Anki note-model (`lib/data/card_database/flashCard_Mapper.dart`).
- Extracts deck media (images/audio) into per-deck folders under `<documents>/anki/<folder>/`; the folder basename is stored on the deck (`Deck.media`).
- Decks and cards are registered in the `flashcards.db` SQLite database.

## 2. Spaced Repetition (SRS)
- Cards are scheduled with SM-2. `Cardmodel.updateCardAfterReview` uses `computeSM2` (`lib/business/flashcard/scheduler.dart`).
- The lesson flow additionally uses `updateCardReview` (`lib/business/flashcard/supermemo.dart`) for per-card ratings.
- Tracks intervals, repetitions, lapses, ease factors, and due dates; due cards are surfaced in the dashboard and the flashcard / lesson review modes.

## 3. Guided Lessons
- A lesson is a sequential session chaining study-mode "steps" over a set of cards, with a start screen, exercise steps, and an end screen (accuracy %, time, score).
- Fetch strategies are controlled by `LearnMode` (`daily`, `all`, `sm`, `shuffle`, `devMode`) and by level (`getByLevel`, complexity 1–7) or by a single `StudyMode` (`getByMode`).
- Tracking: `TimerNoti` (elapsed time + threshold label) and `Questnoti` (reviews/lapses/cards). Completed lessons are saved to SDK `HistoryLessonDao`.

## 4. Study Modes (Mini-Games)
14 study modes are routed per-deck via `_buildStudyModeScreen` in `lib/router/app_router.dart` and also surfaced from the Learn tab and the card-list drawer.

| Route mode | Widget | Prompt | Interaction |
|---|---|---|---|
| `newwayreview` | `Newwayreview` | Word (flip to meaning/image) | Swipe + 6-point SRS rating |
| `blankword` | `BlankWordScreen` | Meaning | Tap shuffled letters/words in order |
| `mindfield` | `MindFeild` | Meaning | Multiple choice (letter-shuffle distractors) |
| `wordsnap` | `WordSnap` | Meaning | Multiple choice (real-word distractors) |
| `wordpulse` | `WordPulse` | Image | Multiple choice (letter-variant distractors) |
| `phonemix` | `PhoneMix` | Words + IPAs | Match word–IPA pairs |
| `synonymfield` | `Synonymfield` | Synonym image | Multiple choice (letter-variant distractors) |
| `synonympick` | `Synonympick` | Synonym image | Multiple choice (real-word distractors) |
| `echospell` | `Echospell` | Audio + IPA | Tap shuffled letters in order |
| `echomatch` | `EchoMatch` | Audio + IPA | Multiple choice (letter-variant distractors) |
| `echofuse` | `EchoFuse` | Audio + IPA | Multiple choice (real-word distractors) |
| `soundandsight` | `SoundNSight` | Image + Audio | Tap shuffled letters in order |
| `neuropick` | `NeuroPick` | Image | Multiple choice (real-word distractors) |
| `speechword` | `Speechword` | Word + IPA | Speech-to-text pronunciation |

Study-mode logic is implemented as a `{name}Noti` `ChangeNotifier` per mode under `lib/ui/screens/studymode/`. Only `newwayreview` (flashcard) persists SRS review scores to the DB; the other modes provide in-session right/wrong feedback.

## 5. IELTS Reading Practice
- A reading-exercise module built on JSON assets under `assets/ielts/` (article `test/`, `question/`, `answer/`, `jsondictionary.json`, `picture/`).
- Parsers (`article_parser`, `question_parser`, `question_normalizer`, `answer_parser`, `reading_passage_parser`) turn the assets into `ParagraphGroup` question screens.
- Question types include select-from-list, multiple choice (ABC / True-False / Yes-No), checkbox, and input (table, diagram, note, flowchart, sentence, summary).
- The Reading tab exposes a navigate grid of passes by series/test/part/group. See `docs/00-15structure/docs/10-ielts.md` and `lib/ui/screens/ielts/IELTS_GUIDE.md`.

## 6. Penpal (Letter Writing)
- A pre-scripted letter-writing practice game. The user selects one of three fictional penpals, reads incoming letters, and writes replies (min length + required keywords checked by regex). Friendship increases on passing stages; attempts are limited per stage.

## 7. User Profile & Analytics
- Local user profile (name, avatar, email, phone) edited from the profile screen and persisted via `UserDao`.
- Analytics (`AnalyzeNotifier` facade): lesson stats/trends, card review stats + leech cards, and activity (daily usage, current/longest streak, monthly/yearly activity), rendered in the Analyze screen blocks.
- Session usage is tracked by `UsageTracker` and stored via `DailyUsageDao`.
