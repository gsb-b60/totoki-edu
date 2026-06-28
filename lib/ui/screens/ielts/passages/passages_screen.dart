import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/features/ielts/notifier/reading_notifier.dart';
import 'package:totoki_extract/features/ielts/models/paragraph_group.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/select_summary_given_list.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/option_choice.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/checkbox_widget.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/input_answer.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/input_table.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/input_diagram.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/select_given_diagram.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/picture_viewer.dart';
import 'package:totoki_extract/widget/reviewScreen.dart';
import 'package:flutter/gestures.dart';

class PassagesScreen extends StatefulWidget {
  final int seriesId;
  final int testId;
  final int part;
  final int questionGroup;

  const PassagesScreen({
    super.key,
    this.seriesId = 1,
    this.testId = 1,
    this.part = 1,
    this.questionGroup = 2,
  });

  @override
  State<PassagesScreen> createState() => _PassagesScreenState();
}

class _PassagesScreenState extends State<PassagesScreen> {
  ReadingNoti? _noti;
  int _currentParagraph = 0;
  List<int?> _selections = [];
  List<String> _textInputs = [];
  bool _answered = false;
  final Map<int, List<int?>> _savedSelections = {};
  final Map<int, List<String>> _savedTextInputs = {};
  final Set<int> _submittedParagraphs = {};
  final List<TapGestureRecognizer> _recognizers = [];
  OverlayEntry? _overlayEntry;

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showWordDefinition(String word, String definition, Offset globalPosition) {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    const popupWidth = 280.0;
    const popupHeight = 120.0;

    double dx = globalPosition.dx - popupWidth / 2;
    double dy = globalPosition.dy + 20;
    if (dx < 12) dx = 12;
    if (dx + popupWidth > screenSize.width - 12) {
      dx = screenSize.width - popupWidth - 12;
    }
    if (dy + popupHeight > screenSize.height - 12) {
      dy = globalPosition.dy - popupHeight - 10;
    }
    if (dy < 12) dy = 12;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Container(color: Colors.transparent),
            Positioned(
              left: dx,
              top: dy,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.darkSurface,
                child: GestureDetector(
                  onTap: _removeOverlay,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: popupWidth),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          word,
                          style: AppTheme.bodyLargeStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          definition,
                          style: AppTheme.bodyLargeStyle.copyWith(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  List<InlineSpan> _buildArticleSpans(String text, ReadingNoti noti) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final spans = <InlineSpan>[];
    final wordRegex = RegExp(r"[A-Za-z]+(?:[''][A-Za-z]+)*");
    int lastEnd = 0;
    for (final match in wordRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: noti.articleText.substring(lastEnd, match.start)));
      }
      final word = match.group(0)!;
      final recognizer = TapGestureRecognizer()
        ..onTapUp = (details) {
          final def = noti.lookupWord(word);
          if (def != null) {
            _showWordDefinition(word, def, details.globalPosition);
          }
        };
      _recognizers.add(recognizer);
      spans.add(TextSpan(
        text: word,
        recognizer: recognizer,
        style: const TextStyle(decoration: TextDecoration.underline, decorationColor: AppTheme.greenPrimary, decorationThickness: 0.5),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return spans;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _noti = context.read<ReadingNoti>();
      _noti!.addListener(_onNotiError);
      _noti!.loadPassage(
        seriesId: widget.seriesId,
        testId: widget.testId,
        part: widget.part,
        questionGroup: widget.questionGroup,
      );
    });
  }

