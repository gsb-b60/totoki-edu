# Crystal of English - Architecture Documentation

This document describes the architectural design and technical implementation of the "Crystal of English" project, a gamified English learning application built with Flutter and Flame.

## 1. High-Level Overview

The application follows a **Hybrid Architecture** combining a traditional Flutter UI shell with a high-performance 2D game engine (Flame).

- **Flutter Layer**: Handles non-game UI, such as menus, settings, flashcard management, and overlays. It provides the application lifecycle and state management.
- **Flame Layer (Game Engine)**: Handles the interactive RPG world, including tilemap rendering, character movement, collision detection, and the battle system.
- **State Management**: Uses the `Provider` pattern for reactive UI updates and `Singleton/Service` patterns for persistent data and global systems.
- **Data Layer**: Powered by SQLite (`sqflite`) for storing user progress, inventory, and a comprehensive flashcard system implementing Spaced Repetition (SRS).

---

## 2. Core Components & Systems

### 2.1 Game Engine (Flame)
The game logic is centered around the `MyGame` class, which extends `FlameGame`.

- **World & Camera**: Uses Flame's `World` and `CameraComponent` for rendering the overworld and dungeons.
- **Map System**: Integrated with `Tiled` maps (.tmx files) using `flame_tiled`. Maps include layers for terrain, objects, and collisions.
- **Actors**: 
  - `Player`: The user-controlled character with joystick support and collision handling.
  - `Enemy`/`EnemyWander`: NPC enemies with patrol logic and proximity triggers for battles.
  - `Npc`: Interactive characters that trigger dialogs or specialized game modes.
- **Collision System**: A custom `Collision` component parses Tiled collision layers and adds hitboxes to the game world.

### 2.2 Educational System (SRS & Quizzes)
Education is the core mechanic, integrated directly into the gameplay.

- **Flashcard System**: 
  - Implements the **SM2 algorithm** for Spaced Repetition.
  - Supports importing Anki `.apkg` files, including media (images/audio) extraction.
  - Managed via `Cardmodel` and `Deckmodel` using `Provider`.
- **Quiz System**:
  - Battles are resolved by answering English quizzes.
  - Quizzes are loaded from JSON assets and shaped based on the player's proficiency level.
  - `BattleScene` manages the transition from overworld to a turn-based combat UI driven by `QuizPanel`.

### 2.3 State & Persistence
- **PlayerProfile**: A singleton that tracks player stats (Level, XP, Gold, Hearts), current location, and inventory. It manages autosaves and manual save slots.
- **Inventory**: Manages items collected or purchased in the game.
- **DatabaseHelper**: Handles all SQLite operations, including schema migrations and complex queries for the SRS system.
- **AudioManager**: Centralized control for background music (BGM) and sound effects (SFX) using `flame_audio`.

---

## 3. Data Flow

1.  **Initialization**: 
    - `main.dart` initializes services (Audio, Profile, Database).
    - `PlayerProfile` loads the last state from the "autosave" slot.
2.  **Gameplay**:
    - `MyGame` loads the map and spawns actors.
    - Player movement triggers `Collision` checks.
    - Interacting with objects (Coins, NPCs) or triggering enemies initiates events.
3.  **Educational Interaction**:
    - Triggering a battle pauses the overworld and pushes a `BattleScene`.
    - Correct answers in the `QuizPanel` damage enemies; incorrect answers damage the player.
    - Battle outcomes update the `PlayerProfile` (XP, Gold, HP).
4.  **Flashcard Study**:
    - Accessing the "Library" or "Card Training" opens Flutter overlays (`Flashcards`, `QuizScreen`).
    - Study sessions update card intervals and due dates in the SQLite database.

---

## 4. Project Structure

- `lib/audio/`: Audio management and assets.
- `lib/components/`: Flame components (Player, Enemy, NPC, BattleScene, etc.).
- `lib/data/`: Data persistence (SQLite helpers, Anki mappers).
- `lib/dialog/`: Dialog system for NPC interactions.
- `lib/flashcard/`: Business logic and UI for the SRS system.
- `lib/quiz/`: Quiz models and repository.
- `lib/state/`: Application state management (Profile, Inventory).
- `lib/ui/`: HUD and Flutter-based UI overlays.
- `assets/`: Maps, Sprites, Fonts, Audio, and Quiz data.

---

## 5. Technical Stack

- **Framework**: Flutter
- **Game Engine**: Flame
- **Language**: Dart
- **Database**: SQLite (sqflite)
- **Maps**: Tiled (.tmx)
- **Audio**: flame_audio, audioplayers
- **State**: Provider
- **Other**: speech_to_text (for future voice features), vibration, flutter_archive (Anki import).
