# Learning Session Calendar

## Purpose
A Google Calendar-like tab for viewing completed study sessions across Day, Week, and Month views. Sessions are auto-logged when a daily lesson finishes, giving users a visual history of their learning activity and streaks.

## Views

### Month View (`lib/ui/screens/calendar/month_view.dart`)
- Grid calendar using `table_calendar` package
- Each day cell shows a heatmap bar — wider/darker green = more cards studied that day
- Tapping a day opens a bottom sheet listing all sessions for that date
- Swipe left/right to change months

### Week View (`lib/ui/screens/calendar/week_view.dart`)
- 7-day header row with day name, date number, and activity indicator dot
- Scrollable list below showing session cards for the entire week
- Each card: date, cards studied, correct/wrong count, duration, accuracy badge
- Tap a card → session detail bottom sheet

### Day View (`lib/ui/screens/calendar/day_view.dart`)
- 24-hour scrollable timeline with hour labels on left
- Session blocks positioned at their estimated start time, height proportional to duration
- Current time red indicator line
- Tap a block → session detail bottom sheet

## Data Flow

1. **Auto-logging**: When a lesson completes, `EndScreen.initState()` calls `CalendarModel.logSession(Session(...))` with card counts, accuracy, duration, and study mode
2. **Loading**: `CalendarModel.init()` loads the current month's sessions and streak on app start
3. **Format switching**: Toggling Day/Week/Month calls `_loadForCurrentFormat()` which queries the `sessions` table for the relevant date range
4. **Streak**: `DatabaseHelper.getCurrentStreak()` queries distinct session dates and counts consecutive days backward from today

## File Tree

```
lib/
├── business/
│   └── calendar/
│       ├── session.dart              # Session data model (toMap/fromMap)
│       └── calendar_model.dart       # CalendarModel ChangeNotifier
├── ui/
│   └── screens/
│       └── calendar/
│           ├── calendar_screen.dart  # Header, format toggle, routes to views
│           ├── month_view.dart       # table_calendar grid + heatmap
│           ├── week_view.dart        # Week header + session card list
│           ├── day_view.dart         # 24h timeline
│           └── session_detail_sheet.dart # Bottom sheet: detail + day overview
├── data/
│   └── database_helper.dart          # + sessions table, CRUD, streak, heatmap queries
├── main.dart                          # CalendarModel provider registration
├── router/
│   └── app_router.dart               # /calendar route (StatefulShellBranch)
└── ui/
    └── screens/
        └── home/
            └── home_screen.dart      # 6th tab: Calendar
```

## Key Classes

| Class | File | Type | Role |
|---|---|---|---|
| `Session` | `session.dart` | Model | Data class with `date`, `cardsStudied`, `correctCount`, `wrongCount`, `durationSeconds`, `accuracy`, `studyMode` |
| `CalendarModel` | `calendar_model.dart` | ChangeNotifier | State: focused day, selected day, format, sessions map, daily counts, streak. Methods: `init`, `logSession`, `setFormat`, `goToToday/Prev/Next` |
| `CalendarFormat` | `calendar_model.dart` | Enum | `day`, `week`, `month` |

## Database Table: `sessions`

| Field | Type | Description |
|---|---|---|
| `id` | INTEGER PK AUTOINCREMENT | Unique session ID |
| `date` | TEXT NOT NULL | `yyyy-MM-dd` format |
| `cards_studied` | INTEGER | Total cards answered |
| `correct_count` | INTEGER | Correct answers |
| `wrong_count` | INTEGER | Wrong answers |
| `duration_seconds` | INTEGER | Session length |
| `accuracy` | REAL | 0.0–1.0 |
| `deck_id` | INTEGER | Nullable FK to decks |
| `study_mode` | TEXT | `daily`, `sm`, `all`, `shuffle`, `devMode` |
| `created_at` | INTEGER | Epoch milliseconds |

## Session Auto-Logging Hook

The auto-logging happens in `lib/ui/lesson/screen/endscreen.dart`:

```dart
// Inside initState after lesson completes
final timer = context.read<TimerNoti>();
final totalCards = lesson.totalRep + lesson.totalLapse;
if (totalCards > 0) {
  context.read<CalendarModel>().logSession(Session(
    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    cardsStudied: totalCards,
    correctCount: lesson.totalRep,
    wrongCount: lesson.totalLapse,
    durationSeconds: timer.time.inSeconds,
    accuracy: lesson.totalRep / totalCards,
    studyMode: lesson.how.name,
  ));
}
```

## Streak Calculation

`DatabaseHelper.getCurrentStreak()` queries `SELECT DISTINCT date FROM sessions ORDER BY date DESC`, then counts consecutive days from today (or yesterday) backward. Returns 0 if the most recent session date is older than yesterday.
