import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/features/user/user_notifier.dart';

class HomeShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final UserNotifier? userNotifier;

  const HomeShell({
    super.key,
    required this.navigationShell,
    this.userNotifier,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late UserNotifier _userNotifier;

  @override
  void initState() {
    super.initState();
    _userNotifier = widget.userNotifier ?? UserNotifier();
    _userNotifier.initialize();
  }

  Widget _buildAvatar(String? avatarUrl) {
    final hasImage =
        avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        File(avatarUrl).existsSync();
    return CircleAvatar(
      radius: 45,
      backgroundColor: AppTheme.darkSurface,
      backgroundImage: hasImage ? FileImage(File(avatarUrl)) : null,
      child: hasImage
          ? null
          : const Icon(Icons.person, size: 45, color: AppTheme.lightText),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;

    Color selectedColor;
    switch (currentIndex) {
      case 0:
        selectedColor = AppTheme.greenPrimary;
        break;
      case 2:
        selectedColor = AppTheme.bluePrimary;
        break;
      case 1:
        selectedColor = AppTheme.pinkPrimary;
        break;
      default:
        selectedColor = AppTheme.greenPrimary;
    }

    const tabTitles = ['Learn', 'Phân tích', 'IELTS'];

    return Scaffold(
      drawer: Drawer(
        backgroundColor: AppTheme.darkBase,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppTheme.darkBase),
              child: GestureDetector(
                onTap: () => context.push('/profile'),
                child: Consumer<UserNotifier>(
                  builder: (context, userNotifier, child) {
                    final user = userNotifier.user;
                    return user != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAvatar(user.avatarUrl),
                              const SizedBox(height: 8),
                              Text(
                                user.name ?? 'Hello my beauty',
                                style: AppTheme.sectionHeaderStyle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'TOTOKI',
                            style: AppTheme.sectionHeaderStyle.copyWith(
                              color: Colors.white,
                            ),
                          );
                  },
                ),
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
              leading: Icon(Icons.dashboard, color: AppTheme.redPrimary),
              title: Text('Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.push('/dashboard');
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: AppTheme.greenPrimary),
              title: Text(
                'Lesson History',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/history');
              },
            ),
            ListTile(
              leading: Icon(Icons.mail, color: AppTheme.sciSpark),
              title: Text('Penpal', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.push('/penpal');
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
      body: widget.navigationShell,
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
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.flash_on_outlined),
              selectedIcon: Icon(Icons.flash_on_rounded),
              label: 'Learn',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Phân tích',
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
