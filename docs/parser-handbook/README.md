# Parser Handbook — Reading IELTS Question JSONs

This folder teaches an agent (or human) how to read the 240 question JSON files in `formated/question/` safely, without crashing on structural quirks.

## How to use

1. Read **`00-quickstart.md`** — it walks through a complete parser in 5 steps.
2. If a problem comes up, the *problem* files (01–03) explain the guard code.
3. **`04-type-key-structure.md`** is a reference table for what keys live under each type category.
4. **`05-writing-robust-code.md`** has defensive patterns, type hints, and a testing strategy.
5. **`template.py`** is ready-to-copy starter code.

## Problem index

| File | Problem | Solution |
|------|---------|----------|
| `01-mixed-items.md` | `body.items` contains str AND dict | `isinstance` check |
| `02-optional-fields.md` | Fields like `title`, `nb`, `text` may be missing | `.get(key, default)` |
| `03-body-vs-body_smart.md` | Key renames (`img`→`image`) and missing `item_qids` | Normalization map |

## External references

Detailed type-by-type analysis lives in `../ieltsJsonDoc/`. This handbook gives you the *code*; that folder gives you the *data*.

## Source

Files: `formated/question/{test}-{part}-{section}.json` (20 tests × 4 parts × 3 sections = 240 files, 688 question groups).
