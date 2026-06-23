# JSON Structure — `formated/question/`

## Source file

`formated/question/1-1-1.json`

## What information it holds

The IELTS reading questions for a given passage. Contains the exercise type, the list of answer options, the question text (with placeholder inputs), and a "smart" structured version with word-level tokenisation for rendering.

## Question types

There are **17 distinct question types**, each with a different `body` structure. They fall into 4 behavioural groups:

| Group | Types | Behaviour |
|-------|-------|-----------|
| **input** | `input-answer`, `input-diagram`, `input-flowchart`, `input-note`, `input-sentence`, `input-summary`, `input-table` | Fill in the blank (no word list — user writes the answer) |
| **option** | `option-abc`, `option-true-false`, `option-yes-no` | Choose the correct option from a set |
| **select** | `select-summary-given-list`, `select-given-list`, `select-section-given-list`, `select-given-diagram`, `select-flowchart-given-list`, `select-section` | Choose from a provided word/phrase list |
| **checkbox** | `checkbox` | Pick N correct options from a list |

---

### input-answer

Short-answer questions: read the question and write the answer.

| Field | Type | Description |
|-------|------|-------------|
| `desc.constraint` | `string` | Word limit (e.g. `"NO MORE THAN THREE WORDS"`) |
| `body.items` | `array` | `[ { "title": "...", "prefix": "<input>" } ]` |

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

### input-diagram

Label a diagram.

| Field | Type | Description |
|-------|------|-------------|
| `desc.text` | `array[string]` | Instructions |
| `desc.constraint` | `string` | Word limit |
| `body.img` | `string` | Image filename |
| `body.items` | `array` | Label items with `<input>` |
| `body.title` | `string` | Diagram title |

```json
{
  "start": 1, "end": 3, "type": "input-diagram",
  "desc": { "text": ["Label the diagram below."], "constraint": "ONE OR TWO WORDS" },
  "body": {
    "img": "a1t2r2-1.jpg",
    "items": ["first label <input>", "second label <input>"],
    "title": "A BEEHIVE"
  }
}
```

---

### input-flowchart

Label a flowchart.

| Field | Type | Description |
|-------|------|-------------|
| `desc.constraint` | `string` | Word limit |
| `body.img` | `string` | Image filename |
| `body.items` | `array` | Steps with `<input>` |

```json
{
  "type": "input-flowchart",
  "desc": { "constraint": "ONE WORD ONLY" },
  "body": {
    "img": "a5t2r1.jpg",
    "items": [
      { "title": "Step 1: <input>", "description": "..." }
    ]
  }
}
```

---

### input-note

Complete notes / summary with no word list.

| Field | Type | Description |
|-------|------|-------------|
| `desc.constraint` | `string` | Word limit |
| `body.items` | `array[string]` | Lines with `<input>` |
| `body.title` | `string` | Section heading (optional) |

```json
{
  "type": "input-note",
  "desc": { "constraint": "NO MORE THAN TWO WORDS" },
  "body": {
    "items": [
      "The most vividly coloured red leaves are found on the side of the tree facing the <input>.",
      "The <input> surfaces of leaves contain the most red pigment."
    ]
  }
}
```

---

### input-sentence

Complete the sentences.

| Field | Type | Description |
|-------|------|-------------|
| `desc.constraint` | `string` | Word limit |
| `body.items` | `array[string]` | Sentence stems with `<input>` |

```json
{
  "type": "input-sentence",
  "desc": { "constraint": "NO MORE THAN THREE WORDS" },
  "body": {
    "items": [
      "Many developers prefer mass-produced houses because they <input>."
    ]
  }
}
```

---

### input-summary

Complete a summary passage (no word list).

| Field | Type | Description |
|-------|------|-------------|
| `desc.constraint` | `string` | Word limit |
| `body.items` | `array[string]` | Summary text with `<input>` |

```json
{
  "type": "input-summary",
  "desc": { "constraint": "NO MORE THAN TWO WORDS" },
  "body": {
    "items": [
      "Psychologists have traditionally believed that a personality <input> was impossible..."
    ]
  }
}
```

---

### input-table

Complete a table.

| Field | Type | Description |
|-------|------|-------------|
| `desc.constraint` | `string` | Word limit |
| `body.items` | `array[array]` | Table rows — first row is header, subsequent rows contain `<input>` |

```json
{
  "type": "input-table",
  "desc": { "constraint": "NO MORE THAN THREE WORDS" },
  "body": {
    "items": [
      ["PERIOD", "STYLE OF PERIOD", "BUILDING MATERIALS", "CHARACTERISTICS"],
      ["Before 18th century", { "type": "example", "items": "<input=traditional>" }, "<input>", ""]
    ]
  }
}
```

---

### option-abc

Multiple choice (A, B, C, D ...).

