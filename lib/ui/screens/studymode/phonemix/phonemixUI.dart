import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/ui/screens/studymode/phonemix/phonemixNoti.dart';
import 'package:provider/provider.dart';

class PhoneMixUI extends StatefulWidget {
  const PhoneMixUI({super.key});

  @override
  State<PhoneMixUI> createState() => _PhoneMixUIState();
}

class _PhoneMixUIState extends State<PhoneMixUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<phoneMixNoti>();
    final reader = context.read<phoneMixNoti>();
    provider.setOptionList();
    final word = provider.getWord();
    final ipa = provider.getIPA();

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppTheme.darkBorder,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: LinearProgressIndicator(
          value: provider.value,
          backgroundColor: AppTheme.darkCard,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greenPrimary),
          minHeight: 18,
          borderRadius: BorderRadius.circular(9),
        ),
        backgroundColor: AppTheme.darkBase,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 40),
                  Text(
                    "Tap the matching pairs",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                height: 125,
                width: 750,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListView.builder(
                      itemCount: word.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Center(
                          child: ChoiceBtn(
                            value: word[index],
                            state: provider.wordState[index],
                            onChoose: () {
                              reader.selectWord(index);
                            },
                          ),
                        );
                      },
                    ),
                    
                  ],
                ),
              ),
              SizedBox(width: 50),
              Container(
                height: 125,
                width: 750,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListView.builder(
                      itemCount: ipa.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Center(
                          child: ChoiceBtn(
                            value: ipa[index],
                            state: provider.ipaState[index],
                            onChoose: () {
                              reader.selectIPA(index);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 50),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            bottom: provider.answer ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: ReviewScreen(
              onPressed: () {
                reader.NextTask();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewScreen extends StatelessWidget {
  ReviewScreen({super.key, required this.onPressed});
  VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: 250,
        child: Container(
          color: AppTheme.darkSurface,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  SizedBox(width: 30),
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.greenBright,
                    size: 40,
                  ),
                  SizedBox(width: 20),
                  Text(
                    "Great job!",
                    style: TextStyle(
                      color: AppTheme.greenBright,
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  SizedBox(
                    width: 650,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () {
                        onPressed.call();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppTheme.greenPrimary,
                      ),
                      child: Text(
                        "CONTINUE",
                        style: TextStyle(
                          color: AppTheme.darkBase,
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            bottom: BorderSide(
                              color: AppTheme.greenAccent,

                              width: 6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

enum ButtonState { normal, selected, done, wrong }

class ChoiceBtn extends StatelessWidget {
  String value;
  ButtonState state;
  VoidCallback? onChoose;
  ChoiceBtn({
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
        borderColor = AppTheme.BlueMuted;
        textColor = AppTheme.BlueMuted;
        break;
      case ButtonState.done:
        backgroundColor = AppTheme.darkBase;
        borderColor = AppTheme.darkCard;
        textColor = AppTheme.darkerCard;
        break;
      case ButtonState.normal:
        backgroundColor = AppTheme.darkBase;
        borderColor = AppTheme.darkCard;
        textColor = Colors.white;
        break;
      case ButtonState.wrong:
        backgroundColor = AppTheme.darkSurface;
        borderColor = AppTheme.redMuted;
        textColor = AppTheme.redMuted;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 165,
        height: 70,
        child: ElevatedButton(
          onPressed: () {
            if (state != ButtonState.done) {
              onChoose?.call();
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: borderColor, width: 4),
            backgroundColor: backgroundColor,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: textColor,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}


