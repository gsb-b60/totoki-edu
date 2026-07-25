import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/studymode/synonymfield/synonymfieldNoti.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/widget/choiceBtnVertical.dart';
import 'package:totoki_extract/widget/checkBtnVertical.dart';
import 'package:totoki_extract/widget/reviewScreen.dart' as shared;

class Synonymfield extends StatefulWidget {
  final int deckID;
  Synonymfield({super.key, required this.deckID});
  @override
  State<Synonymfield> createState() => _SynonymfieldState();
}

class _SynonymfieldState extends State<Synonymfield> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SynonymfieldNoti()..getFlashcardList(widget.deckID),
      child: Consumer<SynonymfieldNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SynonymfieldUI();
        },
      ),
    );
  }
}

class SynonymfieldUI extends StatefulWidget {
  const SynonymfieldUI({super.key});

  @override
  State<SynonymfieldUI> createState() => _SynonymfieldUIState();
}

class _SynonymfieldUIState extends State<SynonymfieldUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SynonymfieldNoti>();
    final reader = context.read<SynonymfieldNoti>();
    final options = provider.getOptionList;
    final states = provider.GetListState();
    final imagePath = provider.getImagePath();

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
                    "Select the correct answer",
                    style: AppTheme.sectionHeaderStyle.copyWith(
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Image Area
                  if (imagePath.isNotEmpty)
                    Expanded(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(imagePath),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  else
                    const Spacer(),
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
                onPressed: () => reader.SetNext(),
              ),
          ],
        ),
      ),
    );
  }
}



