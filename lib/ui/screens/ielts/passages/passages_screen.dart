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
    noti.checkCurrentAnswer(); // called for side effects if any
    final totalParagraphs = noti.questions.length;

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
                        answered: noti.answered,
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
                    answered: noti.answered,
                    allParagraphsComplete: noti.allParagraphsComplete,
                    currentIsSubmitted: isSubmitted,
                    onBack: noti.prev,
                    onNext: noti.next,
                    onSubmit: noti.submit,
                    onDismiss: noti.dismissReview,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Full-screen review overlay
      bottomSheet: noti.answered
          ? IeltsPassageReview(
              items: noti.getReviewItems(),
              onDismiss: noti.dismissReview,
              onRetry: noti.retryCurrentParagraph,
            )
          : null,
    );
  }
}
