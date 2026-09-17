import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/studymode/phonemix/phonemix_noti.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/ui/widget/review_screen.dart' as shared;

enum ButtonState { normal, selected, done, wrong }

class PhonemixUI extends StatefulWidget {
  const PhonemixUI({super.key});

  @override
  State<PhonemixUI> createState() => _PhonemixUIState();
}

class _PhonemixUIState extends State<PhonemixUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhonemixNoti>();
    final reader = context.read<PhonemixNoti>();
    provider.setOptionList();
    final words = provider.getWord();
    final ipas = provider.getIPA();

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
                    "Tap the matching pairs",
                    style: AppTheme.sectionHeaderStyle.copyWith(
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // Matching Area
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Words Column
                      Expanded(
                        child: Column(
                          children: List.generate(words.length, (index) {
                            return ChoiceBtn(
                              value: words[index],
                              state: provider.wordState[index],
                              onChoose: () => reader.selectWord(index),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // IPAs Column
                      Expanded(
                        child: Column(
                          children: List.generate(ipas.length, (index) {
                            return ChoiceBtn(
                              value: ipas[index],
                              state: provider.ipaState[index],
                              onChoose: () => reader.selectIPA(index),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            if (provider.answer)
              shared.ReviewScreen(
                right: true,
                answer: "All pairs matched!",
                onPressed: () => reader.nextTask(),
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
  final VoidCallback? onChoose;

  const ChoiceBtn({
    super.key,
    required this.state,
    required this.value,
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: state == ButtonState.done ? null : onChoose,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 64,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            color: backgroundColor,
          ),
          child: Center(
            child: Text(
              value,
              style: AppTheme.bodyLargeStyle.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,

                fontSize: 14, // Smaller text for IPAs and long words
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}



