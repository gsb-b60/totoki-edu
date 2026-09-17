# Spec: User Profile & Statistics

## Purpose
Visualizes user progress metrics, daily review streak, and learning milestones to encourage daily habit loop.

## Layout
- **Avatar Area**: User nickname and rank status (Bronze to Challenger level).
- **Streak Stats Card**: 
  - Day streak count (e.g. `🔥 12 Days`).
  - Weekly activity grid (grid of 7 days showing checked days).
- **Metric Cards Grid**:
  - Total Reviewed Cards.
  - Correct Rate percentage.
  - Active vocabulary size (Mastered cards).

## Interactions & Behavior
- Weekly checkmarks are updated in real-time when the daily lesson/review session completes.
- Streak is reset if the user misses reviewing cards for a full calendar day.
