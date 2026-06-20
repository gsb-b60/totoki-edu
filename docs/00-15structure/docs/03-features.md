# Core Features

## 1. Deck Import System
- Imports Anki `.apkg` or zip packages containing flashcards (`.db` files).
- Extracts deck media, images, and audio assets to device local storage.
- Auto-registers decks and cards inside the SQLite database helper.

## 2. Spaced Repetition (SRS)
- Cards are scheduled dynamically using the SM-2 algorithm.
- Tracks intervals, repetitions, lapses, ease factors, and due dates.
- Shows current daily due count directly on the deck list dashboard.

## 3. Daily Lesson
- A guided learning session combining new cards and review items in one session.
- Helps user maintain their streak via custom notifications.

## 4. Multi-Study Game Modes
Supports 14 distinct study modules to reduce vocabulary learning fatigue:
1. **Flashcard**: Traditional flip-and-rate style.
2. **MeanFuse**: Matching meanings to terms.
3. **WordSnap**: Drag and drop speed matching.
4. **MindField**: Multiple choice quiz.
5. **EchoSpell**: Audio-based spelling game.
6. **EchoMatch**: Audio matching game.
7. **EchoFuse**: Speed audio vocabulary game.
8. **NeuroPick**: Recall selection under timer pressure.
9. **WordPulse**: High-frequency interactive matching.
10. **Sound & Sight**: Voice-activated pronunciation matching.
11. **SpeechWord**: Speech-to-text pronunciation evaluation.
12. **SynonymField**: Multiple choice for synonyms.
13. **SynonymPick**: Choose synonyms out of a grid.
14. **PhoneMix**: Phonetic syllable builder.
