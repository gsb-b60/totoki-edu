# Architecture

## Layer Architecture
The project follows a clean layer separation approach:

```
┌──────────────────────────────────────────────┐
│                    ui/                       │ (UI Screens & custom Widgets)
└──────────────────────┬───────────────────────┘
                       ▼
┌──────────────────────────────────────────────┐
│                 business/                    │ (Decks/Cards State, SuperMemo algorithm)
└──────────────────────┬───────────────────────┘
                       ▼
┌──────────────────────────────────────────────┐
│                    data/                     │ (SQLite Database Helper, File Mappers)
└──────────────────────────────────────────────┘
```

## Directory structure inside `lib/`
- **`lib/ui/`**: 
  - `screens/`: Contains screen-level files like `studymode/` and `decklist/`.
  - `widget/`: General reusable widgets.
  - `theme/`: App styling theme properties.
- **`lib/business/`**:
  - `flashcard/`: SuperMemo scheduler and data models (`Deck.dart`, `Flashcard.dart`).
  - `path_service.dart`: Handles file directories and paths.
- **`lib/data/`**:
  - `database_helper.dart`: Handles sqflite operations and schema initialization.
  - `flashCard_Mapper.dart`: Converts raw database maps into object instances.

## State Management
- Managed using the standard Flutter `provider` package.
- `Deckmodel` & `Cardmodel` extend `ChangeNotifier` to notify listeners (UI screens) when decks are imported, deleted, or reviewed.
