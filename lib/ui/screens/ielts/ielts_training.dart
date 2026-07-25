import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/ielts/tabs/reading_tab.dart';
import 'package:totoki_extract/ui/screens/ielts/tabs/listening_tab.dart';
import 'package:totoki_extract/ui/screens/ielts/tabs/writing_tab.dart';
import 'package:totoki_extract/ui/screens/ielts/tabs/speaking_tab.dart';

class IeltsTraining extends StatefulWidget {
  const IeltsTraining({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<IeltsTraining> createState() => _IeltsTrainingState();
}

class _IeltsTrainingState extends State<IeltsTraining> {
  int index = 0;
  final List<Widget> _screens = const [
    ReadingTab(),
    ListeningTab(),
    WritingTab(),
    SpeakingTab(),
  ];

  static const _titles = [
    "Reading",
    "Listening",
    "Writing",
    "Speaking",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: AppTheme.darkBase,
              elevation: 0,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.lightText,
                ),
              ),
              title: Text(
                _titles[index],
                style: AppTheme.screenTitleStyle,
              ),
            )
          : null,
      body: Column(
        children: [
          Container(
            color: AppTheme.darkBase,
            child: Row(
              children: List.generate(4, (i) {
                final selected = index == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => index = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected
                                ? AppTheme.bluePrimary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        _titles[i],
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyMediumStyle.copyWith(
                          color: selected
                              ? AppTheme.bluePrimary
                              : AppTheme.lightText.withOpacity(0.5),
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          fontSize: selected ? 15 : 13,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(child: _screens[index]),
        ],
      ),
    );
  }
}
