# JSON Structure — `formated/question/`

## Source file

`formated/question/1-1-1.json`

## What information it holds

The IELTS reading questions for a given passage. Contains the exercise type, the list of answer options, the question text (with placeholder inputs), and a "smart" structured version with word-level tokenisation for rendering.

## Tree structure

```
{
  "test_question": [
    {
      "start": 1,                   // first question number
      "end": 8,                     // last question number
      "type": "select-summary-given-list",  // question type
      "desc": {
        "optionRange": ["A", "T"]   // letter range for answer options
      },
      "body": {
        "list": [                   // answer options as plain strings
          "Mexicans  ",
          "random    ",
          ...
          "smoke     "
        ],
        "items": [                  // question text with <input> placeholders
          {
            "type": "example",
            "items": "Primitive societies saw fire as a <input=I (heavenly)> gift."
          },
          "They tried to <input> burning logs or charcoal <input> ...",
          ...
        ],
        "title": "EARLY FIRE-LIGHTING METHODS",
        "listTitle": "List of Words"
      },
      "body_smart": {               // structured version for rendered display
        "list": [                   // options as atom/block objects
          {
            "type": "atom",
            "blocks": [
              {
                "type": "word",
                "content": "Mexicans",
                "word_gid": "a1t1r1_1-8_5"
              }
            ]
          },
          ...
        ],
        "items": [                  // question text as atom/block objects
          {
            "type": "example",
            "items": {
              "type": "atom",
              "blocks": [
                { "type": "word",         "content": "Primitive",     "word_gid": "..." },
                { "type": "",             "content": " ",             "word_gid": "..." },
                { "type": "input-example","content": "I (heavenly)",  "word_gid": "..." },
                ...
              ]
            }
          },
          {
            "type": "atom",
            "blocks": [
              { "type": "word",  "content": "They",     "word_gid": "..." },
              { "type": "",      "content": " ",        "word_gid": "..." },
              { "type": "input", "content": 1,          "word_gid": "..." },   // <input> placeholder
              ...
            ]
          }
        ]
      }
    }
  ]
}
```

## How to access

```python
import json

with open("formated/question/1-1-1.json") as f:
    data = json.load(f)

for q in data["test_question"]:
    q_type = q["type"]
    options = q["body"]["list"]
    title = q["body"]["title"]
    items = q["body"]["items"]

    # structured version
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
