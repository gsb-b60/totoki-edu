# IELTS Screen Architecture

## Directory Tree

```
lib/ui/screens/ielts/
├── ielts_training.dart          # Entry: routes to listening/reading/speaking/writing tabs
├── tabs/
│   ├── reading_tab.dart         # Tab host → opens PassagesScreen
│   ├── listening_tab.dart
│   ├── speaking_tab.dart
│   └── writing_tab.dart
├── passages/
│   ├── passages_screen.dart     # Main passage Q&A screen (state + scaffold)
│   └── questionType/            # One widget per question type
│       ├── checkbox_widget.dart
│       ├── input_answer.dart
│       ├── input_diagram.dart
│       ├── input_table.dart
│       ├── option_btn.dart
│       ├── option_choice.dart
│       ├── select_given_diagram.dart
│       └── select_summary_given_list.dart
└── widgets/                     # Shared/reusable widgets
    ├── article_viewer.dart      # Renders article text with tappable word definitions
    ├── answer_bottom_bar.dart   # Back / Submit-Dismiss / Next row
    ├── ielts_card.dart          # Generic card used in tab listings
    ├── nav_btn.dart             # Back / Next button
    ├── picture_viewer.dart      # Full-screen image viewer
    ├── question_panel.dart      # Routes pg.type → correct questionType widget
    └── submit_btn.dart          # Submit / Dismiss button
```

## How to Update

### Add a new question type
1. Create widget in `passages/questionType/`
2. Add route in `widgets/question_panel.dart` (in its `build` method)

### Modify the bottom bar
- Edit `widgets/answer_bottom_bar.dart` (stateless, takes callbacks)
- Buttons: `widgets/nav_btn.dart` and `widgets/submit_btn.dart`

### Change article rendering
- Edit `widgets/article_viewer.dart` (stateful, manages word-definition overlay)

### Change screen logic (navigation, submission, answer checking)
- Edit `passages/passages_screen.dart` — the state class `_PassagesScreenState`

### Modify question-type routing
- Edit `widgets/question_panel.dart`

### Data flows down, callbacks up
- Screen owns state (`_selections`, `_textInputs`, `_answered`, etc.)
- Passes data as params to child widgets
- Child widgets fire callbacks → screen calls `setState`
