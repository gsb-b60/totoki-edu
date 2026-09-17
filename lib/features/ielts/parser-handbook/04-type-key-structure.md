# Type Key Structure — What keys to expect per category

## Category: input (fill-in, no word list)

Types: `input-answer`, `input-diagram`, `input-flowchart`, `input-note`, `input-sentence`, `input-summary`, `input-table`

```python
{
  "desc": {
    "constraint": "NO MORE THAN THREE WORDS",
    # optional: "text": [...], "textReadable": [...]
  },
  "body": {
    "items": [...],             # str | dict  <-- guard!
    # optional: "title": "", "img": "", "instruction": [...]
  },
  "body_smart": {
    "items": [...],
    # optional: "image": {...}, "title": {...}, "item_qids": [[...]]
  }
}
```

`input-table` has `body.items` as a 2D array (list of rows, first row is header).

## Category: option (choose from fixed set)

Types: `option-abc`, `option-true-false`, `option-yes-no`

```python
{
  "desc": {
    # option-abc only: "optionRange": ["A", "D"]
    # option-true-false: {} (empty)
    # option-yes-no: {} or {"text": [...]}
  },
  "body": {
    "items": [                  # str | dict  <-- guard!
      "Statement 1 <input>",
      {"type":"example", "items": "Example <input=X>"}
    ]
  },
  "body_smart": {
    "items": [...],
    "item_qids": [[...]]        # extra vs body
  }
}
```

For `option-abc`, each item is `{"title": "Question stem", "options": ["A", "B", "C", "D"]}`.

## Category: select (choose from provided list)

Types: `select-summary-given-list`, `select-given-list`, `select-section-given-list`, `select-given-diagram`, `select-flowchart-given-list`, `select-section`

```python
{
  "desc": {
    "optionRange": ["A", "G"],          # present in most
    # optional: "text": [...], "textReadable": [...], "nb": bool
    # select-section* only: "sectionRange": ["A","G"], "sectionType": "paragraph"
  },
  "body": {
    "list": [...],                      # words/options to choose from
    "items": [...],                     # str | dict  <-- guard!
    # optional: "title": "", "listTitle": "", "img": ""
  },
  "body_smart": {
    "list": [...],
    "items": [...],
    # optional: "item_qids": [[...]], "image": {...}
  }
}
```

`select-section` has no `body.list` — answers map to paragraph/section letters directly.

## Category: checkbox (pick N correct)

Types: `checkbox`

```python
{
  "desc": {
    "optionRange": ["A", "F"],
    "quantity": 3
  },
  "body": {
    "title": "Choose THREE letters...",
    "options": ["A", "B", "C", "D", "E", "F"]
  },
  "body_smart": {
    "options": [...],
    "title": {...},
    "item_qids": [[...]]
  }
}
```