  void _onNotiError() {
    if (!mounted || _noti == null) return;
    if (_noti!.hasError) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
              const SizedBox(width: 10),
              Text("Loading Error", style: AppTheme.sectionHeaderStyle.copyWith(color: Colors.redAccent, fontSize: 18)),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
            child: SingleChildScrollView(
              child: SelectableText(
                _noti!.errorMessage!,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppTheme.lightText, height: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("DISMISS", style: TextStyle(color: AppTheme.greenPrimary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("GO BACK", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
      _noti!.removeListener(_onNotiError);
    }
  }

  @override
  void dispose() {
    _noti?.removeListener(_onNotiError);
    _removeOverlay();
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  void _submit() {
    _saveCurrentSelections();
    final noti = context.read<ReadingNoti>();
    for (int i = 0; i < noti.questions.length; i++) {
      _submittedParagraphs.add(i);
    }
    setState(() => _answered = true);
  }

  void _saveCurrentSelections() {
    final pg = context.read<ReadingNoti>().questions[_currentParagraph];
    if (pg.type.startsWith("input-")) {
      _savedTextInputs[_currentParagraph] = List.from(_textInputs);
    } else {
      _savedSelections[_currentParagraph] = List.from(_selections);
    }
  }

  void _loadSelectionsFor(int index) {
    final pg = context.read<ReadingNoti>().questions[index];
    if (pg.type.startsWith("input-")) {
      final saved = _savedTextInputs[index];
      _textInputs = saved != null && saved.length == pg.textAnswers.length
          ? List.from(saved)
          : List.filled(pg.textAnswers.length, "");
    } else {
      final saved = _savedSelections[index];
      _selections = saved != null && saved.length == pg.answers.length
          ? List.from(saved)
          : List.filled(pg.answers.length, null);
    }
  }

  void _goToParagraph(int index) {
    _saveCurrentSelections();
    setState(() {
      _currentParagraph = index;
      _answered = false;
      _loadSelectionsFor(index);
    });
  }

  void _next() {
    final noti = context.read<ReadingNoti>();
    if (_currentParagraph < noti.questions.length - 1) {
      _goToParagraph(_currentParagraph + 1);
    }
  }

  void _prev() {
    if (_currentParagraph > 0) {
      _goToParagraph(_currentParagraph - 1);
    }
  }

  bool get _currentIsSubmitted => _submittedParagraphs.contains(_currentParagraph);

  bool get _allParagraphsComplete {
    final noti = context.read<ReadingNoti>();
    for (int i = 0; i < noti.questions.length; i++) {
      final pg = noti.questions[i];
      if (pg.type.startsWith("input-")) {
        final inputs = i == _currentParagraph ? _textInputs : _savedTextInputs[i];
        if (inputs == null || inputs.any((s) => s.trim().isEmpty)) return false;
      } else {
        final sel = i == _currentParagraph ? _selections : _savedSelections[i];
        if (sel == null || sel.any((s) => s == null)) return false;
      }
    }
    return true;
  }

  Widget _buildBottomBar(int totalParagraphs) {
    final isLast = _currentParagraph == totalParagraphs - 1;
    final isFirst = _currentParagraph == 0;

    return Row(
      children: [
        Expanded(
          child: _NavBtn(
            label: "BACK",
            icon: Icons.arrow_back_ios,
            onTap: isFirst ? null : _prev,
          ),
        ),
        const SizedBox(width: 12),
        if (!_answered)
          Expanded(
            flex: 2,
            child: _SubmitBtn(
              active: _allParagraphsComplete && !_currentIsSubmitted,
              onTap: _allParagraphsComplete && !_currentIsSubmitted ? _submit : null,
            ),
          )
        else
          Expanded(
            flex: 2,
            child: _SubmitBtn(
              active: true,
              onTap: _dismissReview,
              label: "DISMISS",
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: _NavBtn(
            label: "NEXT",
            icon: Icons.arrow_forward_ios,
            onTap: isLast ? null : _next,
            trailing: true,
          ),
        ),
      ],
    );
  }

  void _dismissReview() {
    setState(() => _answered = false);
  }

  Widget _buildQuestionPanel(ParagraphGroup pg) {
    final noti = context.read<ReadingNoti>();
    final qIdx = _currentParagraph + 1;
    final totalQ = noti.questions.length;

    if (pg.type == "select-flowchart-given-list") {
      final usedOptionIndices = <int>{};
      for (int i = 0; i < noti.questions.length; i++) {
        if (i == _currentParagraph) continue;
        final saved = _savedSelections[i];
        if (saved != null) {
          for (final sel in saved) {
            if (sel != null) usedOptionIndices.add(sel);
          }
        }
      }

      return SelectSummaryGivenList(
        questionText: pg.displayText,
        options: pg.options,
        selected: _selections,
        answered: _answered,
        questionIndex: qIdx,
        totalQuestions: totalQ,
        usedOptionIndices: usedOptionIndices,
        onSelect: (blankIdx, optIdx) => setState(() => _selections[blankIdx] = optIdx),
      );
    }

    if (pg.type == "select-given-diagram" && pg.imageAssetPath != null) {
      final usedOptionIndices = <int>{};
      for (int i = 0; i < noti.questions.length; i++) {
        if (i == _currentParagraph) continue;
        final saved = _savedSelections[i];
        if (saved != null) {
          for (final sel in saved) {
            if (sel != null) usedOptionIndices.add(sel);
          }
        }
      }

      return SelectGivenDiagram(
        questionText: pg.displayText,
        options: pg.options,
        selected: _selections,
        answered: _answered,
        questionIndex: qIdx,
        totalQuestions: totalQ,
        usedOptionIndices: usedOptionIndices,
        imageAssetPath: pg.imageAssetPath,
        diagramTitle: pg.diagramTitle,
        constraint: pg.constraint,
        onSelect: (blankIdx, optIdx) => setState(() => _selections[blankIdx] = optIdx),
      );
    }

    if (pg.type.startsWith("select-")) {
      final usedOptionIndices = <int>{};
      for (int i = 0; i < noti.questions.length; i++) {
        if (i == _currentParagraph) continue;
        final saved = _savedSelections[i];
        if (saved != null) {
          for (final sel in saved) {
            if (sel != null) usedOptionIndices.add(sel);
          }
        }
      }

      return SelectSummaryGivenList(
        questionText: pg.displayText,
        options: pg.options,
        selected: _selections,
        answered: _answered,
        questionIndex: qIdx,
        totalQuestions: totalQ,
        usedOptionIndices: usedOptionIndices,
        onSelect: (blankIdx, optIdx) => setState(() => _selections[blankIdx] = optIdx),
      );
    }

    if (pg.type == "option-abc" ||
        pg.type == "option-true-false" ||
        pg.type == "option-yes-no") {
      return OptionChoice(
        questionText: pg.displayText,
        options: pg.options,
        selected: _selections.isNotEmpty ? _selections[0] : null,
        answered: _answered,
        questionIndex: qIdx,
        totalQuestions: totalQ,
        onSelect: (optIdx) => setState(() {
          _selections = [optIdx];
        }),
      );
    }

    if (pg.type == "checkbox") {
      return CheckboxWidget(
        questionText: pg.displayText,
        options: pg.options,
        selected: _selections,
        quantity: pg.answers.length,
        answered: _answered,
        questionIndex: qIdx,
        totalQuestions: totalQ,
        onSelect: (idx, opt) => setState(() {
          if (opt < 0) {
            _selections[idx] = null;
          } else if (idx < _selections.length) {
            _selections[idx] = opt;
          }
        }),
      );
    }

    if (pg.type == "input-table") {
      return InputTable(
        headerText: pg.displayText,
        tableHeaders: pg.tableHeaders,
        tableCells: pg.tableCells,
        tableInputCounts: pg.tableInputCounts,
        inputs: _textInputs,
        constraint: pg.constraint,
        answered: _answered,
        questionIndex: qIdx,
        totalQuestions: totalQ,
        onChanged: (idx, v) => setState(() {
          if (idx < _textInputs.length) _textInputs[idx] = v;
        }),
      );
    }

    if (pg.type == "input-diagram") {
      return InputDiagram(
        questionText: pg.displayText,
        imageAssetPath: pg.imageAssetPath,
        diagramTitle: pg.diagramTitle,
        inputs: _textInputs,
        constraint: pg.constraint,
        answered: _answered,
        questionIndex: qIdx,
        totalQuestions: totalQ,
        onChanged: (idx, v) => setState(() {
          if (idx < _textInputs.length) _textInputs[idx] = v;
        }),
      );
    }

    if (pg.type.startsWith("input-")) {
      return InputAnswer(
        questionText: pg.displayText,
        inputs: _textInputs,
        constraint: pg.constraint,
        answered: _answered,
        questionIndex: qIdx,
        totalQuestions: totalQ,
        onChanged: (idx, v) => setState(() {
          if (idx < _textInputs.length) _textInputs[idx] = v;
        }),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withAlpha(80), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 20),
              SizedBox(width: 8),
              Text("Unhandled question type", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            "type: ${pg.type}\n"
            "constraint: ${pg.constraint ?? "—"}\n"
            "options: [${pg.options.join(", ")}]\n"
            "textAnswers: [${pg.textAnswers.join(", ")}]\n"
            "displayText: ${pg.displayText}",
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppTheme.lightText, height: 1.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noti = context.watch<ReadingNoti>();

    if (noti.isLoading && !noti.hasError) {
      return Scaffold(
        backgroundColor: AppTheme.darkBase,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Reading", style: AppTheme.screenTitleStyle),
          backgroundColor: AppTheme.darkBase,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (noti.hasError) {
      return Scaffold(
        backgroundColor: AppTheme.darkBase,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Reading", style: AppTheme.screenTitleStyle),
          backgroundColor: AppTheme.darkBase,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
                const SizedBox(height: 16),
                Text("Failed to load passage", style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 18, color: Colors.redAccent)),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300, maxWidth: 400),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      noti.errorMessage!,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppTheme.lightText, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (noti.articleText.isEmpty && noti.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.darkBase,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Reading", style: AppTheme.screenTitleStyle),
          backgroundColor: AppTheme.darkBase,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(
          child: Text("No content available.", style: TextStyle(color: AppTheme.darkBorder)),
        ),
      );
    }

    final pg = noti.questions[_currentParagraph];
    if (pg.type.startsWith("input-")) {
      if (_textInputs.length != pg.textAnswers.length) {
        _textInputs = List.filled(pg.textAnswers.length, "");
      }
    } else {
      if (_selections.length != pg.answers.length) {
        _selections = List.filled(pg.answers.length, null);
      }
    }
    final isSubmitted = _submittedParagraphs.contains(_currentParagraph);
    bool allCorrect = false;
    String correctAnswerStr = '';
    if (isSubmitted) {
      allCorrect = true;
      final parts = <String>[];
      if (pg.type.startsWith("input-")) {
        for (int i = 0; i < pg.textAnswers.length; i++) {
          parts.add(pg.textAnswers[i]);
          if (i >= _textInputs.length ||
              _textInputs[i].trim().toLowerCase() != pg.textAnswers[i].trim().toLowerCase()) {
            allCorrect = false;
          }
        }
      } else {
        for (int i = 0; i < pg.answers.length; i++) {
          if (i < pg.options.length) {
            parts.add(pg.options[pg.answers[i]]);
          }
          if (i >= _selections.length || _selections[i] != pg.answers[i]) {
            allCorrect = false;
          }
        }
      }
      correctAnswerStr = parts.join(', ');
    }
    final totalParagraphs = noti.questions.length;

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Reading", style: AppTheme.screenTitleStyle),
        backgroundColor: AppTheme.darkBase,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.darkBorder, width: 2),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              noti.title,
                              style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ...noti.articleFragments.map((fragment) {
                              if (fragment.type == "text") {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: RichText(
                                    text: TextSpan(
                                      style: AppTheme.bodyLargeStyle.copyWith(height: 1.6),
                                      children: _buildArticleSpans(fragment.text!, noti),
                                    ),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: PictureViewer(imageAssetPath: fragment.imageAssetPath!),
                                );
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.darkBorder, width: 2),
                      ),
                      child: _buildQuestionPanel(pg),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBottomBar(totalParagraphs),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              bottom: _answered ? 0 : -MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: ReviewScreen(
                right: allCorrect,
                answer: correctAnswerStr,
                onPressed: _dismissReview,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool trailing;

  const _NavBtn({
    required this.label,
    required this.icon,
    this.onTap,
    this.trailing = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppTheme.greenPrimary : AppTheme.darkBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: trailing ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!trailing) Icon(icon, size: 16, color: active ? AppTheme.greenPrimary : AppTheme.darkBorder),
            if (!trailing) const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.bodyLargeStyle.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: active ? AppTheme.greenPrimary : AppTheme.darkBorder,
              ),
            ),
            if (trailing) const SizedBox(width: 4),
            if (trailing) Icon(icon, size: 16, color: active ? AppTheme.greenPrimary : AppTheme.darkBorder),
          ],
        ),
      ),
    );
  }
}

class _SubmitBtn extends StatelessWidget {
  final bool active;
  final VoidCallback? onTap;
  final String label;

  const _SubmitBtn({required this.active, this.onTap, this.label = "SUBMIT"});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: active ? AppTheme.greenPrimary : AppTheme.darkCard,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.bodyLargeStyle.copyWith(
              color: active ? AppTheme.darkBase : AppTheme.lightText.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

