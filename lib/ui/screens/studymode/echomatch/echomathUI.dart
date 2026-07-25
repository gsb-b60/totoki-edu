import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/studymode/echomatch/echomatchNoti.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/widget/choiceBtnVertical.dart';
import 'package:totoki_extract/widget/checkBtnVertical.dart';
import 'package:totoki_extract/widget/reviewScreen.dart' as shared;

class EchoMatchUI extends StatefulWidget {
  const EchoMatchUI({super.key});

  @override
  State<EchoMatchUI> createState() => _EchoMatchUIState();
}

class _EchoMatchUIState extends State<EchoMatchUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EchoMatchNoti>();
    final reader = context.read<EchoMatchNoti>();
    final ipa = provider.SetIPA();

    final options = provider.getOptionList;
    final states = provider.GetListState();
    
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
                  const Spacer(),
                  // Question Area
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


                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const Spacer(),
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



