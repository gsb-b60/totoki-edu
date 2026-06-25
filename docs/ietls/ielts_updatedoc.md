# IELTS Reading — Architecture Guide

## 1. File Organization

### Hierarchy

```
seriesId (1–20) → testId (1–4) → part (1–3) → questionGroup (1-based)
```

Example: `seriesId=1, testId=2, part=2, questionGroup=2` loads test `1-2-2`, question group at index 1 (0-based).

### Asset path patterns

| Data | Path |
|---|---|
| Article text | `assets/ielts/test/{seriesId}-{testId}-{part}.json` |
| Questions | `assets/ielts/question/{seriesId}-{testId}-{part}.json` |
| Answers | `assets/ielts/answer/{seriesId}-{testId}.json` |
| Dictionary | `assets/ielts/jsondictionary.json` |
| Article image | `assets/ielts/picture/{seriesId}/{filename}.jpeg` (`.jpg` → `.jpeg`) |
| Question image | same picture directory, same extension cleaning |

### Loading call

```dart
final noti = context.read<ReadingNoti>();
await noti.loadPassage(
  seriesId: 1,
  testId: 2,
  part: 2,
  questionGroup: 2,  // 1-based index into test_question array
);
```

---

## 2. JSON Data Sources

See these docs for full field-level reference:

| Doc | What it covers |
|---|---|
| `jsonstructure-test.md` | Article text with word tokens, sentence-level annotations |
| `jsonstructure-question.md` | All 17 question types, their `body` shapes, `body_smart` tokenisation |
| `jsonstructure-answer.md` | Correct answers per question_id across all 4 sections |

---

## 3. `readingNoti.dart` — Data loading & parsing

File: `lib/ui/screens/ielts/passages/noti/readingNoti.dart`

### 3a. `loadPassage()` lifecycle

```
load JSONs (4 files via Future.wait)
  → decode test JSON → build articleFragments (text + image sections)
  → decode answer JSON → build two lookup maps
  → select question group: qList[questionGroup - 1]
  → switch on type → create ParagraphGroup list
```

### 3b. Answer lookup

```dart
final answerLookup = <int, int>{};        // single-char A-Z answers → 0-based index
final textAnswerLookup = <int, String>{};  // everything else (words, YES/NO, roman numerals)
```

Logic:
- If `correct_answer` is exactly 1 char AND is A–Z → store as index in `answerLookup`
- Otherwise → store raw string in `textAnswerLookup`

### 3c. `ParagraphGroup` fields

| Field | Type | Used by | Description |
|---|---|---|---|
| `displayText` | `String` | all | Question/prompt text (or instruction, or header) |
| `options` | `List<String>` | select-\*, option-\*, checkbox | The word/answer bank |
| `answers` | `List<int>` | select-\*, option-\*, checkbox | 0-based indices of correct options |
| `textAnswers` | `List<String>` | input-\* | Correct text answers (one per blank) |
| `type` | `String` | all | The question type string |
| `constraint` | `String?` | input-\* | Word limit display (e.g. "NO MORE THAN TWO WORDS") |
| `rowLabels` | `List<String>?` | input-table | Row labels for table layout |
| `imageAssetPath` | `String?` | input-diagram | Asset path to the diagram image |
| `diagramTitle` | `String?` | input-diagram | Title displayed above the diagram |

### 3d. Type dispatch switch (in `loadPassage()`)

```
switch (type):
  "select-flowchart-given-list"        → parse items with inputRegex, use answerLookup
  _ when type.startsWith("select-")    → same as above (generic select)
  "option-abc"                         → item.title + item.options, 1 answer per item
  "option-true-false" || "option-yes-no" → text answers mapped to 0/1/2
  "checkbox"                           → title + options + desc.quantity
  "input-table"                        → items as table rows, rowLabels, textAnswers
  "input-diagram"                      → body.img → imageAssetPath, body.items[0] → blanks
  _ when type.startsWith("input-")     → generic: items with <input>, textAnswers
```

**Important**: `input-table` and `input-diagram` must appear BEFORE the generic `startsWith("input-")` catch-all, because they have different `body.items` shapes.

---

