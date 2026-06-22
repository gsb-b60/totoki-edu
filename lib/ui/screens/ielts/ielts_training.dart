import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';
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
                onPressed: () => Navigator.pop(context),
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
      body: _screens[index],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => setState(() => index = i),
          iconSize: 24,
          unselectedItemColor: AppTheme.lightText.withOpacity(0.5),
          backgroundColor: AppTheme.darkSurface,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          selectedItemColor: AppTheme.greenPrimary,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Reading',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.headphones),
              label: 'Listening',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Writing',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic),
              label: 'Speaking',
            ),
          ],
        ),
      ),
    );
  }
}
