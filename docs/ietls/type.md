# Question Type Handling

## Overview

`loadPassage()` in `readingNoti.dart` loads a passage and its questions from JSON files, then parses each question group into a list of `ParagraphGroup` objects based on the question type. The UI (`passages_screen.dart`) dispatches to the appropriate question widget using `pg.type`.

### File paths

```
assets/ielts/test/{seriesId}-{testId}-{part}.json       → article text
assets/ielts/question/{seriesId}-{testId}-{part}.json   → question data
assets/ielts/answer/{seriesId}-{testId}.json            → correct answers
assets/ielts/jsondictionary.json                        → word definitions
```

### API

```dart
final noti = context.read<ReadingNoti>();
await noti.loadPassage(
  seriesId: 1,      // 1–20
  testId: 1,         // 1–4
  part: 1,           // 1–3
  questionGroup: 1,  // 1–2 (index into test_question array)
);
```

---

## `ParagraphGroup` fields

| Field | Type | Description |
|-------|------|-------------|
| `displayText` | `String` | Question text with `<input>` replaced by `___` |
| `options` | `List<String>` | Answer choices (empty for input types) |
| `answers` | `List<int>` | 0-based indices into `options` for correct answers |
| `textAnswers` | `List<String>` | Correct text answers (only for input types) |
| `type` | `String` | One of the 17 question types |
| `constraint` | `String?` | Word limit (only for input types, e.g. `"NO MORE THAN THREE WORDS"`) |

---

## Type dispatch table

The UI selects a widget based on `pg.type` in `_buildQuestionPanel()` (`passages_screen.dart:292`):

| `type` value | Widget | State storage |
|---|---|---|
| `select-*` (6 types) | `SelectSummaryGivenList` | `_selections: List<int?>` |
| `option-abc` | `OptionChoice` | `_selections[0]: int?` |
| `option-true-false` | `OptionChoice` | `_selections[0]: int?` |
| `option-yes-no` | `OptionChoice` | `_selections[0]: int?` |
| `checkbox` | `CheckboxWidget` | `_selections: List<int?>` |
| `input-*` (7 types) | `InputAnswer` | `_textInputs: List<String>` |

---

## Group: `select-*` (6 types)

**Types:** `select-summary-given-list`, `select-given-list`, `select-section-given-list`, `select-given-diagram`, `select-flowchart-given-list`, `select-section`

**Widget:** `SelectSummaryGivenList` (`questionType/select_summary_given_list.dart`)

**How it works:**
- `body.items` contains strings with `<input>` placeholders
- `body.list` contains the word bank the user chooses from
- Each `<input>` in an item becomes one blank → one entry in `answers`
- Answers are single letters (A–Z) in the answer file → mapped to 0–25 index
- Items with `type: "example"` are skipped

**JSON shape:**
```json
{
  "start": 1, "end": 5, "type": "select-summary-given-list",
  "body": {
    "list": ["word1", "word2", "word3"],
    "items": [
      { "type": "example", "items": "example <input>" },
      "Sentence with <input> and <input>."
    ]
  }
}
```

---

## Group: `option-abc`

**Widget:** `OptionChoice` (`questionType/option_choice.dart`)

**How it works:**
- `body.items` is an array of maps, each with `title` (the question) and `options` (the choices)
- Each item → one `ParagraphGroup` with one answer index
- Answer is a single letter in answer file (A=0, B=1, C=2...)
- Shown as a circle-radio list; tapping selects, tapping again does nothing

**JSON shape:**
```json
{
  "start": 31, "end": 36, "type": "option-abc",
  "body": {
    "items": [
      {
        "title": "Compared with today's museums, those of the past",
        "options": [
          "did not present history in a detailed way.",
          "were not primarily intended for the public.",
          "were more clearly organised.",
          "preserved items with greater care."
        ]
      }
    ]
  }
}
```

---

## Group: `option-true-false` / `option-yes-no`

**Widget:** `OptionChoice` (`questionType/option_choice.dart`)

**How it works:**
- `body.items` is an array of statement strings
- Each statement → one `ParagraphGroup` with one answer index
- Options are hardcoded: `["True", "False", "Not Given"]` or `["Yes", "No", "Not Given"]`
- Answer in file is text ("TRUE"/"FALSE"/"NOT GIVEN" or "YES"/"NO"/"NOT GIVEN") → mapped to 0/1/2

**JSON shape:**
```json
{
  "start": 16, "end": 22, "type": "option-yes-no",
  "body": {
    "items": [
      "Marie Curie's husband was a joint winner of both Marie's Nobel Prizes.",
      "Marie became interested in science when she was a child."
    ]
  }
}
```

---

## Group: `checkbox`

**Widget:** `CheckboxWidget` (`questionType/checkbox_widget.dart`)

