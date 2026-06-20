# Spec: Achievements & Ranks

## Purpose
Gamification engine that awards user badges and ranks to make vocabulary acquisition feel like leveling up in a game.

## Layout
- **Current Rank Section**: Highlights user tier (Bronze, Silver, Gold, Amber, Platinum, Diamond, Master, Challenger).
- **Badges List**: List of unlocked and locked badges (e.g. "Early Bird", "Vocabulary Master", "Streak King").
- **Points/XP bar**: Progress bar showing how much XP is needed to reach the next tier.

## Rules & Ranks Table
Ranks are mapped to static theme colors in `AppTheme`:

- **Bronze**: Initial entry level (`Color(0xFFCD7F32)`).
- **Silver**: 100+ mastered cards (`Color(0xFFC0C0C0)`).
- **Gold**: 300+ mastered cards (`Colors.amber`).
- **Amber**: 500+ mastered cards (`Color(0xFFFFD700)`).
- **Platinum**: 1000+ mastered cards (`Color(0xFFE5E4E2)`).
- **Diamond**: 2000+ mastered cards (`Color(0xFFB9F2FF)`).
- **Challenger**: 5000+ mastered cards (`Color(0xFF8A2BE2)`).
