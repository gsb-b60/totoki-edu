import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/studymode/echospell/echospellNoti.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/widget/reviewScreen.dart' as shared;

enum ButtonState { normal, selected, done, wrong }

class EchospellUI extends StatefulWidget {
  const EchospellUI({super.key});

  @override
  State<EchospellUI> createState() => _EchospellUIState();
}

class _EchospellUIState extends State<EchospellUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EchospellNoti>();
    final reader = context.read<EchospellNoti>();
    final list = provider.SetUpList();
    final listWord = provider.SetUpListWord();
    final ipa = provider.SetIPA();
    final listState = provider.GetListState();

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
                  const Spacer(),
                  // Question Area (Audio + IPA)
                  Column(
                    children: [
                      IconButton.outlined(
                        onPressed: () => reader.playSound(),
                        icon: Icon(
                          Icons.volume_up,
                          color: AppTheme.primaryTeal,
                          size: 64,
                        ),
                        padding: const EdgeInsets.all(24),
                        style: IconButton.styleFrom(
                          side: BorderSide(color: AppTheme.primaryTeal, width: 2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        ipa,
                        style: AppTheme.heroStyle.copyWith(


                          fontSize: 32,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                            width: 40,
                            padding: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: value == "_" ? AppTheme.darkBorder : AppTheme.greenPrimary,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              value == "_" ? "" : value,
                              style: AppTheme.heroStyle.copyWith(
                                fontSize: 32,
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
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(list.length, (index) {
                        final value = list[index];
                        return ChoiceBtn(
                          value: value,
                          state: listState[index],
                          onChoose: () => reader.CheckAnswer(value, index),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            if (provider.answered)
              shared.ReviewScreen(
                right: true, // Always right in EchoSpell until word complete
                answer: provider.trueList!.join(""),
                onPressed: () => reader.SetNext(),
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
        backgroundColor = AppTheme.darkCard.withOpacity(0.5);
        borderColor = AppTheme.darkCard;
        textColor = AppTheme.lightText.withOpacity(0.2);
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
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          color: backgroundColor,
        ),
        child: Center(
          child: Text(
            value,
            style: AppTheme.sectionHeaderStyle.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }
}



