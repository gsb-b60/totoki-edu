import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';

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


