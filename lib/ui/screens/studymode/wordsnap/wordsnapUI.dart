import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/studymode/wordsnap/wordsnapNoti.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/widget/choiceBtnVertical.dart';
import 'package:totoki_extract/widget/checkBtnVertical.dart';
import 'package:totoki_extract/widget/reviewScreen.dart' as shared;

class WordSnapUI extends StatefulWidget {
  const WordSnapUI({super.key});

  @override
  State<WordSnapUI> createState() => _WordSnapUIState();
}

class _WordSnapUIState extends State<WordSnapUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordSnapNoti>();
    final options = provider.genOptions();
    final states = provider.getOptionState();
    final progress = provider.value;
    final mean = provider.mean;
    final reader = context.read<WordSnapNoti>();

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
                          mean,
                          style: AppTheme.sectionHeaderStyle.copyWith(
                            color: AppTheme.lightText.withOpacity(0.9),
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
                        isSelected: states[index],
                        onPressed: () => reader.selectOption(index),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  CheckBtnVertical(
                    isChecked: provider.checkable,
                    onCheck: () => reader.checkAnswer(provider.selectedIndex!),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (provider.answered)
              shared.ReviewScreen(
                right: provider.right,
                answer: provider.answer,
                onPressed: () => reader.nextCard(),
              ),
          ],
        ),
      ),
    );
  }
}




