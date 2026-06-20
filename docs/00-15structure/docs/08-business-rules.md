# Business Rules

## Spaced Repetition System (SM-2 Scheduler)

The application calculates the next review time using a modified SuperMemo-2 (SM-2) formula defined in `lib/business/flashcard/supermemo.dart`.

### 1. Difficulty Ratings (Feedbacks)
During review, the user rates their response from 1 to 5:
- **1 (Forgot)**: Completely forgot the card. (Ease change: -0.3)
- **2 (Hard)**: Recalled with severe difficulty. (Ease change: -0.15)
- **3 (Good)**: Recalled with normal effort. (Ease change: 0.0)
- **4 (Easy)**: Recalled easily. (Ease change: +0.1)
- **5 (Very Easy)**: Recalled immediately. (Ease change: +0.25)

---

### 2. Ease Factor Formula
- The baseline Ease Factor starts at `2.5` (or defaults to `1.5` if missing).
- The ease change is added to the ease factor:
  $$\text{newEase} = \text{clamp}(\text{easeFactor} + \text{easeChange} - 0.005, 1.3, 2.3)$$

---

### 3. Repetition and Interval Rules

#### A. If Feedback is < 3 (User forgot / struggled):
- Increment `lapses` by 1.
- Reset consecutive repetitions (`reps`) to 0.
- Reduce `interval` by half, clamped to [1, 2] days:
  $$\text{newInterval} = \text{clamp}(\text{round}(\text{interval} \times 0.5), 1, 2)$$
- Due date is set in days:
  $$\text{due} = \text{DateTime.now()} + \text{newInterval} \text{ days}$$

#### B. If Feedback is >= 3 (User recalled successfully):
- Increment `reps` by 1.
- Apply randomized jitter between 0.95 and 1.05 to avoid card bunching:
  $$\text{newInterval} = \text{clamp}(\text{round}(\text{interval} \times \text{newEase} \times \text{jitter}), 1, 9999)$$
- Due date is set:
  - If `reps < 3`: Due in minutes to allow short-term reinforcement:
    $$\text{due} = \text{DateTime.now()} + (\text{newInterval} \times \text{reps} + 5) \text{ minutes}$$
  - If `reps >= 3`: Due in days:
    $$\text{due} = \text{DateTime.now()} + \text{newInterval} \text{ days}$$
