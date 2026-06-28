# Quickstart — Parse any question file in 5 steps

## Step 1: Load the file

```python
import json

with open("formated/question/10-1-3.json") as f:
    data = json.load(f)

groups = data["test_question"]  # list of question groups
```

## Step 2: Read the question range

```python
for g in groups:
    start = g["start"]   # first question number (int)
    end   = g["end"]     # last question number (int)
    qtype = g["type"]    # one of 17 type strings
```

## Step 3: Safely iterate `body.items`

**Items may be strings or dicts.** Always check:

```python
for item in g["body"]["items"]:
    if isinstance(item, dict):
        text = item["items"]           # the real text
    else:
        text = item                    # plain string
```

## Step 4: Read optional fields with `.get()`

```python
title = g["body"].get("title")         # None if absent
constraint = g["desc"].get("constraint")
option_range = g["desc"].get("optionRange")
```

## Step 5: Access `body_smart` with key mapping

For diagram types, `body.img` becomes `body_smart.image`:

```python
# body key -> body_smart key map
KEY_MAP = {"img": "image"}
bs = g["body_smart"]
for bk, bsv in bs.items():
    mapped = KEY_MAP.get(bk, bk)  # use mapped key for lookups
```

---

See `template.py` for the complete runnable version.
