# Mixed Items — `body.items` contains str AND dict

## Problem

In 12 of the 17 question types, `body.items` is **not** a homogeneous string array.
Some entries are plain strings with `<input>` placeholders, others are objects like:

```json
{
  "type": "example",
  "items": "Life expectancy: <input=70> years (in developed countries)"
}
```

A naive loop `for item in items: item.startswith(...)` will crash on the dict.

## Don't do this

```python
# CRASHES when item is a dict
for item in g["body"]["items"]:
    text = item.replace("<input>", "___")
```

## Guard code

```python
def extract_text(item):
    """Return the display text from a body.items entry."""
    if isinstance(item, dict):
        return item["items"]        # {"type":"example","items":"..."}
    return item                     # plain string

for raw in g["body"]["items"]:
    text = extract_text(raw)
    # now text is always a string
```

## Which types are affected

| Type | Frequency |
|------|-----------|
| `option-true-false` | 1/84 groups |
| `option-yes-no` | several groups |
| `select-given-list` | several groups |
| `select-section` | 1/58 groups |
| `select-section-given-list` | most groups |
| `select-summary-given-list` | a few groups |
| `select-given-diagram` | 1/5 groups |
| `select-flowchart-given-list` | 1/1 group |
| `input-diagram` | 1/11 groups |
| `input-flowchart` | 2/3 groups |
| `input-note` | many groups |
| `input-sentence` | 1/31 groups |
| `input-summary` | 1/51 groups |

## What the dict entries look like

The dict always has exactly 2 keys:
- `type`: always `"example"` (marks a pre-filled example answer)
- `items`: the text string, may contain `<input=V>` with a default value

Reference: `ieltsJsonDoc/bug-risks/mixed-items.md`
