# Spec: Deck Viewer Screen

## Purpose
Allows users to explore all flashcard words contained within a selected deck, search for specific terms, and view statistics.

## Layout
- **App Bar**: Deck Name with card count.
- **Search Bar**: Quick-filter by keyword (searches both the primary English word and translation field).
- **Cards List**: Scrollable list of cards showing:
  - The English word and IPA spelling.
  - Translation preview.
  - Interval weight indicator (number of days/minutes until next due).
  - Audio playback button.

## Interactions & Behavior
- Tapping a card opens the card editor bottom sheet.
- Search query is debounced to avoid layout jitter during typing.
