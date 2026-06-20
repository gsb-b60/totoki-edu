# User Flow

## Main Application Flow
```
Launch App
   ↓
Dashboard / Deck List (Checks SQLite DB Import)
   ↓
Select Deck (or Tap "Daily Lesson")
   ↓
Choose Study Mode (14 Game-like Modes available)
   ↓
Study Mode Session (Answer cards/words)
   ↓
Result Screen (Earn points / update card weights)
   ↓
Return to Dashboard
```

## Flashcard SRS Flow
```
Display Card (Front)
   ↓
Tap to Flip Card (Back) / Listen to Audio
   ↓
User Rates Difficulty:
[Forgot]  [Hard]  [Good]  [Easy]  [Very Easy]
   ↓
Algorithm (SM-2) calculates new ease factor and due time
   ↓
Write back updated cards to Database
   ↓
Go to next card or exit if finished
```
