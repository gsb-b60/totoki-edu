import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/features/ielts/notifier/reading_notifier.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/article_viewer.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/question_panel.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/answer_bottom_bar.dart';
import 'package:totoki_extract/widget/reviewScreen.dart';

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

  void _dismissReview() {
    setState(() => _answered = false);
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
                      child: ArticleViewer(noti: noti),
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
                      child: QuestionPanel(
                        pg: pg,
                        selections: _selections,
                        textInputs: _textInputs,
                        answered: _answered,
                        currentParagraph: _currentParagraph,
                        savedSelections: _savedSelections,
                        totalQuestions: totalParagraphs,
                        onSelectBlank: (blankIdx, optIdx) => setState(() => _selections[blankIdx] = optIdx),
                        onCheckboxSelect: (idx, opt) => setState(() {
                          if (opt < 0) {
                            _selections[idx] = null;
                          } else if (idx < _selections.length) {
                            _selections[idx] = opt;
                          }
                        }),
                        onInputChanged: (idx, v) => setState(() {
                          if (idx < _textInputs.length) _textInputs[idx] = v;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnswerBottomBar(
                    currentParagraph: _currentParagraph,
                    totalParagraphs: totalParagraphs,
                    answered: _answered,
                    allParagraphsComplete: _allParagraphsComplete,
                    currentIsSubmitted: _currentIsSubmitted,
                    onBack: _prev,
                    onNext: _next,
                    onSubmit: _submit,
                    onDismiss: _dismissReview,
                  ),
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
