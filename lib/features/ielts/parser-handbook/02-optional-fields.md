# Optional Fields — Which keys may be missing

## Rule

**Always use `.get()` instead of `[]` for any key except `start`, `end`, `type`.**

```python
# SAFE
title = g["body"].get("title")          # None when absent
nb = g["desc"].get("nb")                # None when absent
img = g["body"].get("img")              # None when absent
text = g["desc"].get("text")            # None when absent

# DANGEROUS
title = g["body"]["title"]              # KeyError if missing
```

## Per-category optional fields

### input types

| Key | Appears in | Missing in |
|-----|------------|-----------|
| `body.title` | `input-note` (86%), `input-summary` (55%), `input-table` (44%), `input-sentence` (3%) | many files |
| `body.img` | `input-diagram` (100%), `input-flowchart` (33%), `input-note` (3%) | most input-note files |
| `body.instruction` | `input-sentence` (6%) | 29/31 input-sentence files |
| `desc.text` | `input-summary` (8%), `input-diagram` | most input-summary files |
| `desc.textReadable` | `input-summary` (8%) | most input-summary files |

### option types

| Key | Appears in | Missing in |
|-----|------------|-----------|
| `desc` | `option-true-false` | always empty `{}` |
| `desc.text` | `option-yes-no` (1%) | 75/76 groups |

### select types

| Key | Appears in | Missing in |
|-----|------------|-----------|
| `desc.nb` | `select-given-list` (40%), `select-section` (16%), `select-summary-given-list` (13%) | majority |
| `desc.text` | `select-given-list` (77%), `select-section` | some |
| `desc.textReadable` | `select-given-list` (77%), `select-section` | some |
| `body.title` | `select-given-list` (15%), `select-summary-given-list` | most |
| `body.listTitle` | `select-given-list`, `select-summary-given-list` | absent in subset |
| `body.list` | `select-given-diagram` (60%) | 2/5 groups |

## How to decide: use a per-type default table

```python
DEFAULTS = {
    "input-note": {"body": {"title": "", "img": None}},
    "input-summary": {"body": {"title": ""}, "desc": {"text": None}},
    "select-given-list": {"desc": {"nb": False}},
}

def get_body_field(g, key):
    """Read a body field, returning a safe default if absent."""
    default = DEFAULTS.get(g["type"], {}).get("body", {}).get(key)
    return g["body"].get(key, default)
```

Reference: `ieltsJsonDoc/bug-risks/optional-fields.md`
