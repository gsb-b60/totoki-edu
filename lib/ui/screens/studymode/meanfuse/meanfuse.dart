import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/studymode/meanfuse/meanfuse_noti.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/ui/widget/review_screen.dart' as shared;

// Enum defined in echospellUI might be used here if they were shared, 
// but MeanfuseNoti imports ButtonState from echospellUI.dart.
// I will keep the imports as they are in the original file to avoid logic changes.
import 'package:totoki_extract/ui/screens/studymode/echospell/echospell_ui.dart' show ButtonState;

class Meanfuse extends StatefulWidget {
  const Meanfuse({super.key, required this.deckId});
  final int deckId;

  @override
  State<Meanfuse> createState() => _MeanfuseState();
}

class _MeanfuseState extends State<Meanfuse> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MeanfuseNoti()..getFlashcardList(widget.deckId),
      child: Consumer<MeanfuseNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const MeanfuseUI();
        },
      ),
    );
  }
}

class MeanfuseUI extends StatelessWidget {
  const MeanfuseUI({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeanfuseNoti>();
    final reader = context.read<MeanfuseNoti>();
    final list = provider.setupList();
    final listWord = provider.setupListWord();
    final listState = provider.getListState();

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.lightText,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: LinearProgressIndicator(
          value: provider.value,
          backgroundColor: AppTheme.darkCard,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greenPrimary),
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
        backgroundColor: AppTheme.darkBase,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    "Tap to build the word",
                    style: AppTheme.sectionHeaderStyle.copyWith(
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Meaning Question Area
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          provider.mean,
                          style: AppTheme.sectionHeaderStyle.copyWith(
                            color: AppTheme.lightText.withValues(alpha:0.9),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Word Building Area (Blanks)
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: List.generate(listWord.length, (index) {
                          String value = listWord[index];
                          return Container(
                            width: 32,
                            padding: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: value == "_" ? AppTheme.darkBorder : AppTheme.greenPrimary,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              value == "_" ? "" : value,
                              style: AppTheme.sectionHeaderStyle.copyWith(
                                fontSize: 24,
                                color: AppTheme.greenPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Options Area (Letter Grid)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: List.generate(list.length, (index) {
                        final value = list[index];
                        return ChoiceBtn(
                          value: value,
                          state: listState[index],
                          onChoose: () => reader.checkAnswer(value, index),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            if (provider.answered)
              shared.ReviewScreen(
                right: true,
                answer: provider.trueList!.join(""),
                onPressed: () => reader.setNext(),
              ),
          ],
        ),
      ),
    );
  }
}

class ChoiceBtn extends StatelessWidget {
  final String value;
  final ButtonState state;
  final VoidCallback onChoose;

  const ChoiceBtn({
    super.key,
    required this.value,
    required this.state,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppTheme.darkBase;
    Color textColor = Colors.white;
    Color borderColor = AppTheme.darkCard;

    switch (state) {
      case ButtonState.selected:
        backgroundColor = AppTheme.darkSurface;
        borderColor = AppTheme.bluePrimary;
        textColor = AppTheme.bluePrimary;
        break;
      case ButtonState.done:
        backgroundColor = AppTheme.darkCard.withValues(alpha:0.5);
        borderColor = AppTheme.darkCard;
        textColor = AppTheme.lightText.withValues(alpha:0.2);
        break;
      case ButtonState.normal:
        backgroundColor = AppTheme.darkSurface;
        borderColor = AppTheme.darkBorder;
        textColor = AppTheme.lightText;
        break;
      case ButtonState.wrong:
        backgroundColor = AppTheme.darkSurface;
        borderColor = AppTheme.redPrimary;
        textColor = AppTheme.redPrimary;
        break;
    }

    return GestureDetector(
      onTap: state == ButtonState.done ? null : onChoose,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          color: backgroundColor,
        ),
        child: Center(
          child: Text(
            value,
            style: AppTheme.bodyLargeStyle.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,

            ),
          ),
        ),
      ),
    );
  }
}



