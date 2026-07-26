import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/business/flashcard/deck.dart';

class HomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    Color selectedColor;
    switch (currentIndex) {
      case 0:
      case 1:
        selectedColor = AppTheme.greenPrimary;
        break;
      case 2:
        selectedColor = AppTheme.pinkPrimary;
        break;
      case 3:
        selectedColor = AppTheme.redPrimary;
        break;
      case 4:
        selectedColor = AppTheme.bluePrimary;
        break;
      case 5:
        selectedColor = AppTheme.primaryTeal;
        break;
      default:
        selectedColor = AppTheme.greenPrimary;
    }

    const tabTitles = [
      'All Decks',
      'Learn',
      'Stats',
      'Dashboard',
      'IELTS',
      'Calendar',
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppTheme.darkBase,
        title: Text(
          tabTitles[currentIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: currentIndex == 0
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
                              if (context.mounted) {
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
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppTheme.darkSurface,
          indicatorColor: selectedColor.withValues(alpha: 0.18),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return AppTheme.captionStyle.copyWith(
              color: selected
                  ? selectedColor
                  : AppTheme.lightText.withValues(alpha: 0.55),
              fontWeight: selected ? FontWeight.bold : FontWeight.w600,
              letterSpacing: 0,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected
                  ? selectedColor
                  : AppTheme.lightText.withValues(alpha: 0.55),
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
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
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
          ],
        ),
      ),
    );
  }
}
