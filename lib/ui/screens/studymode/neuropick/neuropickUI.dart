import 'dart:io';

import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/ui/screens/studymode/neuropick/neuropickNoti.dart';
import 'package:provider/provider.dart';

class NeuroPickUI extends StatefulWidget {
  const NeuroPickUI({super.key});

  @override
  State<NeuroPickUI> createState() => _NeuroPickUIState();
}

class _NeuroPickUIState extends State<NeuroPickUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NeuroPickNoti>();
    List<String> options = provider.getOptions();
    List<bool> states = provider.getOptionState();
    final reader = context.read<NeuroPickNoti>();
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
                    "Select the correct answer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (provider.getImagePath() != "")
                    Container(
                      width: 390,
                      height: 270,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(provider.getImagePath()),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Container(
                    height: 270,
                    width: 350,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: options.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Center(
                                child: ChoiceBtn(
                                  value: options[index],
                                  isSelected: states[index],
                                  onPressed: () {
                                    reader.selectOption(index);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        CheckBtn(
                          isChecked: provider.checkable,
                          onCheck: () {
                            reader.checkAnswer(provider.selectedIndex!);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            bottom: provider.answered ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: ReviewScreen(
              right: provider.right,
              answer: provider.answer,
              onPressed: () {
                reader.nextCard();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChoiceBtn extends StatelessWidget {
  String value;
  bool isSelected;
  VoidCallback? onPressed;
  ChoiceBtn({
    super.key,
    required this.isSelected,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: SizedBox(
        width: 200,
        height: 60,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(
              color: isSelected ? AppTheme.greenMuted : AppTheme.darkCard,
              width: 4,
            ),
            backgroundColor: isSelected
                ? AppTheme.darkSurface
                : AppTheme.darkBase,
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isSelected ? AppTheme.greenMuted : Colors.white,
              fontSize: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class CheckBtn extends StatelessWidget {
  bool isChecked;
  VoidCallback? onCheck;
  CheckBtn({super.key, required this.isChecked, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isChecked ? onCheck : null,
      child: Container(
        padding: const EdgeInsets.all(3.0),
        height: 60,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            bottom: BorderSide(
              color: isChecked ? AppTheme.greenAccent : Colors.transparent,
              width: 6,
            ),
          ),
          color: isChecked ? AppTheme.greenPrimary : AppTheme.darkCard,
        ),
        child: Center(
          child: Text(
            "Check",
            style: TextStyle(
              color: AppTheme.darkBase,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class ReviewScreen extends StatelessWidget {
  ReviewScreen({
    super.key,
    required this.right,
    required this.onPressed,
    required this.answer,
  });
  final bool right;
  final String answer;

  VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: right ? 250 : 350,
        child: Container(
          color: AppTheme.darkSurface,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  SizedBox(width: 30),
                  Icon(
                    right ? Icons.check_circle_rounded : Icons.cancel,
                    color: right ? AppTheme.greenBright : AppTheme.redPrimary,
                    size: 40,
                  ),
                  SizedBox(width: 20),
                  Text(
                    right ? "Great job!" : "Incorrect",
                    style: TextStyle(
                      color: right ? AppTheme.greenBright : AppTheme.redPrimary,
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              if (!right)
                Row(
                  children: [
                    SizedBox(width: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Correct answer:",
                          style: TextStyle(
                            color: AppTheme.redPrimary,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          answer,
                          style: TextStyle(
                            color: AppTheme.redAccent,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
                        elevation: right ? 10 : 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: right
                            ? AppTheme.greenPrimary
                            : AppTheme.redBright,
                      ),
                      child: Text(
                        right ? "CONTINUE" : "GOT IT",
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
                              color: right
                                  ? AppTheme.greenAccent
                                  : AppTheme.redMuted,
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