| Field | Type | Description |
|-------|------|-------------|
| `desc.optionRange` | `array[string]` | Letter range (e.g. `["A", "D"]`) |
| `body.items` | `array` | `[ { "title": "...", "options": ["..."] } ]` |

```json
{
  "start": 31, "end": 36, "type": "option-abc",
  "desc": { "optionRange": ["A", "D"] },
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

### option-true-false

True / False / Not Given.

| Field | Type | Description |
|-------|------|-------------|
| `desc` | `{}` | Always empty |
| `body.items` | `array[string]` | Statements to judge |

```json
{
  "type": "option-true-false",
  "desc": {},
  "body": {
    "items": [
      "Marie Curie's husband was a joint winner of both Marie's Nobel Prizes.",
      "Marie became interested in science when she was a child."
    ]
  }
}
```

---

### option-yes-no

Yes / No / Not Given.

| Field | Type | Description |
|-------|------|-------------|
| `desc` | `{}` | Always empty |
| `body.items` | `array[string]` | Statements to judge |

```json
{
  "type": "option-yes-no",
  "desc": {},
  "body": {
    "items": [
      "The biggest threat to the environment now comes from business and industry."
    ]
  }
}
```

---

### select-summary-given-list

Complete a summary by selecting words from a list.

| Field | Type | Description |
|-------|------|-------------|
| `desc.optionRange` | `array[string]` | Letter range |
| `body.list` | `array[string]` | Available words |
| `body.items` | `array` | Summary text with `<input>` (and optional `type: "example"`) |
| `body.title` | `string` | Summary title (optional) |
| `body.listTitle` | `string` | List heading |

```json
{
  "type": "select-summary-given-list",
  "desc": { "optionRange": ["A", "T"] },
  "body": {
    "list": ["Mexicans", "random", "smoke"],
    "items": [
      { "type": "example", "items": "Primitive societies saw fire as a <input=I (heavenly)> gift." },
      "They tried to <input> burning logs or charcoal <input> ..."
    ],
    "title": "EARLY FIRE-LIGHTING METHODS",
    "listTitle": "List of Words"
  }
}
```

---

### select-given-list

Match questions or descriptions to items in a list.

| Field | Type | Description |
|-------|------|-------------|
| `desc.nb` | `bool` | `true` if passage labels are letters not numbers |
| `desc.text` | `array[string]` | Instructions |
| `desc.optionRange` | `array[string]` | Letter range |
| `body.list` | `array[string]` | Items to match to |
| `body.items` | `array` | Descriptions with `<input>` (may have `type: "example"`) |
| `body.title` | `string` | Section heading |
| `body.listTitle` | `string` | List heading |

```json
{
  "type": "select-given-list",
  "desc": {
    "nb": true,
    "text": ["Look at the following notes...", "Decide which type of match..."],
    "optionRange": ["A", "H"]
  },
  "body": {
    "list": ["the Ethereal Match", "the Instantaneous Match"],
    "items": [
      { "type": "example", "items": "could be lit by being rubbed..." },
      "was the result of a famous scientist's work <input>"
    ],
    "title": "NOTES",
    "listTitle": "Types of Matches"
  }
}
```

---

### select-section-given-list

Match headings or statements to passage paragraphs/sections, choosing from a list.

| Field | Type | Description |
|-------|------|-------------|
| `desc.text` | `array[string]` | Instructions |
| `desc.optionRange` | `array[string]` | Letter range |
| `desc.sectionType` | `string` | `"paragraph"` or `"section"` |
| `desc.sectionRange` | `array[string]` | Range of sections (e.g. `["A", "F"]`) |
| `body.list` | `array[string]` | Available headings/options |
| `body.items` | `array` | Items with `<input>` (may have `type: "example"`) |
| `body.listTitle` | `string` | List heading |

```json
{
  "type": "select-section-given-list",
  "desc": {
    "text": ["Reading Passage 3 has six paragraphs, A-F.", "Choose the correct heading..."],
    "optionRange": ["i", "vii"],
    "sectionType": "paragraph",
    "sectionRange": ["A", "F"]
  },
  "body": {
    "list": ["Commercial pressures on people in charge", "Mixed views on current changes..."],
    "items": [
      { "type": "example", "items": "Paragraph A <input=v>" },
      "Paragraph B <input>",
      "Paragraph C <input>"
    ],
    "listTitle": "List of Headings"
  }
}
```

---

### select-given-diagram

Label a diagram using words from a list.

| Field | Type | Description |
|-------|------|-------------|
| `desc.text` | `array[string]` | Instructions |
| `desc.optionRange` | `array[string]` | Letter range |
| `body.img` | `string` | Image filename |
| `body.list` | `array[string]` | Available labels |
| `body.items` | `array[string]` | Label slots with `<input>` |

```json
{
  "type": "select-given-diagram",
  "desc": {
    "text": ["Complete the labels on Diagram B below."],
    "optionRange": ["A", "G"]
  },
  "body": {
    "img": "a2t1r1.jpg",
    "list": ["granite", "limestone", "basalt"],
    "items": ["<input>", "<input>", "<input>", "<input>"]
  }
}
```

---

### select-flowchart-given-list

Complete a flowchart using words from a list.

| Field | Type | Description |
|-------|------|-------------|
| `desc.optionRange` | `array[string]` | Letter range |
| `body.list` | `array[string]` | Available words |
| `body.items` | `array` | Flowchart steps with `<input>` |
| `body.title` | `string` | Flowchart title |
| `body.listTitle` | `string` | List heading |
| `body.instruction` | `array[string]` | Instructions |

```json
{
  "type": "select-flowchart-given-list",
  "desc": { "optionRange": ["A", "R"] },
  "body": {
    "list": ["smoke", "beehive", "nectar"],
    "items": [
      { "type": "example", "items": "<input=example>" },
      "<input>",
      "<input>"
    ],
    "title": "BEEKEEPER MOVEMENTS",
    "listTitle": "List of Words/Phrases",
    "instruction": ["The flowchart below outlines..."]
  }
}
```

---

### select-section

Match information to the correct passage paragraph/section (no word list).

| Field | Type | Description |
|-------|------|-------------|
| `desc.text` | `array[string]` | Instructions |
| `desc.sectionType` | `string` | `"paragraph"` or `"section"` |
| `desc.sectionRange` | `array[string]` | Range of sections |
| `body.items` | `array` | Descriptions with `<input>` |

```json
{
  "type": "select-section",
  "desc": {
    "text": ["Reading Passage 2 has seven paragraphs, A-G.", "State which paragraph discusses each..."],
    "sectionType": "paragraph",
    "sectionRange": ["A", "G"]
  },
  "body": {
    "items": [
      { "type": "example", "items": "a reason for the limitations of scientific research <input>" },
      "the role of imitation in developing a sense of identity <input>"
    ]
  }
}
```

---

### checkbox

Select N correct options from a list (e.g. "Which THREE of the following...").

| Field | Type | Description |
|-------|------|-------------|
| `desc.quantity` | `number` | How many to select |
| `desc.optionRange` | `array[string]` | Letter range |
| `body.title` | `string` | The question/prompt |
| `body.options` | `array[string]` | Options to check |

```json
{
  "start": 26, "end": 28, "type": "checkbox",
  "desc": {
    "quantity": 3,
    "optionRange": ["A", "F"]
  },
  "body": {
    "title": "Which THREE of the following factors are mentioned?",
    "options": [
      "the number of unregistered zoos in the world",
      "the lack of money in developing countries",
      "the actions of the Isle of Wight local council",
      "the failure of the WZCS to examine the standards of the 'core zoos'",
      "the unrealistic aim of the WZCS in view of the number of species 'saved' to date",
      "the policies of WZCS zoo managers"
    ]
  }
}
```

---

## Common fields

Every question object has these fields regardless of type:

| Field | Type | Description |
|-------|------|-------------|
| `start` | `number` | First question number |
| `end` | `number` | Last question number |
| `type` | `string` | One of the 17 types above |
| `desc` | `object` | Metadata (varies by type) |
| `body` | `object` | The question content (varies by type) |
| `body_smart` | `object` | Word-tokenised version of `body` for rendered display |

The `body_smart` field mirrors the `body` structure but replaces every plain string with an `{ atom -> blocks[{word_gid, type, content}] }` tree. It is always present and safe to use for rendering.

## How to access

```python
import json

with open("formated/question/1-1-1.json") as f:
    data = json.load(f)

for q in data["test_question"]:
    q_type = q["type"]
    if q_type == "checkbox":
        title = q["body"]["title"]
        options = q["body"]["options"]
    elif q_type.startswith("input-"):
        constraint = q["desc"]["constraint"]
        items = q["body"]["items"]
    elif q_type.startswith("option-"):
        items = q["body"]["items"]
    elif q_type.startswith("select-"):
        items = q["body"]["items"]
        if "list" in q["body"]:
            word_list = q["body"]["list"]

    # structured version always available
    smart_items = q["body_smart"]["items"]
    for item in smart_items:
        for block in item["items"]["blocks"] if "items" in item else item["blocks"]:
            if block["type"] == "input":
                print(f"Input slot {block['content']}")
```

## What this data could serve

- Render the IELTS question UI with fill-in-the-blank inputs
- Map answer options (A–T) to their text values
- Display questions as structured text with word-level metadata
- Build interactive exercises where users select words from the list
- Identify question type to switch between rendering modes (MCQ, fill-in, matching, checkbox)
