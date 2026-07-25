import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/ui/lesson/config/storage.dart';
import 'package:totoki_extract/ui/screens/home/home_screen.dart';

import 'package:totoki_extract/ui/screens/decklist/decklist_screen.dart';
import 'package:totoki_extract/ui/screens/decklist/cardlistscreen.dart';
import 'package:totoki_extract/ui/screens/learnmode/learnmodescreen.dart';
import 'package:totoki_extract/ui/screens/decklist/achievement/achievement.dart';
import 'package:totoki_extract/ui/screens/decklist/achievement/achievementUI.dart';
import 'package:totoki_extract/ui/screens/dashboard/dashboard.dart';
import 'package:totoki_extract/ui/screens/ielts/ielts_training.dart';

import 'package:totoki_extract/ui/screens/studymode/flashcard/newwayreview.dart';
import 'package:totoki_extract/ui/screens/blankfill/blankwordscreen.dart';
import 'package:totoki_extract/ui/screens/studymode/mindfield/mindfeild.dart';
import 'package:totoki_extract/ui/screens/studymode/wordsnap/wordsnap.dart';
import 'package:totoki_extract/ui/screens/studymode/phonemix/phonemix.dart';
import 'package:totoki_extract/ui/screens/studymode/synonymfield/synonymfield.dart';
import 'package:totoki_extract/ui/screens/studymode/echospell/echospell.dart';
import 'package:totoki_extract/ui/screens/studymode/echomatch/echomath.dart';
import 'package:totoki_extract/ui/screens/studymode/echofuse/echofuse.dart';
import 'package:totoki_extract/ui/screens/studymode/sound_and_sight/sound_and_sight.dart';
import 'package:totoki_extract/ui/screens/studymode/neuropick/neuropick.dart';
import 'package:totoki_extract/ui/screens/studymode/wordpulse/wordpulse.dart';
import 'package:totoki_extract/ui/screens/studymode/synonympick/synonympick.dart';
import 'package:totoki_extract/ui/screens/studymode/speechword/speechword.dart';

import 'package:totoki_extract/ui/lesson/dailyLesson/learnSpec/lessonScreen.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/learnSpec/learnLevel.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/learnSpec/learnMode.dart';

import 'package:totoki_extract/ui/screens/ielts/passages/passages_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/decks',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/decks',
                builder: (context, state) => const DeckListTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (context, state) => const LearnModeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const Achievement(showAppBar: false),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DueDayDashBoard(showAppBar: false),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ielts',
                builder: (context, state) => const IeltsTraining(showAppBar: false),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/decks/:deckId/cards',
        builder: (context, state) {
          final deckId = int.parse(state.pathParameters['deckId']!);
          final extra = state.extra as Map<String, dynamic>?;
          final deckName = extra?['deckName'] as String?;
          return ChangeNotifierProvider<Cardmodel>(
            create: (_) => Cardmodel(),
            child: CardListScreen(deckId: deckId, deckName: deckName),
          );
        },
      ),

      GoRoute(
        path: '/decks/:deckId/cards/study/:mode',
        builder: (context, state) {
          final deckId = int.parse(state.pathParameters['deckId']!);
          final mode = state.pathParameters['mode']!;
          final cardModel = (state.extra as Cardmodel?) ?? Cardmodel();
          final screen = _buildStudyModeScreen(mode, deckId);
          return ChangeNotifierProvider<Cardmodel>.value(
            value: cardModel,
            child: screen,
          );
        },
      ),

      GoRoute(
        path: '/learn/lesson',
        builder: (context, state) {
          final fetchMode = state.extra as LearnMode;
          return LessonScreen(fetchMode: fetchMode);
        },
      ),

      GoRoute(
        path: '/learn/level/:level',
        builder: (context, state) {
          final level = int.parse(state.pathParameters['level']!);
          return Learnlevel(level: level);
        },
      ),

      GoRoute(
        path: '/learn/mode',
        builder: (context, state) {
          final mode = state.extra as StudyMode;
          return LessLearnMode(st: mode);
        },
      ),

      GoRoute(
        path: '/stats/card',
        builder: (context, state) {
          final card = state.extra as Flashcard;
          return CardInforScreen(card: card);
        },
      ),

      GoRoute(
        path: '/ielts/reading',
        builder: (context, state) => const PassagesScreen(),
      ),

      GoRoute(
        path: '/ielts/reading/:series/:test/:part/:group',
        builder: (context, state) {
          final series = int.parse(state.pathParameters['series']!);
          final test = int.parse(state.pathParameters['test']!);
          final part = int.parse(state.pathParameters['part']!);
          final group = int.parse(state.pathParameters['group']!);
          return PassagesScreen(
            seriesId: series,
            testId: test,
            part: part,
            questionGroup: group,
          );
        },
      ),
    ],
  );

  static Widget _buildStudyModeScreen(String mode, int deckId) {
    return switch (mode) {
      'newwayreview' => Newwayreview(deckId: deckId),
      'blankword' => BlankWordScreen(deck_id: deckId),
      'mindfield' => MindFeild(deckID: deckId),
      'wordsnap' => WordSnap(deck_id: deckId),
      'phonemix' => PhoneMix(deckID: deckId),
      'synonymfield' => Synonymfield(deckID: deckId),
      'echospell' => Echospell(deck_id: deckId),
      'echomatch' => EchoMatch(deck_id: deckId),
      'echofuse' => EchoFuse(deck_id: deckId),
      'soundandsight' => SoundNSight(deck_id: deckId),
      'neuropick' => NeuroPick(deckID: deckId),
      'wordpulse' => WordPulse(deck_id: deckId),
      'synonympick' => Synonympick(deckID: deckId),
      'speechword' => Speechword(deck_id: deckId),
      _ => const Scaffold(body: Center(child: Text('Unknown mode'))),
    };
  }
}
