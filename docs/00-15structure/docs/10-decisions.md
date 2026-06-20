# Architectural Decision Log (ADR)

## 2026-06-19: Provider State Management
- **Decision**: We chose standard `Provider` instead of complex setups like Riverpod or Bloc for managing Deck and Card lists.
- **Reason**: The application has simple local state scopes that benefit from straightforward ChangeNotifier triggers.
- **Implication**: Any new global states must extend `ChangeNotifier` and be declared in `main.dart`'s MultiProvider block.

---

## 2026-06-19: SQLite (Sqflite) local database helper
- **Decision**: We implemented an offline-first SQLite layout.
- **Reason**: Requires immediate responsive queries of large flashcard lists (containing 5,000+ words with audio paths) without cellular connectivity.
- **Implication**: All queries must handle asynchronous futures. Any DB schema migrations must be registered in the `_reconcileSchema` method.
