# Database Schema (SQLite)

## Table: `decks`
Stores information about the card decks.

| Field | Type | Description |
|---|---|---|
| `id` | INTEGER PRIMARY KEY | Unique ID of the deck |
| `name` | TEXT NOT NULL | Deck title/name |
| `description` | TEXT | Optional description |
| `created_at` | INTEGER | Milliseconds timestamp |
| `updated_at` | INTEGER | Milliseconds timestamp |
| `media` | TEXT | Path to directory containing assets (images/audio) |

---

## Table: `cards`
Stores flashcards associated with decks.

| Field | Type | Description |
|---|---|---|
| `id` | INTEGER PRIMARY KEY | Unique card identifier |
| `deck_id` | INTEGER | Foreign key referencing `decks(id)` |
| `word` | TEXT | The primary English term |
| `meaning` | TEXT | Meaning/Translation |
| `img` | TEXT | Relative path to image asset |
| `synonyms` | TEXT | Synonym terms (comma-separated or JSON) |
| `sound` | TEXT | Primary audio asset path |
| `defSound` | TEXT | Definition audio path |
| `usageSound` | TEXT | Usage audio path |
| `example` | TEXT | Example sentence |
| `ipa` | TEXT | IPA Phonetic spelling |
| `complexity` | INTEGER | Word difficulty level |
| `interval` | INTEGER | Current repetition interval in days |
| `reps` | INTEGER | Number of consecutive successful repetitions |
| `due` | INTEGER | Epoch millisecond timestamp of next review date |
| `last_review` | INTEGER | Timestamp of the last review date |
| `lapses` | INTEGER | Number of times card was forgotten |
| `ease_factor` | REAL | SM-2 multiplier (defaults to 2.5) |
