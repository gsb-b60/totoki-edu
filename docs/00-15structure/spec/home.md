# Spec: Dashboard / Home Screen

## Purpose
The home screen serves as the launchpad where users select card decks, import new content, and check their daily due counts.

## Layout
- **Header**: App Logo with statistics (Current Day Streak, Total Reviewed, Mastered Words).
- **Deck List Grid**: Custom cards showing:
  - Deck name (formatted using `Deck.extractCardName`).
  - Total card counts & due card count (in red color if > 0).
  - Tap handler to go to card overview screen.
  - Delete button (calls `Deckmodel.deleteDeck` and triggers a SnackBar confirmation).
- **Bottom Action Area**: Floating Action Button (FAB) or Button to import new card archives (`.db` files) via a file picker.

## Interactions & Behavior
- On launch: `Deckmodel.hadDB()` checks if a local database exists. If empty, auto-opens the file picker for initial import.
- Deleting a deck shows a SnackBar to undo or confirm removal.
