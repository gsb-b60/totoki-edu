# Writing Robust Code — Defensive patterns and testing

## Pattern 1: Always use a safe accessor

```python
def safe_get(obj, *keys, default=None):
    """Drill into nested dict without KeyError."""
    for key in keys:
        try:
            obj = obj[key]
        except (KeyError, TypeError):
            return default
    return obj

# Usage
title = safe_get(g, "body", "title", default="")
```

## Pattern 2: Separating input-reading from logic

Keep the "quirky JSON reading" in one place and return clean dicts:

```python
def normalize_group(g):
    """Convert a raw question group into a predictable shape."""
    items = []
    for raw in g["body"].get("items", []):
        if isinstance(raw, dict):
            items.append({"text": raw["items"], "is_example": True})
        else:
            items.append({"text": raw, "is_example": False})

    return {
        "start": g["start"],
        "end": g["end"],
        "type": g["type"],
        "desc": {k: v for k, v in g["desc"].items()},
        "body": {
            "items": items,
            "title": g["body"].get("title"),
            "img": g["body"].get("img") or g["body_smart"].get("image"),
        },
    }
```

## Pattern 3: Type hints for self-documenting code

```python
from typing import Any, Optional

QuestionGroup = dict[str, Any]
NormalizedItem = dict[str, str | bool]

def normalize_items(raw_items: list) -> list[NormalizedItem]:
    ...
```

## Pattern 4: Test with the edge-case files

```python
import glob, json

edge_files = glob.glob("ieltsJsonDoc/examples/edge-cases/*.json")
for path in edge_files:
    with open(path) as f:
        data = json.load(f)
    for g in data["test_question"]:
        result = normalize_group(g)
        assert result["start"] <= result["end"]
        assert result["type"] in KNOWN_TYPES
        # ... more assertions
```

## Pattern 5: Validate on load, fail early

```python
KNOWN_TYPES = {
    "input-answer", "input-diagram", "input-flowchart", "input-note",
    "input-sentence", "input-summary", "input-table",
    "option-abc", "option-true-false", "option-yes-no",
    "select-summary-given-list", "select-given-list",
    "select-section-given-list", "select-given-diagram",
    "select-flowchart-given-list", "select-section",
    "checkbox",
}

def validate_group(g):
    assert "start" in g and "end" in g and "type" in g
    assert g["type"] in KNOWN_TYPES, f"Unknown type: {g['type']}"
```
