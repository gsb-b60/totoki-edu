import 'package:flutter/material.dart';
import 'package:totoki_extract/features/ielts/models/article_fragment.dart';
import 'package:totoki_extract/features/ielts/models/paragraph_group.dart';
import 'package:totoki_extract/features/ielts/models/review_item.dart';
import 'package:totoki_extract/features/ielts/parsers/reading_passage_parser.dart';

class ReadingNoti extends ChangeNotifier {
  String title = "";
  String articleText = "";
  List<ArticleFragment> articleFragments = [];
  List<ParagraphGroup> questions = [];
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic> _dictionary = {};

  // UI State
  int currentParagraph = 0;
  List<int?> selections = [];
  List<String> textInputs = [];
  bool answered = false;
  final Map<int, List<int?>> savedSelections = {};
  final Map<int, List<String>> savedTextInputs = {};
  final Set<int> submittedParagraphs = {};

  bool get hasError => errorMessage != null;

  bool get currentIsSubmitted => submittedParagraphs.contains(currentParagraph);

  bool get allParagraphsComplete {
    for (int i = 0; i < questions.length; i++) {
      final pg = questions[i];
      if (pg.type.startsWith("input-")) {
        final inputs = i == currentParagraph ? textInputs : savedTextInputs[i];
        if (inputs == null || inputs.any((s) => s.trim().isEmpty)) return false;
      } else {
        final sel = i == currentParagraph ? selections : savedSelections[i];
        if (sel == null || sel.any((s) => s == null)) return false;
      }
    }
    return true;
  }

  String? lookupWord(String word) {
    final entry = _dictionary[word.toLowerCase()];
    return entry?["quick_def"] as String?;
  }

  Future<void> loadPassage({
    required int seriesId,
    required int testId,
    required int part,
    required int questionGroup,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await ReadingPassageParser.parse(
        seriesId: seriesId,
        testId: testId,
        part: part,
        questionGroup: questionGroup,
      );

      title = result.title;
      articleFragments = result.fragments;
      articleText = result.articleText;
      questions = result.questions;
      _dictionary = result.dictionary;
      errorMessage = null;

      // Reset UI state
      currentParagraph = 0;
      submittedParagraphs.clear();
      savedSelections.clear();
      savedTextInputs.clear();
      answered = false;

      for (int i = 0; i < questions.length; i++) {
        final pg = questions[i];
        savedSelections[i] = List.filled(pg.answers.length, null);
        savedTextInputs[i] = List.filled(pg.textAnswers.length, "");
      }

      if (questions.isNotEmpty) {
        final first = questions[0];
        selections = List.filled(first.answers.length, null);
        textInputs = List.filled(first.textAnswers.length, "");
      } else {
        selections = [];
        textInputs = [];
      }
    } on ReadingPassageException catch (e) {
      errorMessage = e.message;
      questions = [];
      selections = [];
      textInputs = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void submit() {
    saveCurrentSelections();
    for (int i = 0; i < questions.length; i++) {
      submittedParagraphs.add(i);
    }
    answered = true;
    notifyListeners();
  }

  void saveCurrentSelections() {
    final pg = questions[currentParagraph];
    if (pg.type.startsWith("input-")) {
      savedTextInputs[currentParagraph] = List.from(textInputs);
    } else {
      savedSelections[currentParagraph] = List.from(selections);
    }
  }

  void loadSelectionsFor(int index) {
    final pg = questions[index];
    if (pg.type.startsWith("input-")) {
      final saved = savedTextInputs[index];
      textInputs = saved != null && saved.length == pg.textAnswers.length
          ? List.from(saved)
          : List.filled(pg.textAnswers.length, "");
    } else {
      final saved = savedSelections[index];
      selections = saved != null && saved.length == pg.answers.length
          ? List.from(saved)
          : List.filled(pg.answers.length, null);
    }
  }

  void goToParagraph(int index) {
    if (index < 0 || index >= questions.length) return;
    saveCurrentSelections();
    currentParagraph = index;
    answered = false;
    loadSelectionsFor(index);
    notifyListeners();
  }

  void next() {
    if (currentParagraph < questions.length - 1) {
      goToParagraph(currentParagraph + 1);
    }
  }

  void prev() {
    if (currentParagraph > 0) {
      goToParagraph(currentParagraph - 1);
    }
  }

  void dismissReview() {
    answered = false;
    notifyListeners();
  }

  void updateSelection(int blankIdx, int? optIdx) {
    if (blankIdx >= 0 && blankIdx < selections.length) {
      selections[blankIdx] = optIdx;
      notifyListeners();
    }
  }

  void updateTextInput(int idx, String value) {
    if (idx >= 0 && idx < textInputs.length) {
      textInputs[idx] = value;
      notifyListeners();
    }
  }

  ({bool allCorrect, String correctAnswerStr}) checkCurrentAnswer() {
    final pg = questions[currentParagraph];
    final isSubmitted = submittedParagraphs.contains(currentParagraph);
    if (!isSubmitted) return (allCorrect: false, correctAnswerStr: '');

    bool allCorrect = true;
    final parts = <String>[];

    if (pg.type.startsWith("input-")) {
      for (int i = 0; i < pg.textAnswers.length; i++) {
        parts.add(pg.textAnswers[i]);
        if (i >= textInputs.length ||
            textInputs[i].trim().toLowerCase() != pg.textAnswers[i].trim().toLowerCase()) {
          allCorrect = false;
        }
      }
    } else {
      for (int i = 0; i < pg.answers.length; i++) {
        if (i < pg.options.length) {
          parts.add(pg.options[pg.answers[i]]);
        }
        if (i >= selections.length || selections[i] != pg.answers[i]) {
          allCorrect = false;
        }
      }
    }

    return (allCorrect: allCorrect, correctAnswerStr: parts.join(', '));
  }

  List<ReviewItem> getReviewItems() {
    return questions.asMap().entries.map((e) {
      final i = e.key;
      final pg = e.value;
      final userSel = i == currentParagraph ? selections : (savedSelections[i] ?? []);
      final userText = i == currentParagraph ? textInputs : (savedTextInputs[i] ?? []);
      final isCorrect = _checkCorrectForParagraph(pg, userSel, userText);
      return ReviewItem(
        index: i,
        question: pg,
        userSelections: userSel,
        userTextInputs: userText,
        correctSelections: pg.answers,
        correctTextAnswers: pg.textAnswers,
        isCorrect: isCorrect,
      );
    }).toList();
  }

  bool _checkCorrectForParagraph(ParagraphGroup pg, List<int?> userSel, List<String> userText) {
    if (pg.type.startsWith("input-")) {
      for (int i = 0; i < pg.textAnswers.length; i++) {
        final user = i < userText.length ? userText[i] : '';
        if (user.trim().toLowerCase() != pg.textAnswers[i].trim().toLowerCase()) {
          return false;
        }
      }
      return true;
    } else {
      for (int i = 0; i < pg.answers.length; i++) {
        if (i >= userSel.length || userSel[i] != pg.answers[i]) {
          return false;
        }
      }
      return true;
    }
  }

  void retryCurrentParagraph() {
    final pg = questions[currentParagraph];
    if (pg.type.startsWith("input-")) {
      textInputs = List.filled(pg.textAnswers.length, "");
    } else {
      selections = List.filled(pg.answers.length, null);
    }
    answered = false;
    notifyListeners();
  }
}