import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/business/flashcard/Deck.dart';
import 'package:totoki_extract/ui/screens/dashboard/dashBoard.dart';
import 'package:totoki_extract/ui/screens/decklist/achievement/achievement.dart';
import 'package:totoki_extract/ui/screens/learnmode/learnmodescreen.dart';
import 'package:totoki_extract/ui/screens/decklist/decklist_screen.dart';
import 'package:totoki_extract/ui/screens/ielts/ielts_training.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Color get _selectedColor {
    switch (_selectedIndex) {
      case 0:
      case 1:
        return AppTheme.greenPrimary;
      case 2:
        return AppTheme.pinkPrimary;
      case 3:
        return AppTheme.redPrimary;
      case 4:
        return AppTheme.bluePrimary;
      default:
        return AppTheme.greenPrimary;
    }
  }

  static const List<String> _tabTitles = [
    'All Decks',
    'Learn',
    'Stats',
    'Dashboard',
    'IELTS',
  ];

  @override
  void initState() {
    super.initState();
    final deckModel = Provider.of<Deckmodel>(context, listen: false);
    deckModel.hadDB().then((hadDB) {
      if (!hadDB) {
        deckModel.filePicker().then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Import process finished.'),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppTheme.darkBase,
              title: Text(
                _tabTitles[_selectedIndex],
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: _selectedIndex == 0
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Consumer<Deckmodel>(
                    builder: (context, deckModel, child) => IconButton(
                      tooltip: 'Import deck',
                      onPressed: deckModel.isLoading
                          ? null
                          : () async {
                              await deckModel.filePicker();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Import process finished.'),
                                  ),
                                );
                              }
                            },
                      icon: Icon(
                        Icons.upload_file,
                        color: deckModel.isLoading
                            ? Colors.white38
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const DeckListTab(),
          const LearnModeScreen(),
          const Achievement(showAppBar: false),
          const DueDayDashBoard(showAppBar: false),
          const IeltsTraining(showAppBar: false),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppTheme.darkSurface,
          indicatorColor: _selectedColor.withOpacity(0.18),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return AppTheme.captionStyle.copyWith(
              color: selected
                  ? _selectedColor
                  : AppTheme.lightText.withOpacity(0.55),
              fontWeight: selected ? FontWeight.bold : FontWeight.w600,
              letterSpacing: 0,
            );
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return IconThemeData(
              color: selected
                  ? _selectedColor
                  : AppTheme.lightText.withOpacity(0.55),
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.layers_outlined),
              selectedIcon: Icon(Icons.layers_rounded),
              label: 'Decks',
            ),
            NavigationDestination(
              icon: Icon(Icons.flash_on_outlined),
              selectedIcon: Icon(Icons.flash_on_rounded),
              label: 'Learn',
            ),
            NavigationDestination(
              icon: Icon(Icons.stars_outlined),
              selectedIcon: Icon(Icons.stars_rounded),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              selectedIcon: Icon(Icons.space_dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.language_outlined),
              selectedIcon: Icon(Icons.language_rounded),
              label: 'IELTS',
            ),
          ],
        ),
      ),
    );
  }
}
