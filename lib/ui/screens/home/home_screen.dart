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
        selectedColor = AppTheme.greenPrimary;
        break;
      case 1:
        selectedColor = AppTheme.bluePrimary;
        break;
      default:
        selectedColor = AppTheme.greenPrimary;
    }

    const tabTitles = ['Learn', 'IELTS'];

    return Scaffold(
      drawer: Drawer(
        backgroundColor: AppTheme.darkBase,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppTheme.darkSurface),
              child: Text(
                'TOTOKI',
                style: AppTheme.sectionHeaderStyle.copyWith(color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.layers, color: AppTheme.greenPrimary),
              title: Text('All Decks', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.push('/decks');
              },
            ),
            ListTile(
              leading: Icon(Icons.stars, color: AppTheme.pinkPrimary),
              title: Text('Stats', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.push('/stats');
              },
            ),
            ListTile(
              leading: Icon(Icons.space_dashboard, color: AppTheme.redPrimary),
              title: Text('Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.push('/dashboard');
              },
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
        ),
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
        actions: null,
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppTheme.darkBase,
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
              icon: Icon(Icons.flash_on_outlined),
              selectedIcon: Icon(Icons.flash_on_rounded),
              label: 'Learn',
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