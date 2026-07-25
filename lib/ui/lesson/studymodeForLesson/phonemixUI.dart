import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/noti/lessonNoti.dart';
import 'package:totoki_extract/widget/progressIndicator.dart';
import 'package:totoki_extract/widget/reviewScreen.dart';
import 'package:totoki_extract/widget/skipBtn.dart';
import 'package:provider/provider.dart';

class PhoneMixUI extends StatefulWidget {
  const PhoneMixUI({super.key});

  @override
  State<PhoneMixUI> createState() => _PhoneMixUIState();
}

class _PhoneMixUIState extends State<PhoneMixUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonNoti>();
    final reader = context.read<LessonNoti>();

    provider.setOptionListPhone();
    final words = provider.getWord();
    final ipas = provider.getIPA();

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder, size: 24),
          onPressed: () => context.pop(),
        ),
        title: ProgressBar(value: provider.value, inARow: provider.inARow),
        actions: [
          SkipBtn(onPressed: () => reader.skipLesson()),
        ],
        backgroundColor: AppTheme.darkBase,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Tap the matching pairs",
                    style: AppTheme.screenTitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 1),
                  Expanded(
                    flex: 10,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Words Column
                        Expanded(
                          child: Column(
                            children: List.generate(words.length, (index) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: PhoneMatchBtn(
                                    value: words[index],
                                    state: provider.wordState[index],
                                    onPressed: () => reader.selectWord(index),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // IPA Column
                        Expanded(
                          child: Column(
                            children: List.generate(ipas.length, (index) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: PhoneMatchBtn(
                                    value: ipas[index],
                                    state: provider.ipaState[index],
                                    onPressed: () => reader.selectIPA(index),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
            // Review Overlay
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              bottom: provider.answered ? 0 : -MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: ReviewScreen(
                right: true,
                answer: "",
                onPressed: () => reader.nextCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneMatchBtn extends StatelessWidget {
  final String value;
  final ButtonState state;
  final VoidCallback onPressed;

  const PhoneMatchBtn({
    super.key,
    required this.value,
    required this.state,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppTheme.darkBase;
    Color textColor = AppTheme.lightText;
    Color borderColor = AppTheme.darkCard;

    switch (state) {
      case ButtonState.selected:
        backgroundColor = AppTheme.darkSurface;
        borderColor = AppTheme.bluePrimary;
        textColor = AppTheme.bluePrimary;
        break;
      case ButtonState.done:
        backgroundColor = AppTheme.darkSurface.withOpacity(0.5);
        borderColor = AppTheme.darkBorder.withOpacity(0.3);
        textColor = AppTheme.darkBorder.withOpacity(0.5);
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: state == ButtonState.done ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(

                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

