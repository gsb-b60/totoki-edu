# Totoki Flashcard - App Design Principles

This document defines the visual language, UI architecture, and UX standards for the Totoki Flashcard application. All future UI development and refactoring must adhere to these guidelines to maintain consistency.

## 1. Core Philosophy: "The Vertical Focus"
Unlike the original game-based parent project, this application is built for **Portrait (Vertical)** mobile use. 
*   **Safe Areas**: Always respect `MediaQuery.of(context).padding` for notches and home indicators.
*   **Thumb Zone**: Primary actions (Check, Next, Flip) should be placed in the bottom 40% of the screen.
*   **Flexible Layouts**: Use `LayoutBuilder` and `Flexible`/`Expanded` instead of fixed `height` or `width` constants to support varying screen aspect ratios.

## 2. Color System (The "Cyber-SRS" Aesthetic)
The app uses a professional dark theme with vibrant semantic highlights. All colors must be referenced via `AppTheme`.

### 2.1 Base Surfaces
| Layer | Color Constant | Usage |
| :--- | :--- | :--- |
| **Background** | `AppTheme.darkBase` | Main scaffold background. |
| **Surface** | `AppTheme.darkSurface` | Secondary areas (e.g., card backgrounds, bottom sheets). |
| **Active/Elevation** | `AppTheme.darkCard` | Interactive elements, elevated cards. |
| **Border** | `AppTheme.darkBorder` | Subtle separators and outlines. |
| **Primary Text** | `AppTheme.lightText` | Default text color for most elements. |
| **Accent/Interactive** | `AppTheme.bluePrimary` | Highlighted elements, primary interactive components. |

### 2.2 Semantic & Feedback Colors
*   **Correct/Success**: `AppTheme.greenPrimary` (FlashcardTheme.correct)
*   **Wrong/Error**: `AppTheme.redPrimary` (FlashcardTheme.wrong)
*   **Pending/Warning**: `AppTheme.yellowPrimary` (FlashcardTheme.pending)
*   **Primary Action**: `AppTheme.primaryTeal`

### 2.3 Study Mode Palette
Each study mode has a distinct color identity. Use `FlashcardTheme.getStudyModeColor(mode)` to retrieve:
*   **MeanFuse**: Moss Green (`#4A7C59`)
*   **WordSnap**: Blue-Grey Teal (`#3C6E71`)
*   **EchoSpell**: Deep Emerald (`#1C7C54`)
*   **NeuroPick**: Bronze Brown (`#916953`)

## 3. Component Standards

### 3.1 Buttons
*   **Primary Action**: Large, rounded corners (12px-16px), using `primaryTeal` or `greenPrimary`.
*   **Choice Buttons**: High-contrast text on `darkSurface` or `darkCard`. Status changes (correct/wrong) should animate the background color.
*   **Vertical Alignment**: Use `lib/widget/choiceBtnVertical.dart` for multiple-choice lists.

### 3.2 Typography Scale
Use a consistent hierarchy to guide the user's eye.

| Level | Size Range | Weight | Usage |
| :--- | :--- | :--- | :--- |
| **Flashcard Hero** | 36px - 48px | Bold | Primary word/prompt in study mode. |
| **Screen Title** | 28px - 32px | Bold | Main app bar or header titles. |
| **Section Header** | 20px - 24px | Semibold | Sub-titles (e.g., Deck names in list). |
| **Body (Large)** | 16px - 18px | Regular | Important descriptions, primary button text. |
| **Body (Medium)** | 14px - 16px | Regular | Standard readable text (meanings, examples). |
| **Small/Caption** | 12px | Light/Italic | IPA, metadata (Due dates, intervals). |

*   **Color**: Use `AppTheme.lightText` as the base.
*   **Opacity**: Reduce opacity (0.7) for metadata or secondary info to create visual depth.
*   **Font**: Prefer Material 3 default or "Roboto" for IPA symbols.

## 4. UI Architecture (Rules for Agents)

### Rule 1: No Hardcoded Dimensions
Never use `width: 360` or `height: 800`. Use `MediaQuery` percentages or `Flex` layouts.
*   *Bad*: `Container(height: 200)`
*   *Good*: `SizedBox(height: MediaQuery.of(context).size.height * 0.25)`

### Rule 2: Component Reusability
Before building a widget, check `lib/widget/`. If you are building a new type of button or progress bar, place it in `lib/widget/` and name it descriptively (e.g., `ChoiceBtnVertical.dart`).

### Rule 3: Visual Polish
*   **Haptics**: Use `Vibration` for feedback on "Wrong" or "Correct" answers.
*   **Transitions**: Use subtle animations (e.g., `FadeIn`, `SlideTransition`) when switching between study modes in `LessonScreen`.

### Rule 4: Information Density
Avoid clutter. In study mode, the **Word/Prompt** is the hero. Secondary data (meaning, examples) should be revealed only when necessary or kept in a non-distracting area.

## 5. Guide for Next Agent
When building a new screen:
1.  **Context**: Start by checking `AppTheme` for colors.
2.  **Layout**: Wrap your UI in a `SafeArea` and use a `Column` or `ListView`.
3.  **Theming**: Use `Theme.of(context).textTheme` to ensure text colors follow the dark-mode standard.
4.  **Media**: Use `PathService` to resolve any image or audio files; never assume a file exists without a guard.
