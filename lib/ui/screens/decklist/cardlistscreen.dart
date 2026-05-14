import 'package:flutter/material.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/business/flashcard/Flashcard.dart';
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

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer audio = AudioPlayer();

class CardListScreen extends StatefulWidget {
  final int? deckId;
  final String? deckName;
  const CardListScreen({
    super.key,
    required this.deckId,
    required this.deckName,
  });

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  bool menu = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.deckId != null) {
        final cardModel = Provider.of<Cardmodel>(context, listen: false);
        cardModel.fetchCards(widget.deckId!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _NavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LearnMode(deckID: widget.deckId!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardModel = Provider.of<Cardmodel>(context);

    final List<Widget> cardWidgets = cardModel.card.map((card) {
      return FlashCardItem(card: card, media: cardModel.media);
    }).toList();
    return Scaffold(
      backgroundColor: AppTheme.darkSurface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.lightText),
        ),
        title: Text(
          widget.deckName ?? "My Deck",
          style: TextStyle(color: AppTheme.lightText, fontSize: 27),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                menu = !menu;
              });
            },
            icon: Icon(Icons.menu, color: AppTheme.greenPrimary),
          ),
        ],
        backgroundColor: AppTheme.darkSurface,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cardWidgets.length,
                  itemBuilder: (context, index) {
                    return cardWidgets[index];
                  },
                ),
              ),
              //_NavBar(context),
            ],
          ),
          if (menu)
            GestureDetector(
              onTap: () => setState(() => menu = false),
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          if (menu)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.darkSurface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 15,
                      offset: Offset(-5, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Study Modes",
                              style: AppTheme.bodyLargeStyle,
                            ),
                            IconButton(
                              onPressed: () => setState(() => menu = false),
                              icon: const Icon(Icons.close, color: AppTheme.lightText),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: AppTheme.darkCard, height: 1),
                      Expanded(
                        child: LearnMode(deckID: widget.deckId!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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

class FlashCardItem extends StatelessWidget {
  final Flashcard card;
  final String? media;
  const FlashCardItem({super.key, required this.card, required this.media});

  @override
  Widget build(BuildContext context) {
    final String? dir = (media != null && media!.isNotEmpty)
        ? PathService.getDeckMediaPath(media!)
        : null;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.darkerCard,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: IPAandWord(card: card)),
                SoundTitle(
                  title: "sound",
                  value: (dir != null && card.sound != null)
                      ? '$dir/${card.sound}'
                      : '',
                  icon: const Icon(Icons.volume_up),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CardInformation(card: card, dir: dir),
                ),
                const SizedBox(width: 20),
                PictureHolder(
                  w: 140,
                  h: 120,
                  path: (dir != null && card.img != null)
                      ? '$dir/${card.img}'
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            PictureHolder(
              w: double.infinity,
              h: 160,
              path: (dir != null && card.synonyms != null)
                  ? '$dir/${card.synonyms}'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class IPAandWord extends StatelessWidget {
  const IPAandWord({super.key, required this.card});

  final Flashcard card;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.word ?? '',
            style: const TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (card.ipa != null)
            Text(
              "/${card.ipa!}/",
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                overflow: TextOverflow.ellipsis,
                color: AppTheme.lightText,
                fontFamily: "roboto",
              ),
            ),
        ],
      ),
    );
  }
}

class CardInformation extends StatelessWidget {
  const CardInformation({super.key, required this.card, required this.dir});

  final Flashcard card;
  final String? dir;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              TitleAndValue(title: "Meaning", value: card.meaning ?? ''),
              TitleAndValue(title: "Example", value: card.example ?? ''),
              if (card.due != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 4),
                  child: Text(
                    'Due: ${DateFormat('MM/dd').format(card.due!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.pinkPrimary,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChipTitle(
                    title: "Interval",
                    value: card.interval.toString(),
                    color: AppTheme.greenDeep,
                  ),
                  ChipTitle(
                    title: "Reps",
                    value: card.reps.toString(),
                    color: AppTheme.greenDeep,
                  ),
                  Complexity(card: card),
                ],
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SoundTitle(
              title: "u sound",
              value: (dir != null && card.usageSound != null)
                  ? '$dir/${card.usageSound}'
                  : '',
              icon: const Icon(Icons.volume_up),
            ),
            SoundTitle(
              title: "def sound",
              value: (dir != null && card.defSound != null)
                  ? '$dir/${card.defSound}'
                  : '',
              icon: const Icon(Icons.volume_up),
            ),
          ],
        ),
      ],
    );
  }
}

class PictureHolder extends StatelessWidget {
  final String? path;
  final double w;
  final double h;
  const PictureHolder({
    super.key,
    required this.path,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    if (path != null) {
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(path!), fit: BoxFit.fitWidth),
        ),
      );
    } else {
      return Text("synonyms");
    }
  }
}

class SoundTitle extends StatelessWidget {
  final String title;
  final String value;
  final Icon icon;
  const SoundTitle({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (value != '' || value.isNotEmpty) {
      return Column(
        children: [
          IconButton(
            icon: icon,
            onPressed: () async {
              await audio.play(DeviceFileSource(value));
            },
            color: AppTheme.lightText,
          ),
          Text(title, style: TextStyle(color: AppTheme.lightText)),
        ],
      );
    } else {
      return SizedBox();
    }
  }
}

class ChipTitle extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const ChipTitle({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        '$title: $value',
        style: TextStyle(
          color: AppTheme.lightText,
          fontWeight: FontWeight.bold,
        ),
      ),
      side: BorderSide(color: AppTheme.darkBorder),
      backgroundColor: color,
    );
  }
}

class TitleAndValue extends StatelessWidget {
  final String title;
  final String value;

  const TitleAndValue({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value != '') {
      return SizedBox(
        width: double.infinity,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$title: ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(fontSize: 15, color: AppTheme.lightText),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }
}

class Complexity extends StatelessWidget {
  const Complexity({super.key, required this.card});

  final Flashcard card;
  Color _getChipColor(int complexity) {
    if (complexity == 1) {
      return const Color.fromARGB(255, 0, 168, 6);
    } else if (complexity == 2) {
      return const Color.fromARGB(255, 0, 97, 73);
    } else if (complexity == 3) {
      return const Color.fromARGB(255, 0, 59, 94);
    } else if (complexity == 4) {
      return const Color.fromARGB(255, 141, 3, 106);
    } else if (complexity == 5) {
      return const Color.fromARGB(255, 138, 3, 16);
    } else {
      return Colors.grey[100]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getChipColor(card.complexity ?? 0);
    return Chip(
      label: Text(
        'level: ${card.complexity}',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}



