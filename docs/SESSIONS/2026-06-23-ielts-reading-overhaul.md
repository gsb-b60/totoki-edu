# Session Plan — IELTS Reading Overhaul + Mascot + Heatmap

## Goal
Transform the IELTS Reading section from hardcoded MC-only prototype to a full-featured practice system with all question types, answer highlighting, touchable answers, separate RSR data layer, a mascot, and daily heatmap tracking.

---

## Phase 1 — Data Layer Refactor (RSR Separation)

### 1.1 Create SQLite Tables for IELTS Progress
- `ielts_passages` — metadata for each passage (book, test, passage, title)
- `ielts_answers` — per-question tracking (question_id, book, test, passage, user_answer, correct_answer, judgement, answered_at)
- Seed from existing answer JSON files on first launch

### 1.2 Build `IeltsRepository` (lib/data/ielts_repository.dart)
- Wraps `DatabaseHelper` for IELTS-specific CRUD
- `loadPassage(book, test, passage)` → loads test JSON
- `loadQuestions(book, test, passage)` → loads question JSON
- `loadAnswers(book, test)` → loads answer JSON (or DB)
- `saveAnswer(question_id, user_answer, judgement)` → persists to DB
- `getHistory(book, test)` → retrieves past answers

### 1.3 Create `AnswerService` (lib/services/answer_service.dart)
- Normalizes answer comparison (pipe-separated alternatives, case-insensitive)
- Judges correct/incorrect per question type
- Calculates section band score

---

## Phase 2 — Question Type Renderer System

### 2.1 Question Type Registry (lib/ui/screens/ielts/questions/)
```
questions/
├── question_parser.dart       # Parse question JSON → QuestionModel
├── question_renderer.dart     # Dispatcher: type → widget
├── models/
│   └── question_model.dart    # Unified QuestionModel
├── types/
│   ├── mcq_widget.dart        # Multiple Choice (A/B/C/D)
│   ├── tfng_widget.dart       # True/False/Not Given
│   ├── yng_widget.dart        # Yes/No/Not Given
│   ├── summary_select_widget.dart  # Select from list (gap-fill)
│   ├── match_heading_widget.dart   # Matching headings to paragraphs
│   ├── match_feature_widget.dart   # Matching features/endings
│   ├── fill_blank_widget.dart      # Sentence/note completion
│   └── table_completion_widget.dart # Table/flow-chart completion
```

### 2.2 Question Types to Support (from JSON data)
| JSON `type` | Widget | Answer Format |
|---|---|---|
| `select-summary-given-list` | `SummarySelectWidget` | Letter (A-T) |
| `select-given-list` | `SelectFromListWidget` | Letter (A-H) |
| `mcq` (implied) | `McqWidget` | A/B/C/D |
| `yes-no-not-given` | `YesNoNotGivenWidget` | YES/NO/NOT GIVEN |
| `true-false-not-given` | `TrueFalseNotGivenWidget` | TRUE/FALSE/NOT GIVEN |
| `match-list-to-end` | `MatchHeadingWidget` | Letter → paragraph |
| `match-to-end` | `MatchFeatureWidget` | Letter → feature |
| `sentence-completion` | `FillBlankWidget` | Word/phrase |
| `summary-completion` | `FillBlankWidget` | Word from passage |
| `note-completion` | `FillBlankWidget` | Word/phrase |
| `table-completion` | `TableCompletionWidget` | Words/phrases |
| `flow-chart-completion` | `TableCompletionWidget` | Words/phrases |
| `short-answer` | `ShortAnswerWidget` | Words/phrases |

### 2.3 QuestionModel Unified Type
```dart
class QuestionModel {
  final int start, end;
  final String type;
  final String? title;
  final List<String>? options;       // For selection types
  final List<QuestionItem> items;    // Question body with input slots
  final List<int>? correctAnswers;   // From answer JSON
  final bool? isExample;
}
```

