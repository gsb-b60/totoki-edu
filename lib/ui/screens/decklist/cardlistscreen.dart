import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/business/flashcard/deck.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';

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
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.deckId != null) {
        final cardModel = Provider.of<Cardmodel>(context, listen: false);
        cardModel.fetchCards(widget.deckId!);
        setState(() => _isInitialLoad = false);
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

    String displayName = Deck.extractCardName(widget.deckName ?? "My Deck");

    final List<Widget> cardWidgets = cardModel.card.map((card) {
      return FlashCardItem(card: card, media: cardModel.media);
    }).toList();
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.lightText),
        ),
        title: Text(
          displayName,
          style: AppTheme.sectionHeaderStyle.copyWith(fontWeight: FontWeight.bold),
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
        backgroundColor: AppTheme.darkBase,
      ),
      endDrawer: Drawer(
        backgroundColor: AppTheme.darkBase,
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
      body: _buildCardListBody(cardModel, cardWidgets),
    );
  }

  Widget _buildCardListBody(Cardmodel cardModel, List<Widget> cardWidgets) {
    if (_isInitialLoad && cardModel.card.isEmpty && !cardModel.hasError) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
    }

    if (cardModel.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                cardModel.error ?? 'An error occurred',
                style: const TextStyle(color: AppTheme.lightText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.deckId != null) {
                    final cm = Provider.of<Cardmodel>(context, listen: false);
                    cm.fetchCards(widget.deckId!);
                  }
                },
                icon: const Icon(Icons.refresh, color: AppTheme.darkSurface),
                label: const Text('Retry', style: TextStyle(color: AppTheme.darkSurface)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              ),
            ],
          ),
        ),
      );
    }

    if (!cardModel.hasError && cardModel.card.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.credit_card_outlined, color: AppTheme.lightText, size: 64),
              SizedBox(height: 16),
              Text(
                'No cards in this deck yet',
                style: TextStyle(color: AppTheme.lightText, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Add cards or study a different deck',
                style: TextStyle(color: AppTheme.lightText, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              final cardModel = Provider.of<Cardmodel>(context, listen: false);
              if (widget.deckId != null) {
                await cardModel.fetchCards(widget.deckId!);
              }
            },
            child: ListView.builder(
              itemCount: cardWidgets.length,
              itemBuilder: (context, index) {
                return cardWidgets[index];
              },
            ),
          ),
        ),
      ],
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
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: Offset(0, 3),
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
              icon: const Icon(Icons.volume_up, color: AppTheme.greenPrimary),
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
          Row(
            children: [
              if (card.usageSound != null && dir != null)
                SoundTitle(
                  title: "u sound",
                  value: '$dir/${card.usageSound}',
                  icon: const Icon(Icons.volume_up, color: AppTheme.greenPrimary),
                ),
              if (card.defSound != null && dir != null)
                SoundTitle(
                  title: "def sound",
                  value: '$dir/${card.defSound}',
                  icon: const Icon(Icons.volume_up, color: AppTheme.greenPrimary),
                ),
            ],
          ),
          if (card.img != null && dir != null)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: PictureHolder(
                w: double.infinity,
                h: 200,
                path: '$dir/${card.img}',
              ),
            ),
          if (card.synonyms != null && dir != null)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: PictureHolder(
                w: double.infinity,
                h: 240,
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
        decoration: BoxDecoration(
          color: AppTheme.darkBase,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.darkBorder.withValues(alpha: 0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(path!), 
            fit: BoxFit.contain,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
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
    if (value.isNotEmpty) {
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