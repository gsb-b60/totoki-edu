import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/ui/widget/choiceBtnVertical.dart';
import 'package:totoki_extract/ui/widget/checkBtnVertical.dart';
import 'package:totoki_extract/ui/widget/reviewScreen.dart' as shared;
import 'mindfieldnoti.dart';

class MindFeildUI extends StatefulWidget {
  const MindFeildUI({super.key});

  @override
  State<MindFeildUI> createState() => _MindFeildUIState();
}

class _MindFeildUIState extends State<MindFeildUI> {
  int? selectedIndex;
  bool answered = false;
  bool right = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Mindfieldnoti>();
    final card = provider.currentCard;
    final options = provider.getOptionList;
    final progress = provider.getProgress();

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.lightText, size: 24),
          onPressed: () => context.pop(),
        ),
        title: LinearProgressIndicator(
          value: progress,
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
                    "Select the correct answer",
                    style: AppTheme.sectionHeaderStyle.copyWith(
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Meaning Question Area
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          card.meaning ?? "No meaning available",
                          style: AppTheme.sectionHeaderStyle.copyWith(
                            color: AppTheme.lightText.withValues(alpha: 0.9),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Options Area
                  Column(
                    children: List.generate(options.length, (index) {
                      return ChoiceBtnVertical(
                        value: options[index],
                        isSelected: selectedIndex == index,
                        onPressed: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  CheckBtnVertical(
                    isChecked: selectedIndex != null,
                    onCheck: () {
                      setState(() {
                        right = context.read<Mindfieldnoti>().checkAnswer(
                          selectedIndex!,
                        );
                        answered = true;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (answered)
              shared.ReviewScreen(
                right: right,
                answer:
                    "${card.word}${card.ipa != null ? ' - /${card.ipa}/' : ''}",
                onPressed: () {
                  context.read<Mindfieldnoti>().nextCard();
                  setState(() {
                    answered = false;
                    selectedIndex = null;
                    right = false;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
