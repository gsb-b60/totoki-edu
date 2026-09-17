# Business Rules

## Spaced Repetition System (SM-2)

The application provides two spaced-repetition schedulers in `lib/business/flashcard/`:

1. **`computeSM2`** in `scheduler.dart` — used by `Cardmodel.updateCardAfterReview` (flashcard review mode).
2. **`updateCardReview`** in `supermemo.dart` — used by the lesson flow for per-card ratings.

---

## 1. `computeSM2` (`lib/business/flashcard/scheduler.dart`)

Signature: `NextSchedule computeSM2({required int quality, int prevInterval = 0, int prevReps = 0, double prevEF = 2.5})`.

- **Quality < 3 (failed):** `reps = 0`, `intervalDays = 1`.
- **Quality ≥ 3 (passed):** `reps = prevReps + 1`; interval is `1` (rep 1), `6` (rep 2), otherwise `prevInterval * ef` rounded (floored at 1 day).
- **EF update:** `ef = ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))`, floored at `1.3`.

Returns a `NextSchedule(intervalDays, reps, easeFactor)`.

`Cardmodel.updateCardAfterReview(card, quality)` converts a legacy rating to a 0–5 quality input (`>=3 → 5`, `==2 → 4`, else `→ 2`), calls `computeSM2`, increments `lapses` on failure, persists via `updateCard`, and stores the previous schedule for `undoLastReview()`.

---

## 2. `updateCardReview` (`lib/business/flashcard/supermemo.dart`)

Signature: `Flashcard updateCardReview(Flashcard card, int feed)` where `feed` is 1–5.

### Difficulty ratings (feedback)
| Feed | Label | Ease change |
|---|---|---|
| 1 | Forgot | −0.3 |
| 2 | Hard | −0.15 |
| 3 | Good | 0.0 |
| 4 | Easy | +0.1 |
| 5 | Very Easy | +0.25 |

### Ease factor
- Baseline ease factor defaults to `1.5` if missing.
- A randomized jitter between `0.95` and `1.05` is applied.
- New ease is clamped to `[1.3, 2.3]`:
  `newEase = clamp(easeFactor + easeChange − 0.005, 1.3, 2.3)`.

### Repetition and interval rules

**A. Feed < 3 (forgot/struggled):**
- `lapses += 1`, `reps = 0`.
- `interval = clamp(round(interval × 0.5), 1, 2)` days.
- Due = now + interval days.

**B. Feed ≥ 3 (recalled successfully):**
- `reps += 1`.
- `interval = clamp(round(interval × newEase × jitter), 1, 9999)`.
- Due:
  - If `reps < 3`: now + `(interval × reps + 5)` minutes (short-term reinforcement).
  - Else: now + interval days.

`SMNoti.updateCardAfterReview(card, rate)` calls `updateCardReview` and persists via `DatabaseHelper.updateCard`.

---

## Lesson accuracy thresholds (`lib/ui/lesson/config/threshold.dart`)
- **Accuracy:** excellent (≤1 wrong) / great (≤2) / good (≤4) / fair (≤6).
- **Time:** Super (≤90s) / Quick (≤180s) / Moderate (≤280s) / slow (≤380s).
