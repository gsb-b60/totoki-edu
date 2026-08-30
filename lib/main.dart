import 'package:flutter/material.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totoki_extract/business/flashcard/deck.dart';
import 'package:totoki_extract/features/user/user_notifier.dart';
import 'package:totoki_extract/features/user/analyze_notifier.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/services/sound_controller.dart';
import 'package:totoki_extract/features/ielts/notifier/reading_notifier.dart';
import 'package:totoki_extract/router/app_router.dart';
import 'package:totoki_extract/ui/screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PathService.init();
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Deckmodel()..fetchDecks()),
        ChangeNotifierProvider(create: (_) => Cardmodel()),
        ChangeNotifierProvider(create: (_) => SoundController()),
        ChangeNotifierProvider(create: (_) => ReadingNoti()),
        ChangeNotifierProvider(create: (_) => UserNotifier()..initialize()),
        ChangeNotifierProvider(create: (_) => AnalyzeNotifier()),
      ],
      child: PathService.initError != null
          ? ErrorApp(PathService.initError!)
          : MyApp(onboardingCompleted: onboardingCompleted),
    ),
  );
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Startup Error\n$message',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final bool onboardingCompleted;
  const MyApp({super.key, required this.onboardingCompleted});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _onboardingCompleted = widget.onboardingCompleted;
  }

  void _onOnboardingComplete() {
    setState(() => _onboardingCompleted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboardingCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppTheme.darkBase,
          primaryColor: AppTheme.primaryTeal,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primaryTeal,
            brightness: Brightness.dark,
            surface: AppTheme.darkSurface,
          ),
        ),
        home: OnboardingScreen(onComplete: _onOnboardingComplete),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
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
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: AppTheme.lightText,
          displayColor: AppTheme.lightText,
        ),
      ),
    );
  }
}