**How it works:**
- `body.title` is the prompt (e.g. "Which THREE of the following...")
- `body.options` is the list of choices
- `desc.quantity` is how many must be selected
- Answers span `start` to `end` in the answer file — each is a single letter
- Checkboxes track a `List<int?>` where each entry holds the selected option index
- Tapping a selected option deselects it (sets to `null`)
- Shows remaining count (e.g. "Select 3 options (2 remaining)")

**JSON shape:**
```json
{
  "start": 26, "end": 28, "type": "checkbox",
  "desc": { "quantity": 3, "optionRange": ["A", "F"] },
  "body": {
    "title": "Which THREE of the following factors are mentioned?",
    "options": [
      "the number of unregistered zoos in the world",
      "the lack of money in developing countries",
      "the actions of the Isle of Wight local council",
      "the failure of the WZCS",
      "the unrealistic aim of the WZCS",
      "the policies of WZCS zoo managers"
    ]
  }
}
```

---

## Group: `input-*` (7 types)

**Types:** `input-answer`, `input-diagram`, `input-flowchart`, `input-note`, `input-sentence`, `input-summary`, `input-table`

**Widget:** `InputAnswer` (`questionType/input_answer.dart`)

**How it works:**
- Items are strings or maps with `<input>` placeholders (no word list)
- User types text into text fields
- `body.items` may be strings or maps with `title`/`prefix` fields
- `desc.constraint` (e.g. `"NO MORE THAN THREE WORDS"`) is shown as a label
- Correct answers are stored in `pg.textAnswers` (not `answers`)
- State tracked via `_textInputs: List<String>` (separate from `_selections`)
- On submit, text is compared case-insensitively against correct answers

**JSON shape (string items):**
```json
{
  "start": 27, "end": 30, "type": "input-note",
  "desc": { "constraint": "NO MORE THAN TWO WORDS" },
  "body": {
    "items": [
      "The most vividly coloured red leaves are found on the side facing the <input>.",
      "The <input> surfaces of leaves contain the most red pigment."
    ]
  }
}
```

**JSON shape (map items):**
```json
{
  "start": 27, "end": 30, "type": "input-answer",
  "desc": { "constraint": "NO MORE THAN THREE WORDS" },
  "body": {
    "items": [
      { "title": "What change has there been...", "prefix": "<input>" }
    ]
  }
}
```

---

## Answer file

`assets/ielts/answer/{seriesId}-{testId}.json` contains `"reading"` entries with:

```json
{ "question_id": "1", "correct_answer": "E" }
```

Two lookup maps are built from this array:
- `answerLookup: Map<int, int>` — single-letter A–Z → index 0–25
- `textAnswerLookup: Map<int, String>` — all other answers (words, roman numerals, YES/NO)

---

## Adding a new question type

1. **Parse** it in `readingNoti.dart:loadPassage()` — add a new `else if` branch reading `qGroup`, `body`, and the appropriate lookup map. Create `ParagraphGroup` instances.
2. **Create a widget** in `questionType/` — accept type-specific props and a callback to update state.
3. **Register** in `passages_screen.dart:_buildQuestionPanel()` — add a new `if` block checking `pg.type` and returning your widget.
4. **State** — use `_selections: List<int?>` if index-based, `_textInputs: List<String>` if text-based.
5. **Submit checking** — update the `isSubmitted` block in `build()` if your type needs custom comparison.

---

## Session changelog

### What was implemented

- **`loadPassage()`** now accepts 4 parameters (`seriesId`, `testId`, `part`, `questionGroup`) and builds file paths dynamically
- **`questionGroup`** (1-based) selects which entry from `test_question[]` to use instead of `.first`
- **Type branching** — `loadPassage` parses differently per group:
  - `select-*` — unchanged
  - `option-abc` — reads `item.title` + `item.options[]`
  - `option-true-false` / `option-yes-no` — maps text answer (TRUE/YES/FALSE/NO/NOT GIVEN) to index
  - `checkbox` — reads `body.title`, `body.options`, `desc.quantity`
  - `input-*` — reads items with `<input>` placeholders, stores text answers
- **`ParagraphGroup`** gained `textAnswers` (`List<String>`) and `constraint` (`String?`)
- **New widgets** in `questionType/`:
  - `option_choice.dart` — radio-style option list (shared by option-abc, option-tf, option-yn)
  - `checkbox_widget.dart` — N-of-M checkbox with remaining count display
  - `input_answer.dart` — text fields per blank with constraint label
- **`passages_screen.dart`** dispatches to the correct widget in `_buildQuestionPanel()` via `pg.type`
- **State management** — `_textInputs` / `_savedTextInputs` added alongside `_selections` / `_savedSelections` for input types
- **Submit logic** handles both index-based (select/option/checkbox) and text-based (input) answer checking