## 4. `passages_screen.dart` — UI dispatch & state

File: `lib/ui/screens/ielts/passages/passages_screen.dart`

### 4a. Widget tree (build method)

```
Scaffold
  AppBar (back + title)
  SafeArea
    Stack
      Column
        Container (article panel, flex 5)
          SingleChildScrollView
            title
            articleFragments[] → text (RichText) / image (Image.asset)
        Container (question panel, flex 4)
          _buildQuestionPanel(pg)    ← dispatch here
        _buildBottomBar(totalQ)
      AnimatedPositioned
        ReviewScreen (correct/incorrect overlay, slides up on submit)
```

### 4b. State tracking

Two parallel state arrays, determined by whether type starts with `"input-"`:

| State variable | Type | Used by |
|---|---|---|
| `_selections` | `List<int?>` | select-\*, option-\*, checkbox |
| `_textInputs` | `List<String>` | all input-\* types |

Save/load across paragraph navigation:
- `_savedSelections: Map<int, List<int?>>`
- `_savedTextInputs: Map<int, List<String>>`
- Branched by `pg.type.startsWith("input-")` in `_saveCurrentSelections()` / `_loadSelectionsFor()`

### 4c. `_buildQuestionPanel()` dispatch chain

Order matters — more specific types before generic catches:

```
pg.type == "select-flowchart-given-list"  → SelectSummaryGivenList  (precise)
pg.type.startsWith("select-")             → SelectSummaryGivenList  (generic)
pg.type in ["option-abc","option-tf","option-yn"] → OptionChoice     (set check)
pg.type == "checkbox"                     → CheckboxWidget         (precise)
pg.type == "input-table"                  → InputTable             (precise)
pg.type == "input-diagram"                → InputDiagram           (precise)
pg.type.startsWith("input-")              → InputAnswer            (generic)
else                                      → "Unknown" red error
```

### 4d. Submit & review

- `_submit()` marks all paragraphs as submitted
- `_allParagraphsComplete` checks all blanks filled (branched on `startsWith("input-")`)
- Review screen shows correct answers joined as comma-separated string
- Input types compare `_textInputs[i].trim().toLowerCase()` vs `pg.textAnswers[i]`
- Index types compare `_selections[i]` vs `pg.answers[i]`

---

## 5. Question type widgets

All widgets live in `lib/ui/screens/ielts/passages/questionType/`.

| Widget | File | `type` matched | State used | Key props |
|---|---|---|---|---|
| `SelectSummaryGivenList` | `select_summary_given_list.dart` | `select-flowchart-given-list`, `select-given-list`, `select-section-given-list`, `select-given-diagram`, `select-summary-given-list` | `_selections` | `questionText`, `options`, `selected[]`, `usedOptionIndices`, `onSelect(blankIdx, optIdx)` |
| `OptionChoice` | `option_choice.dart` | `option-abc`, `option-true-false`, `option-yes-no` | `_selections[0]` | `questionText`, `options`, `selected`, `onSelect(optIdx)` |
| `CheckboxWidget` | `checkbox_widget.dart` | `checkbox` | `_selections` | `questionText`, `options`, `selected[]`, `quantity`, `onSelect(idx, optIdx)` |
| `InputTable` | `input_table.dart` | `input-table` | `_textInputs` | `headerText`, `rowLabels[]`, `inputs[]`, `constraint`, `onChanged(idx, val)` |
| `InputDiagram` | `input_diagram.dart` | `input-diagram` | `_textInputs` | `questionText`, `imageAssetPath`, `diagramTitle`, `inputs[]`, `constraint`, `onChanged(idx, val)` |
| `InputAnswer` | `input_answer.dart` | all other `input-*` | `_textInputs` | `questionText`, `inputs[]`, `constraint`, `onChanged(idx, val)` |
| `OptionBtn` | `option_btn.dart` | (helper, not a question type) | — | `label`, `isSelected`, `onTap` |

### Widget contract

Every question widget:
- Is a **StatelessWidget** (except `SelectSummaryGivenList` which is StatefulWidget for its dropdown)
- Receives the **current state** (selected/inputs) as a prop
- Calls the **callback** (`onSelect`/`onChanged`) on user interaction → `passages_screen.dart` calls `setState`
- Receives `answered` bool to switch between edit mode and review display

