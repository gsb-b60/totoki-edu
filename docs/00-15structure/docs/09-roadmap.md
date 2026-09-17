# Project Roadmap

## Done
- Local SQLite databases (`flashcards.db` for decks/cards/SRS, `user.db` for profile/usage/analytics).
- SM-2 spaced-repetition schedulers (`computeSM2` and `updateCardReview`).
- Anki `.apkg` package import pipeline (unzip, collection DB read, media extraction, note-model mapping, complexity scoring).
- Dark theme and typography tokens in `AppTheme`.
- Deck list / card list / learn-mode / analyze / dashboard / history / profile screens.
- 14 routable study mini-games.
- Guided lesson system (start → steps → end, per-mode fetchers, timer, accuracy, SM-2 rating, history save).
- IELTS reading module (asset parsers, question types, passages screen, review).
- Penpal letter-writing practice game.
- User analytics (lesson stats, card review stats, streak/activity).
- Unit + widget test suites (`test/unit`, `test/widget`), top-level parsing/history tests, and an integration test.
- GitHub Actions CI (`.github/workflows/ci.yml`): `flutter analyze` + `flutter test` on push/PR.

## Doing
- Refining gameplay across the study modes.
- Expanding IELTS content coverage and question-type handling.
- Improving statistics reporting and analytics UI.

## Next
- Push-notification daily reminders.
- Voice-feedback validation with advanced speech-to-text algorithms.
- Remote server backup/synchronization.
- Expanded IELTS skills (listening/writing/speaking) beyond reading.
