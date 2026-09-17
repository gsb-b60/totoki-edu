"""
parse_questions.py — Safe reader for IELTS question JSON files.

Usage:
    python template.py formated/question/10-1-3.json
    python template.py --all                         # read every file
"""

import json, glob, os, sys
from typing import Any, Optional

KNOWN_TYPES = {
    "input-answer", "input-diagram", "input-flowchart", "input-note",
    "input-sentence", "input-summary", "input-table",
    "option-abc", "option-true-false", "option-yes-no",
    "select-summary-given-list", "select-given-list",
    "select-section-given-list", "select-given-diagram",
    "select-flowchart-given-list", "select-section",
    "checkbox",
}

# body_smart uses "image" where body uses "img"
BODY_SMART_KEY_MAP = {"img": "image"}

# ---------------------------------------------------------------------------
# Guard 1: str | dict in body.items
# ---------------------------------------------------------------------------

def normalize_item(raw: Any) -> dict:
    if isinstance(raw, dict):
        if "items" in raw:
            return {"text": raw["items"], "is_example": True}
        return {k: v for k, v in raw.items()}
    return {"text": raw, "is_example": False}

# ---------------------------------------------------------------------------
# Guard 2: optional fields with get()
# ---------------------------------------------------------------------------

def safe_get(obj: Any, *keys: str, default: Any = None) -> Any:
    for key in keys:
        try:
            obj = obj[key]
        except (KeyError, TypeError):
            return default
    return obj

# ---------------------------------------------------------------------------
# Guard 3: align body_smart keys (image->img, inject item_qids)
# ---------------------------------------------------------------------------

def map_body_smart(bs: dict) -> dict:
    result = {}
    for k, v in bs.items():
        mapped = next((rk for rk, rv in BODY_SMART_KEY_MAP.items() if rv == k), k)
        result[mapped] = v
    return result

# ---------------------------------------------------------------------------
# Main normalizer
# ---------------------------------------------------------------------------

def normalize_group(g: dict) -> dict:
    qtype = g.get("type", "?")
    raw_items = safe_get(g, "body", "items", default=[])
    items = [normalize_item(i) for i in raw_items]

    body = {"items": items}
    for opt_key in ("title", "img", "instruction", "list", "options", "listTitle"):
        val = g.get("body", {}).get(opt_key)
        if val is not None:
            body[opt_key] = val

    desc = {k: v for k, v in g.get("desc", {}).items()}

    bs_raw = g.get("body_smart", {})
    body_smart = map_body_smart(bs_raw)

    return {
        "start": g.get("start"),
        "end": g.get("end"),
        "type": qtype,
        "desc": desc,
        "body": body,
        "body_smart": body_smart,
    }

def load_file(path: str) -> list[dict]:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    return [normalize_group(g) for g in data.get("test_question", [])]

# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--all":
        pattern = os.path.join("formated", "question", "*.json")
        paths = sorted(glob.glob(pattern))
    elif len(sys.argv) > 1:
        paths = sys.argv[1:2]
    else:
        print(__doc__)
        sys.exit(1)

    for path in paths:
        groups = load_file(path)
        for g in groups:
            assert g["type"] in KNOWN_TYPES, f"Unknown type in {path}: {g['type']}"
            print(f"{path:40s} Q{g['start']:2d}-{g['end']:2d}  {g['type']:35s}  "
                  f"items={len(g['body']['items'])}")
