import 'package:flutter/material.dart';
import 'package:totoki_extract/business/flashcard/Flashcard.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/business/flashcard/Deck.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/ui/screens/decklist/deckwelcome.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PathService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Deckmodel()..fetchDecks()),
        ChangeNotifierProvider(create: (_) => Cardmodel()),
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
        appBarTheme: AppBarTheme(
          backgroundColor: AppTheme.darkBase,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTheme.screenTitleStyle.copyWith(fontSize: 20),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryTeal,
          brightness: Brightness.dark,
          surface: AppTheme.darkSurface,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: AppTheme.lightText,
          displayColor: AppTheme.lightText,
        ),
      ),
      home: const DeckListScreen(),
    );
  }
}
