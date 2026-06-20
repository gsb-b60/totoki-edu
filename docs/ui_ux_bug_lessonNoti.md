# UI/UX Bugs in `lessonNoti.dart`

During the review of `lib/ui/lesson/dailyLesson/noti/lessonNoti.dart`, two critical UI/UX bugs were identified that can lead to application freezes (infinite loops) and crashes (race conditions).

---

## 1. Infinite Loop (App Freeze) on Short Words

### Why the Bug Happens
In the `genOptions()` method, the app tries to generate exactly two distractors (incorrect options) for a multiple-choice question by shuffling the letters of the target `word`. It ensures the generated options are unique using a `do...while` loop:

```dart
do {
  mixed = generateVariant(word, rand);
} while (mixed == word || strs.contains(mixed));
```

The problem arises when the target word has **fewer than 3 unique letter permutations**.
- If the word has 1 letter (e.g., `"a"`, `"I"`), there is only 1 permutation.
- If the word has 2 letters (e.g., `"to"`, `"is"`, `"he"`), there are only 2 permutations.
- If the word has repeated letters (e.g., `"egg"`), it may have very few permutations.

Because the code rigidly attempts to collect 3 distinct strings (the correct word + 2 distractors), any word with fewer than 3 permutations will trap the app in the `do...while` loop forever, permanently freezing the UI.

### Plan to Fix
Modify `genOptions()` to handle short words or words with few permutations gracefully:
1. Limit the `do...while` loops with a maximum number of attempts (e.g., `int attempts = 0; while (... && attempts < 10)`).
2. If the maximum attempts are reached, generate fallback distractors by appending or replacing characters with random letters from the alphabet, ensuring the list always reaches the required size without looping infinitely.

---

## 2. Race Condition Crash in Match Game (`_checkMath`)

### Why the Bug Happens
In the word-to-IPA matching game, selecting an incorrect pair triggers a 300-millisecond delay before resetting the button states and clearing the selections:

```dart
Future.delayed(Duration(milliseconds: 300), () {
  ipaState[selectedIPAIDX!] = ButtonState.normal;
  wordState[selectedWordIDX!] = ButtonState.normal;
  selectedWordIDX = null;
  selectedIPAIDX = null;
  notifyListeners();
});
```

If a user taps *another* pair of buttons rapidly before this 300ms delay finishes, `selectedWordIDX` and `selectedIPAIDX` are updated to new values. 
When the first 300ms delay finally resolves, it clears `selectedWordIDX` and `selectedIPAIDX` (setting them to `null`). 
Then, when the *second* 300ms delay resolves, the app attempts to read `selectedIPAIDX!`, encountering a `Null check operator used on a null value` exception, causing a red screen / app crash.

### Plan to Fix
Capture the currently selected indices in local variables *before* the `Future.delayed` executes, so the callback only operates on the indices that triggered it:

```dart
final currentWordIdx = selectedWordIDX!;
final currentIpaIdx = selectedIPAIDX!;

selectedWordIDX = null;
selectedIPAIDX = null;

Future.delayed(Duration(milliseconds: 300), () {
  if (wordState[currentWordIdx] == ButtonState.wrong) {
    wordState[currentWordIdx] = ButtonState.normal;
  }
  if (ipaState[currentIpaIdx] == ButtonState.wrong) {
    ipaState[currentIpaIdx] = ButtonState.normal;
  }
  notifyListeners();
});
```
This guarantees the callback doesn't interfere with subsequent user taps and never accesses a globally modified nullable variable using the bang operator (`!`).
