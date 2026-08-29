import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/ui/widget/nav_page_button.dart';

class LearnMode extends StatelessWidget {
  const LearnMode({super.key, required this.deckID});

  final int deckID;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        NavPageBtn(
          label: "SRS Review",
          icon: Icons.rate_review,
          color: AppTheme.primaryTeal,
          routePath: '/decks/$deckID/cards/study/newwayreview',
        ),
        NavPageBtn(
          label: "Blank Word",
          icon: Icons.text_fields,
          color: AppTheme.meanFuse,
          routePath: '/decks/$deckID/cards/study/blankword',
        ),
        NavPageBtn(
          label: "Mind Field",
          icon: Icons.psychology,
          color: AppTheme.mindField,
          routePath: '/decks/$deckID/cards/study/mindfield',
        ),
        NavPageBtn(
          label: "Word Snap",
          icon: Icons.touch_app,
          color: AppTheme.wordSnap,
          routePath: '/decks/$deckID/cards/study/wordsnap',
        ),
        NavPageBtn(
          label: "Phoneme Mix",
          icon: Icons.graphic_eq,
          color: AppTheme.phoneMix,
          routePath: '/decks/$deckID/cards/study/phonemix',
        ),
        NavPageBtn(
          label: "Synonym Field",
          icon: Icons.compare_arrows,
          color: AppTheme.meanFuse,
          routePath: '/decks/$deckID/cards/study/synonymfield',
        ),
        NavPageBtn(
          label: "Echo Spell",
          icon: Icons.hearing,
          color: AppTheme.echoSpell,
          routePath: '/decks/$deckID/cards/study/echospell',
        ),
        NavPageBtn(
          label: "Echo Match",
          icon: Icons.extension,
          color: AppTheme.echoMatch,
          routePath: '/decks/$deckID/cards/study/echomatch',
        ),
        NavPageBtn(
          label: "Echo Fuse",
          icon: Icons.merge_type,
          color: AppTheme.echoFuse,
          routePath: '/decks/$deckID/cards/study/echofuse',
        ),
        NavPageBtn(
          label: "Sound - Sight",
          icon: Icons.visibility,
          color: AppTheme.soundSight,
          routePath: '/decks/$deckID/cards/study/soundandsight',
        ),
        NavPageBtn(
          label: "Neuro Pick",
          icon: Icons.image_search,
          color: AppTheme.neuroPick,
          routePath: '/decks/$deckID/cards/study/neuropick',
        ),
        NavPageBtn(
          label: "Word Pulse",
          icon: Icons.favorite,
          color: AppTheme.wordPulse,
          routePath: '/decks/$deckID/cards/study/wordpulse',
        ),
        NavPageBtn(
          label: "Synonym Pick",
          icon: Icons.low_priority,
          color: AppTheme.meanFuse,
          routePath: '/decks/$deckID/cards/study/synonympick',
        ),
        NavPageBtn(
          label: "Speech Word",
          icon: Icons.mic,
          color: AppTheme.primaryRed,
          routePath: '/decks/$deckID/cards/study/speechword',
        ),
      ],
    );
  }
}

