# Spec: Calendar Screen

## Purpose
A 3-view calendar (Day, Week, Month) for reviewing completed study sessions, tracking streaks, and visualizing learning activity over time.

## Layout
- **Header**: `<` month/year `>` with Today tap, 🔥 streak badge on right when active
- **Format Toggle**: Day | Week | Month chips + "Today" text button
- **Body**: Switches between three view widgets based on selected format

### Month View
- 7-column grid of day cells, one row per week
- Each cell: day number + heatmap bar (width = cards studied intensity)
- Colors: `greenPrimary` (30+), `greenBright` (15+), `greenMuted` (5+), `greenMuted 50%` (1+)
- Selected day: teal highlight
- Today: teal tint

### Week View
- 7-day header: abbreviated name, date, activity dot
- Scrollable session card list below
- Each card: date, card count, correct/wrong/duration badges, accuracy pill
- Accuracy pill color: green ≥80%, yellow ≥50%, red <50%

### Day View
- 24-hour vertical timeline (0:00–23:00) at 60px per hour
- Hour labels on left, thin separator lines
- Session blocks positioned by start time, height = duration
- Block color: teal with border
- Current time: red circle + line

## Interactions
- **Tap a day** (Month): Opens bottom sheet listing all sessions for that date
- **Tap a session card** (Week): Opens session detail bottom sheet
- **Tap a session block** (Day): Opens session detail bottom sheet
- **Format toggle**: Switches body view immediately, data reloads for new range
- **Navigation arrows**: Move to previous/next month, week, or day
- **Tap title / "Today"**: Reset to current date in current format

## Session Detail Bottom Sheet
- Date header
- 4 metric tiles: Cards, Correct, Wrong, Duration
- Accuracy progress bar with percentage
- Study mode label (if present)

## Data Dependencies
- `CalendarModel` loaded from `DatabaseHelper.sessions` table
- Streak from `DatabaseHelper.getCurrentStreak()`
- Session auto-logged from `EndScreen` > `LessonNoti` data
