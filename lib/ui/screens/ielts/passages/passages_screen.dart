import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/features/ielts/notifier/reading_notifier.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/article_viewer.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/question_panel.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/answer_bottom_bar.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/widgets/passage_states.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/widgets/ielts_passage_review.dart';

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
  late int _seriesId;
  late int _testId;
  late int _part;
  late int _group;

  @override
  void initState() {
    super.initState();
    _seriesId = widget.seriesId;
    _testId = widget.testId;
    _part = widget.part;
    _group = widget.questionGroup;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _noti = context.read<ReadingNoti>();
      _noti!.addListener(_onNotiError);
      _noti!.loadPassage(
        seriesId: _seriesId,
        testId: _testId,
        part: _part,
        questionGroup: _group,
      );
    });
  }

  void _onNotiError() {
    if (!mounted || _noti == null) return;
    if (_noti!.hasError) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ErrorDialog(
          errorMessage: _noti!.errorMessage!,
          onDismiss: () => Navigator.pop(context),
          onGoBack: () {
            Navigator.pop(context);
            context.pop();
          },
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

  (int, int, int, int)? _getNextPassage() {
    // Group 1 -> Group 2
    if (_group < 2) return (_seriesId, _testId, _part, _group + 1);
    // End of groups -> next Part
    if (_part < 3) return (_seriesId, _testId, _part + 1, 1);
    // End of parts -> next Test
    if (_testId < 4) return (_seriesId, _testId + 1, 1, 1);
    // End of tests -> next Series
    if (_seriesId < 4) return (_seriesId + 1, 1, 1, 1);
    // End of all -> loop to Series 1
    return (1, 1, 1, 1);
  }

  void _handleContinue() {
    final noti = _noti!;
    final next = _getNextPassage();
    if (next != null) {
      noti.continueToNext();
      context.push('/ielts/reading/${next.$1}/${next.$2}/${next.$3}/${next.$4}');
    } else {
      noti.continueToNext();
      context.push('/ielts/reading/1/1/1/1');
    }
  }

  void _handleRetry() {
    _noti!.retryCurrentParagraph();
  }

  @override
  Widget build(BuildContext context) {
    final noti = context.watch<ReadingNoti>();

    if (noti.isLoading && !noti.hasError) {
      return LoadingState(onBack: () => context.pop());
    }

    if (noti.hasError) {
      return ErrorState(
        errorMessage: noti.errorMessage!,
        onBack: () => context.pop(),
        onDismiss: () => context.pop(),
      );
    }

    if (noti.articleText.isEmpty && noti.questions.isEmpty) {
      return EmptyState(onBack: () => context.pop());
    }

    final pg = noti.questions[noti.currentParagraph];
    final isSubmitted = noti.currentIsSubmitted;
    noti.checkCurrentAnswer();
    final totalParagraphs = noti.questions.length;
    final isReview = noti.state == PassageState.review;

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.lightText,
            size: 24,
          ),
          onPressed: () => context.pop(),
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
                        border: Border.all(
                          color: AppTheme.darkBorder,
                          width: 2,
                        ),
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
                        border: Border.all(
                          color: AppTheme.darkBorder,
                          width: 2,
                        ),
                      ),
                      child: QuestionPanel(
                        pg: pg,
                        selections: noti.selections,
                        textInputs: noti.textInputs,
                        answered: isReview,
                        currentParagraph: noti.currentParagraph,
                        savedSelections: noti.savedSelections,
                        totalQuestions: totalParagraphs,
                        onSelectBlank: (blankIdx, optIdx) =>
                            noti.updateSelection(blankIdx, optIdx),
                        onCheckboxSelect: (idx, opt) =>
                            noti.updateSelection(idx, opt < 0 ? null : opt),
                        onInputChanged: (idx, v) =>
                            noti.updateTextInput(idx, v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnswerBottomBar(
                    currentParagraph: noti.currentParagraph,
                    totalParagraphs: totalParagraphs,
                    answered: isReview,
                    allParagraphsComplete: noti.allParagraphsComplete,
                    currentIsSubmitted: isSubmitted,
                    onBack: noti.prev,
                    onNext: noti.next,
                    onSubmit: noti.submit,
                    onDismiss: isReview ? _handleRetry : noti.dismissReview,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: isReview
          ? IeltsPassageReview(
              items: noti.getReviewItems(),
              onContinue: _handleContinue,
              onRetry: _handleRetry,
            )
          : null,
    );
  }
}
