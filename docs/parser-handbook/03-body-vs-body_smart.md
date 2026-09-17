# body vs body_smart — Key mapping and normalization

## Problem

`body_smart` is a word-tokenised version of `body` for rendering. But the two are
**not structurally identical**. Three concrete differences will break naive code.

## Difference 1: `img` vs `image`

`body` uses key `img` for diagram images, but `body_smart` uses `image`.

```json
"body": { "img": "test3_part1_section3_diagram.png", ... }
"body_smart": { "image": { "type": "image", "src": "..." }, ... }
```

**Guard:**

```python
def get_body_smart_image(bs):
    return bs.get("image") or bs.get("img")
```

Or when iterating body_smart keys while referencing body, use a map:

```python
BODY_SMART_KEY_MAP = {"img": "image"}
# all other keys are identical

for key, value in g["body"].items():
    bs_key = BODY_SMART_KEY_MAP.get(key, key)
    bs_value = g["body_smart"].get(bs_key)
```

## Difference 2: Extra `item_qids` in body_smart

`body_smart` sometimes has an `item_qids` array that does **not** exist in `body`.

Affected types: `input-sentence`, `option-abc`, `option-true-false`, `option-yes-no`,
`select-given-list`, `select-section`, `checkbox`.

```json
"body_smart": {
  "items": [...],
  "item_qids": [["qid1"], ["qid2"]]
}
```

**Guard:** treat `item_qids` as body_smart-only; never expect it in `body`.

```python
for item in g["body"]["items"]:
    # process item — no item_qids here

item_qids = g["body_smart"].get("item_qids", [])
# only use item_qids from body_smart
```

## Difference 3: Missing keys in body_smart

Some keys exist in `body` but are absent in `body_smart`:
- `listTitle` — missing in some `select-summary-given-list` body_smart
- `title` — missing in some `select-given-list` body_smart

**Guard:** always use `.get()` on both `body` and `body_smart`.

## Summary

| body key | body_smart key | Difference type |
|----------|----------------|-----------------|
| `img` | `image` | renamed |
| `*` (no `item_qids`) | `item_qids` | extra key |
| `listTitle` | sometimes missing | optional |
| `title` | sometimes missing | optional |

Reference: `ieltsJsonDoc/bug-risks/body-vs-body_smart.md`
