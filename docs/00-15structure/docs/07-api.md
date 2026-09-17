# API Spec (Local-First)

Currently, the application runs entirely offline and interacts directly with local SQLite databases. 

## Local SQLite Methods (`DatabaseHelper`)

### Decks
- `insertDeck(Deck deck)`: Saves new deck metadata.
- `getDecks()`: Fetches all decks ordered by update date.
- `deleteDeck(int id)`: Cascading deletion of a deck and all related cards.

### Cards
- `insertCard(Flashcard card)`: Inserts a card.
- `updateCard(Flashcard card)`: Standard update for reviews.
- `getCardForDeck(int deckId)`: Fetches cards in a deck ordered by `due` date.
- `getDueCardsForDeck(int deckId)`: Fetches cards where `due <= current_timestamp`.

---

## Future Synchronized API
When building cloud synchronization, the API endpoints will follow:

### GET `/api/decks`
- Fetches all user decks and stats.

### POST `/api/decks/sync`
- Sends locally updated reviews to update the cloud DB.

### GET `/api/cards/due`
- Returns due cards list from server.
