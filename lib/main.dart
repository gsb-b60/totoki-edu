import 'package:flutter/material.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/business/flashcard/Deck.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/ui/screens/decklist/deckwelcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PathService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Deckmodel()..fetchDecks()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTheme.darkBase,
        primaryColor: AppTheme.primaryTeal,
        cardColor: AppTheme.darkSurface,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.darkBase,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppTheme.lightText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryTeal,
          brightness: Brightness.dark,
          surface: AppTheme.darkSurface,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppTheme.lightText),
          bodyMedium: TextStyle(color: AppTheme.lightText),
          titleLarge: TextStyle(color: AppTheme.lightText, fontWeight: FontWeight.bold),
        ),
      ),
      home: const DeckListScreen(),
    );
  }
}
