import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/business/flashcard/Flashcard.dart';

// Study Mode Screen Imports
import 'package:totoki_extract/ui/screens/blankfill/blankwordscreen.dart';
import 'package:totoki_extract/ui/screens/studymode/echofuse/echofuse.dart';
import 'package:totoki_extract/ui/screens/studymode/echomatch/echomath.dart';
import 'package:totoki_extract/ui/screens/studymode/echospell/echospell.dart';
import 'package:totoki_extract/ui/screens/studymode/flashcard/newwayreview.dart';
import 'package:totoki_extract/ui/screens/studymode/mindfield/mindfeild.dart';
import 'package:totoki_extract/ui/screens/studymode/neuropick/neuropick.dart';
import 'package:totoki_extract/ui/screens/studymode/phonemix/phonemix.dart';
import 'package:totoki_extract/ui/screens/studymode/sound&sight/sound&sight.dart';
import 'package:totoki_extract/ui/screens/studymode/speechword/speechword.dart';
import 'package:totoki_extract/ui/screens/studymode/synonymfield/synonymfield.dart';
import 'package:totoki_extract/ui/screens/studymode/synonympick/synonympick.dart';
import 'package:totoki_extract/ui/screens/studymode/wordpulse/wordpulse.dart';
import 'package:totoki_extract/ui/screens/studymode/wordsnap/wordsnap.dart';

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
          screenBuilder: () => Newwayreview(deckId: deckID),
        ),
        NavPageBtn(
          label: "Blank Word",
          icon: Icons.text_fields,
          color: AppTheme.meanFuse,
          screenBuilder: () => BlankWordScreen(deck_id: deckID),
        ),
        NavPageBtn(
          label: "Mind Field",
          icon: Icons.psychology,
          color: AppTheme.mindField,
          screenBuilder: () => MindFeild(deckID: deckID),
        ),
        NavPageBtn(
          label: "Word Snap",
          icon: Icons.touch_app,
          color: AppTheme.wordSnap,
          screenBuilder: () => WordSnap(deck_id: deckID),
        ),
        NavPageBtn(
          label: "Phoneme Mix",
          icon: Icons.graphic_eq,
          color: AppTheme.phoneMix,
          screenBuilder: () => PhoneMix(deckID: deckID),
        ),
        NavPageBtn(
          label: "Synonym Field",
          icon: Icons.compare_arrows,
          color: AppTheme.meanFuse,
          screenBuilder: () => Synonymfield(deckID: deckID),
        ),
        NavPageBtn(
          label: "Echo Spell",
          icon: Icons.hearing,
          color: AppTheme.echoSpell,
          screenBuilder: () => Echospell(deck_id: deckID),
        ),
        NavPageBtn(
          label: "Echo Match",
          icon: Icons.extension,
          color: AppTheme.echoMatch,
          screenBuilder: () => EchoMatch(deck_id: deckID),
        ),
        NavPageBtn(
          label: "Echo Fuse",
          icon: Icons.merge_type,
          color: AppTheme.echoFuse,
          screenBuilder: () => EchoFuse(deck_id: deckID),
        ),
        NavPageBtn(
          label: "Sound - Sight",
          icon: Icons.visibility,
          color: AppTheme.soundSight,
          screenBuilder: () => SoundNSight(deck_id: deckID),
        ),
        NavPageBtn(
          label: "Neuro Pick",
          icon: Icons.image_search,
          color: AppTheme.neuroPick,
          screenBuilder: () => NeuroPick(deckID: deckID),
        ),
        NavPageBtn(
          label: "Word Pulse",
          icon: Icons.favorite,
          color: AppTheme.wordPulse,
          screenBuilder: () => WordPulse(deck_id: deckID),
        ),
        NavPageBtn(
          label: "Synonym Pick",
          icon: Icons.low_priority,
          color: AppTheme.meanFuse,
          screenBuilder: () => Synonympick(deckID: deckID),
        ),
        NavPageBtn(
          label: "Speech Word",
          icon: Icons.mic,
          color: AppTheme.primaryRed,
          screenBuilder: () => Speechword(deck_id: deckID),
        ),
      ],
    );
  }
}

class NavPageBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Widget Function() screenBuilder;

  const NavPageBtn({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.screenBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          final cardModel = Provider.of<Cardmodel>(context, listen: false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<Cardmodel>.value(
                value: cardModel,
                child: screenBuilder(),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.bodyMediumStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.lightText.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