---

## 6. Adding a new question type — step-by-step

### Step 1: Add fields to `ParagraphGroup` (if needed)

If the new type needs data beyond existing fields (e.g. an image path, row labels), add fields to `ParagraphGroup` in `readingNoti.dart`.

```dart
class ParagraphGroup {
  // ... existing fields
  final NewType? newField;
}
```

### Step 2: Parse in `readingNoti.dart:loadPassage()`

Add a new `case` in the `switch` block. Place it BEFORE the generic catch-all if its `body.items` shape differs.

```dart
case "new-type":
  // parse qGroup, body, answerLookup/textAnswerLookup
  questions.add(ParagraphGroup(
    displayText: ...,
    options: ...,
    answers: ...,
    type: type,
  ));
```

Rules:
- If answers are A–Z letters → use `answerLookup[qNum]`
- If answers are text → use `textAnswerLookup[qNum]`
- `"input-*"` types → use `_textInputs` state → `textAnswerLookup` → store in `textAnswers`
- Other types → use `_selections` state → `answerLookup` → store in `answers`

### Step 3: Create a widget in `questionType/`

Follow the existing widget pattern:

```dart
class NewTypeWidget extends StatelessWidget {
  final String questionText;
  final List<String> inputs;        // or List<int?> selected
  final bool answered;
  final int questionIndex;
  final int totalQuestions;
  final void Function(int, String) onChanged;  // or onSelect

  // ... build method
}
```

Keep it stateless. The `passages_screen.dart` holds all state.

### Step 4: Register in `passages_screen.dart:_buildQuestionPanel()`

Add an `if` block **before** the generic catch-all of the same group:

```dart
if (pg.type == "new-type") {
  return NewTypeWidget(
    // ... props
  );
}
```

### Step 5: Verify state handling

- If text-based → `pg.type.startsWith("input-")` already covers save/load/check. No extra work.
- If index-based → same, `startsWith("input-")` is false, so `_selections` path is used.
- If entirely new state category → update `_saveCurrentSelections()`, `_loadSelectionsFor()`, `_allParagraphsComplete`, and the submit-check block in `build()`.

### Step 6: Update this doc

Add the new type to the tables in sections 3c, 3d, 4c, and 5.

---

## 7. Current type coverage

| `type` value | Behaviour | Widget | Answer source |
|---|---|---|---|
| `select-summary-given-list` | Pick from list | `SelectSummaryGivenList` | `answerLookup` |
| `select-given-list` | Pick from list | `SelectSummaryGivenList` | `answerLookup` |
| `select-section-given-list` | Pick from list | `SelectSummaryGivenList` | `answerLookup` |
| `select-given-diagram` | Pick from list | `SelectSummaryGivenList` | `answerLookup` |
| `select-flowchart-given-list` | Pick from list | `SelectSummaryGivenList` | `answerLookup` |
| `select-section` | Pick from list | `SelectSummaryGivenList` | `answerLookup` |
| `option-abc` | Single choice | `OptionChoice` | `answerLookup` |
| `option-true-false` | Single choice | `OptionChoice` | `textAnswerLookup` → mapped 0/1/2 |
| `option-yes-no` | Single choice | `OptionChoice` | `textAnswerLookup` → mapped 0/1/2 |
| `checkbox` | N of M | `CheckboxWidget` | `answerLookup` |
| `input-table` | Fill in table | `InputTable` | `textAnswerLookup` |
| `input-diagram` | Label diagram | `InputDiagram` | `textAnswerLookup` |
| `input-answer` | Fill in blank | `InputAnswer` | `textAnswerLookup` |
| `input-flowchart` | Fill in blank | `InputAnswer` | `textAnswerLookup` |
| `input-note` | Fill in blank | `InputAnswer` | `textAnswerLookup` |
| `input-sentence` | Fill in blank | `InputAnswer` | `textAnswerLookup` |
| `input-summary` | Fill in blank | `InputAnswer` | `textAnswerLookup` |
