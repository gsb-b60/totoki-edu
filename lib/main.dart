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
        scaffoldBackgroundColor: AppTheme.darkBase,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryTeal,
          brightness: Brightness.dark,
        ),
      ),
      home: const DeckListScreen(),
    );
  }
}
