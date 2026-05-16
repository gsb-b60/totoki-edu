import 'package:flutter/material.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/business/flashcard/Flashcard.dart';

import 'package:totoki_extract/ui/screens/decklist/learnModeMenu.dart';


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

  @override
  Widget build(BuildContext context) {
    final cardModel = Provider.of<Cardmodel>(context);

    String displayName = widget.deckName ?? "My Deck";
    RegExp regExp = RegExp(r':\s*(.*)');
    Match? match = regExp.firstMatch(displayName);
    if (match != null) {
      displayName = match.group(1)!;
    }

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
          displayName,
          style: AppTheme.screenTitleStyle,
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: Icon(Icons.menu, color: AppTheme.greenPrimary),
            ),
          ),
        ],
        backgroundColor: AppTheme.darkSurface,
      ),
      endDrawer: Drawer(
        backgroundColor: AppTheme.darkSurface,
        width: MediaQuery.of(context).size.width * 0.8,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                "Study Modes",
                style: AppTheme.sectionHeaderStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: AppTheme.darkBorder, indent: 32, endIndent: 32),
              const SizedBox(height: 16),
              Expanded(
                child: LearnMode(deckID: widget.deckId!),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cardWidgets.length,
              itemBuilder: (context, index) {
                return cardWidgets[index];
              },
            ),
          ),
        ],
      ),
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
            color: AppTheme.darkCard.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
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
              Icon(Icons.chevron_right, color: AppTheme.lightText.withValues(alpha: 0.3)),
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IPAandWord(card: card),
          if (card.sound != null && dir != null)
            SoundTitle(
              title: "sound",
              value: '$dir/${card.sound}',
              icon: const Icon(Icons.volume_up),
            ),
          TitleAndValue(title: "Meaning", value: card.meaning ?? ''),
          TitleAndValue(title: "Example", value: card.example ?? ''),
          if (card.due != null)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Due: ${DateFormat('MM/dd').format(card.due!)}',
                style: AppTheme.captionStyle.copyWith(color: AppTheme.pinkPrimary),
              ),
            ),
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
          Column(
            children: [
              if (card.usageSound != null && dir != null)
                SoundTitle(
                  title: "u sound",
                  value: '$dir/${card.usageSound}',
                  icon: const Icon(Icons.volume_up),
                ),
              if (card.defSound != null && dir != null)
                SoundTitle(
                  title: "def sound",
                  value: '$dir/${card.defSound}',
                  icon: const Icon(Icons.volume_up),
                ),
            ],
          ),
          if (card.img != null && dir != null)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: PictureHolder(
                w: double.infinity,
                h: 120,
                path: '$dir/${card.img}',
              ),
            ),
          if (card.synonyms != null && dir != null)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: PictureHolder(
                w: double.infinity,
                h: 160,
                path: '$dir/${card.synonyms}',
              ),
            ),
        ],
      ),
    );
  }
}

class IPAandWord extends StatelessWidget {
  const IPAandWord({super.key, required this.card});

  final Flashcard card;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          card.word ?? '',
          style: AppTheme.heroStyle,
          overflow: TextOverflow.ellipsis,
        ),
        if (card.ipa != null)
          Text(
            "/${card.ipa!}/",
            style: AppTheme.captionStyle,
          ),
      ],
    );
  }
}

class CardInformation extends StatelessWidget {
  const CardInformation({super.key, required this.card, required this.dir});

  final Flashcard card;
  final String? dir;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
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
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
        style: AppTheme.bodyMediumStyle.copyWith(
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
      return Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$title: ',
                style: AppTheme.bodyMediumStyle.copyWith(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: value,
                style: AppTheme.bodyMediumStyle,
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