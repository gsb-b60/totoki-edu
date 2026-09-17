# IELTS Training System

## Data (`assets/ielts/`)

| Directory | Naming | Content | Reference Doc |
|-----------|--------|---------|---------------|
| `assets/ielts/test/` | `{test}-{section}-{passage}.json` (e.g. `1-1-3.json`) | Reading passage text: word-level tokens, sentence annotations, explanations | [jsonstructure-test.md](../../ietls/jsonstructure-test.md) |
| `assets/ielts/question/` | `{test}-{section}-{passage}.json` | Reading questions: options, input placeholders, structured smart version | [jsonstructure-question.md](../../ietls/jsonstructure-question.md) |
| `assets/ielts/answer/` | `{test}-{section}.json` (e.g. `1-1.json`) | Answer keys for all 4 skills (listening/reading/writing/speaking) + user responses | [jsonstructure-answer.md](../../ietls/jsonstructure-answer.md) |
| `assets/ielts/jsondictionary.json` | — | Flat word-definition map `{word: {word_bin, quick_def, is_starred}}` | — |

**Naming pattern:** `test/` and `question/` use `{test}-{section}-{passage}.json` (20 tests × 4 sections × 3 passages = 240 files). `answer/` omits passage: `{test}-{section}.json` (80 files). Hardcoded path currently: `assets/ielts/test/1-1-1.json`.

## Flutter UI (`lib/ui/screens/ielts/`)

| File | Purpose |
|------|---------|
| `ielts_training.dart` | Entry screen with `BottomNavigationBar` switching between 4 skill tabs |
| `tabs/reading_tab.dart` | Reading tab — navigates to `PassagesScreen` |
| `tabs/listening_tab.dart` | Listening tab |
| `tabs/writing_tab.dart` | Writing tab |
| `tabs/speaking_tab.dart` | Speaking tab |
| `passages/passages_screen.dart` | Full reading passage: tappable article + MCQ questions + answer review overlay |
| `passages/noti/readingNoti.dart` | `ChangeNotifier`: loads passage text + dictionary in parallel via `Future.wait`; drives `passages_screen` |
| `widgets/ielts_card.dart` | Reusable card widget |

## Key data flow (Reading)

1. `readingNoti.loadPassage()` fires `Future.wait` on `test/1-1-1.json` (passage) and `jsondictionary.json` (word-lookup map)
2. Article text is extracted from nested `section > items > paragraph > sentence` structure and joined into a plain string
3. `passages_screen.dart` renders the article as `RichText` with per-word `TapGestureRecognizer` — tapping a word looks it up in the dictionary map (case-insensitive) and pops up an `OverlayEntry` card with the definition
4. MCQ questions below the passage are hardcoded in `readingNoti.dart` (to be migrated to `question/{id}.json`)
5. On answer submit, a `ReviewScreen` slides up via `AnimatedPositioned`

**Note:** The reference JSON-structure docs live under `docs/ietls/` (intentional naming).
