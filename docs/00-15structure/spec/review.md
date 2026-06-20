# Spec: Card Review Screen

## Purpose
Enables users to review due cards using a standard front-to-back flip design.

## Layout
- **Top**: Progress indicator (e.g., `5 / 20` cards completed).
- **Center**: The interactive flashcard box.
  - Front: English Word, IPA transcription, and a tap-to-listen audio button.
  - Back: Word meaning, English synonyms, example sentence, and card image.
- **Bottom**: Feedback selection bar shown after card flip:
  - `Forgot` (Red, rate 1)
  - `Hard` (Orange, rate 2)
  - `Good` (Blue, rate 3)
  - `Easy` (Teal, rate 4)
  - `Very Easy` (Green, rate 5)

## Mechanics
- Uses the `flip_card` package for flip transitions.
- Tapping a rate button calls `updateCardReview(card, rate)` inside `supermemo.dart`, saves it to the SQLite database, and automatically pushes the next card onto the stack.
- Plays vibration effects via the `Vibration` library if the user rates a card as `Forgot` or `Hard`.