---

## Phase 3 — Answer Highlighting in Passage

### 3.1 Leverage Existing Test JSON Structure
Each sentence in `assets/ielts/test/{b}-{t}-{p}.json` already has:
- `question_ids: [1, 2, ...]` — which questions this sentence answers
- `explain: "Q1: ..."` — explanation text
- `selected_words: "word1,word2,..."` — keywords in the sentence
- `reason: true/false` — whether this sentence is answer-relevant

### 3.2 Passage Renderer Upgrade (`passages_screen.dart`)
- Parse test JSON sentences with `question_ids`
- Highlight sentences that contain answers (subtle background tint)
- On tap of highlighted sentence → show tooltip with:
  - Question number
  - The explanation (`explain` field)
  - Highlighted keywords (`selected_words`)
- Color-code: correct answers green, wrong answers red (after submission)

### 3.3 Touchable Answer Flow
1. User reads passage, taps highlighted sentence → sees explanation tooltip
2. User answers questions below
3. After submit → correct answer highlights in passage turn green, wrong turns red
4. User can tap highlighted area to review rationale

---

## Phase 4 — Mascot System

### 4.1 Mascot Design
- Name: **Totoki** (use existing branding)
- Character: A small friendly owl/book creature (use existing `assets/illumode/` or create new)
- States: idle, thinking, correct, wrong, streak, level-up

### 4.2 Mascot Widget (`lib/widget/mascot/`)
```dart
mascot/
├── mascot_widget.dart          # Animated mascot with state machine
├── mascot_notifier.dart        # MascotState (idle/happy/sad/celebrate/thinking)
├── mascot_animations.dart     # Animation definitions (scale, bounce, float)
└── mascot_sounds.dart         # Sound triggers mapped to states
```

### 4.3 Mascot Behaviors
| Event | Mascot Reaction | Sound |
|---|---|---|
| Correct answer | Happy bounce + sparkle | `correct.mp3` |
| Wrong answer | Sad wobble + head shake | `wrong.mp3` |
| Streak (3+) | Celebration dance + confetti | `streak.mp3` |
| Idle (no activity) | Gentle floating/breathing | — |
| Session complete | Level-up animation | `finish.mp3` |
| Thinking (user reading) | Tilting head, blinking | — |

### 4.4 Integration Points
- Bottom-right corner of IELTS Reading screen (always visible)
- Dashboard screen (larger version with stats)
- Study mode screens (reuse existing mascot)

---

## Phase 5 — Daily Study Heatmap

### 5.1 Activity Tracking Table (SQLite)
```sql
CREATE TABLE study_activity (
  date TEXT NOT NULL PRIMARY KEY,         -- "2026-06-23"
  cards_reviewed INTEGER DEFAULT 0,
  ielts_questions_answered INTEGER DEFAULT 0,
  study_minutes REAL DEFAULT 0,
  streak INTEGER DEFAULT 0
);
```

### 5.2 Heatmap Widget (`lib/widget/heatmap/`)
```dart
heatmap/
├── heatmap_widget.dart         # GitHub-style contribution grid
├── heatmap_notifier.dart       # Loads/saves activity data
├── month_strip.dart            # One row = one week, col = day
└── day_cell.dart               # Colored square based on intensity
```

### 5.3 Intensity Scale
| Level | Color | Criteria |
|---|---|---|
| 0 | Dark gray | No activity |
| 1 | Light green | 1-5 items |
| 2 | Medium green | 6-15 items |
| 3 | Dark green | 16-30 items |
| 4 | Teal/Accent | 30+ items |

### 5.4 Activity Logger Service (`lib/services/activity_service.dart`)
- Logs every card review, IELTS question answered, study session
- Updates `study_activity` table in real-time
- Computes current streak from consecutive-day activity
- Exposes weekly/monthly aggregates for heatmap

---

## Phase 6 — Integration

