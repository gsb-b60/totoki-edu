# Database Schema (SQLite)

The app uses **two SQLite databases**, both created via `sqflite` with `PRAGMA foreign_keys = ON`.

- **`flashcards.db`** — deck & card domain data (Anki-imported vocabulary + SRS scheduling).
- **`user.db`** — user profile, lesson history, card review history, and daily usage.

Both helpers are accessed via hardcoded singletons: `DatabaseHelper.instance` (`lib/data/card_database/database_helper.dart`) and `UserDatabaseHelper.instance` (`lib/data/user_database/user_db_helper.dart`).

---

## `flashcards.db` (DatabaseHelper)

### Table: `decks`

| Field | Type | Description |
|---|---|---|
| `id` | INTEGER PRIMARY KEY | Unique deck ID |
| `name` | TEXT NOT NULL | Deck title/name |
| `description` | TEXT | Optional description |
| `created_at` | INTEGER | Milliseconds timestamp |
| `updated_at` | INTEGER | Milliseconds timestamp |
| `media` | TEXT | Per-deck media folder basename under `<documents>/anki/` |

### Table: `cards`

| Field | Type | Description |
|---|---|---|
| `id` | INTEGER PRIMARY KEY | Unique card identifier |
| `created_at` | INTEGER | Milliseconds timestamp |
| `updated_at` | INTEGER | Milliseconds timestamp |
| `deck_id` | INTEGER | FK → `decks(id)` (ON DELETE CASCADE) |
| `word` | TEXT | The primary English term |
| `meaning` | TEXT | Meaning/translation |
| `img` | TEXT | Relative image asset path |
| `synonyms` | TEXT | Synonym terms / image reference |
| `sound` | TEXT | Primary audio asset path |
| `defSound` | TEXT | Definition audio path |
| `usageSound` | TEXT | Usage audio path |
| `example` | TEXT | Example sentence |
| `ipa` | TEXT | IPA phonetic spelling |
| `complexity` | INTEGER DEFAULT 1 | Word difficulty level (1–7) |
| `interval` | INTEGER DEFAULT 0 | Current repetition interval |
| `reps` | INTEGER DEFAULT 0 | Number of consecutive successful repetitions |
| `due` | INTEGER | Epoch millisecond timestamp of next review |
| `last_review` | INTEGER | Epoch millisecond timestamp of last review |
| `lapses` | INTEGER DEFAULT 0 | Number of times the card was forgotten |
| `ease_factor` | REAL DEFAULT 2.5 | SM-2 ease multiplier |

### Schema reconciliation

`DatabaseHelper` runs `_reconcileSchema` on open: it inspects `PRAGMA table_info(cards)` and adds any missing of `complexity`, `synonyms`, `defSound`, `usageSound`, `last_review`, `lapses`, `ease_factor` via `ALTER TABLE … ADD COLUMN` (tolerant to per-column failures). Database version stays at 1.

### Key query behavior
- `getCardForDeck(deckId)` orders by `due ASC, id ASC`.
- `getCardLimit(limit)` returns only "complete" cards (sound + word + ipa + img + meaning, single-word).
- Aggregates: learned counts (`interval>2 AND reps>2`), master counts (`reps>3 AND interval>2.2`), and per-level queries by `complexity`.

---

## `user.db` (UserDatabaseHelper)

All tables are created in a transaction on first open.

### Table: `app_user`

| Field | Type | Description |
|---|---|---|
| `id` | TEXT PRIMARY KEY | User ID (UUID) |
| `name` | TEXT | Display name |
| `created_at` | TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP | Created timestamp |
| `avatar_url` | TEXT | Avatar path |
| `email` | TEXT | Email |
| `phone_number` | TEXT | Phone |
| `updated_at` | TEXT | Updated timestamp |

### Table: `history_lesson`

| Field | Type | Description |
|---|---|---|
| `id` | INTEGER PRIMARY KEY AUTOINCREMENT | Row ID |
| `user_id` | TEXT NOT NULL | FK → `app_user(id)` |
| `lesson_type` | INTEGER NOT NULL | CHECK IN (0,1,2,3); maps to `LessonType` by index |
| `accuracy` | INTEGER | Accuracy percentage |
| `time_spent` | INTEGER | Time spent |

### Table: `card_history`

| Field | Type | Description |
|---|---|---|
| `id` | INTEGER PRIMARY KEY AUTOINCREMENT | Row ID |
| `user_id` | TEXT NOT NULL | FK → `app_user(id)` |
| `card_id` | INTEGER NOT NULL | Referenced card |
| `success` | INTEGER NOT NULL | CHECK IN (0,1); whether the review was successful |

### Table: `daily_user_usage`

| Field | Type | Description |
|---|---|---|
| `id` | INTEGER PRIMARY KEY AUTOINCREMENT | Row ID |
| `user_id` | TEXT NOT NULL | FK → `app_user(id)` |
| `date` | TEXT NOT NULL | Date string (`d/M/yyyy`) |
| `amount` | INTEGER NOT NULL | Usage amount (minutes) |
| | | UNIQUE (`user_id`, `date`) |

### DAOs (`lib/data/user_database/`)
- `UserDao` — single-user model: create/fetch the local user, update name/email/phone/avatar.
- `HistoryLessonDao` — insert/fetch lessons, aggregate per-lesson-type stats and daily trends.
- `DailyUsageDao` — add usage time, upsert daily usage, current/longest streak, monthly/yearly activity.
- `CardHistoryDao` — insert/fetch card review history, review stats, and leech-card listing.

---

## Date/time note
- `Flashcard` and `Deck` use epoch-millisecond integers for timestamps.
- `User` uses ISO-8601 strings; `DailyUsage.date` uses `d/M/yyyy` strings.