### 6.1 IELTS Reading Flow (Rewrite)
```
ReadingTab
  └── PassageSelector (book/test/passage grid)
       └── PassagesScreen
            ├── PassageArticle (highlighted + touchable)
            ├── QuestionPanel (type-dispatched widgets)
            ├── MascotOverlay (bottom-right)
            └── ReviewScreen (score + highlighted answers)
```

### 6.2 Navigation
- ReadingTab: Show list of available passages (instead of hardcoded cards)
- Each passage shows: book-test-passage title, difficulty, completion %
- On tap → load passage, questions, answers from JSON/DB

### 6.3 Dashboard Integration
- Add heatmap to dashboard (below stats)
- Add mascot to dashboard
- Show IELTS-specific stats: tests completed, avg band score

---

## Execution Order

| Step | Task | Est. Time |
|---|---|---|
| 1 | Create SQLite tables + `IeltsRepository` | 1h |
| 2 | Build `AnswerService` + answer normalization | 30m |
| 3 | Build `QuestionModel` + `question_parser.dart` | 45m |
| 4 | Implement MCQ widget (refactor existing code) | 30m |
| 5 | Implement TFNG/YNG widgets | 30m |
| 6 | Implement summary-select from list widget | 30m |
| 7 | Implement matching headings/features widgets | 45m |
| 8 | Implement fill-blank and table completion widgets | 45m |
| 9 | Upgrade passage renderer with highlight + touch | 1h |
| 10 | Build mascot system (widget + notifier + animations) | 1.5h |
| 11 | Build heatmap system (widget + notifier + activity service) | 1h |
| 12 | Wire everything together in new Reading flow | 1h |
| 13 | Add mascot to dashboard + study modes | 30m |
| 14 | Polish, `flutter analyze`, edge cases | 1h |

**Total**: ~10-12h

---

## Key Files to Create/Modify

**New Files:**
- `lib/data/ielts_repository.dart`
- `lib/services/answer_service.dart`
- `lib/services/activity_service.dart`
- `lib/ui/screens/ielts/questions/question_parser.dart`
- `lib/ui/screens/ielts/questions/question_renderer.dart`
- `lib/ui/screens/ielts/questions/models/question_model.dart`
- `lib/ui/screens/ielts/questions/types/mcq_widget.dart`
- `lib/ui/screens/ielts/questions/types/tfng_widget.dart`
- `lib/ui/screens/ielts/questions/types/yng_widget.dart`
- `lib/ui/screens/ielts/questions/types/summary_select_widget.dart`
- `lib/ui/screens/ielts/questions/types/match_heading_widget.dart`
- `lib/ui/screens/ielts/questions/types/match_feature_widget.dart`
- `lib/ui/screens/ielts/questions/types/fill_blank_widget.dart`
- `lib/ui/screens/ielts/questions/types/table_completion_widget.dart`
- `lib/ui/screens/ielts/questions/types/short_answer_widget.dart`
- `lib/widget/mascot/mascot_widget.dart`
- `lib/widget/mascot/mascot_notifier.dart`
- `lib/widget/mascot/mascot_animations.dart`
- `lib/widget/mascot/mascot_sounds.dart`
- `lib/widget/heatmap/heatmap_widget.dart`
- `lib/widget/heatmap/heatmap_notifier.dart`
- `lib/widget/heatmap/month_strip.dart`
- `lib/widget/heatmap/day_cell.dart`

**Modified Files:**
- `lib/ui/screens/ielts/tabs/reading_tab.dart` (passage selector)
- `lib/ui/screens/ielts/passages/passages_screen.dart` (major rewrite)
- `lib/ui/screens/ielts/passages/noti/readingNoti.dart` (use JSON data)
- `lib/ui/screens/dashboard/dashBoard.dart` (add heatmap + mascot)
- `lib/data/database_helper.dart` (add IELTS + activity tables)
- `lib/main.dart` (register new providers)
