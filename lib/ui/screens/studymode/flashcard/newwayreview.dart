import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:provider/provider.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:flip_card/flip_card.dart';
import 'front.dart';
import "back.dart";
import 'dart:math';

class Newwayreview extends StatefulWidget {
  final int deckId;
  const Newwayreview({super.key, required this.deckId});

  @override
  State<Newwayreview> createState() => _Newwayreview();
}

class _Newwayreview extends State<Newwayreview> {
  List<Flashcard> _dueCards = [];
  bool _isLoading = true;
  List<Widget>? cardWidgets;

  Future<void> _loadDueCard() async {
    final cardModel = Provider.of<Cardmodel>(context, listen: false);
    _dueCards = await cardModel.getDueCards(widget.deckId);
    cardWidgets = _dueCards.map((card) {
      return FlipCardItem(card: card, media: cardModel.media);
    }).toList();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDueCard();
  }

  final controller = SwipableStackController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.lightText, size: 24),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Review Cards',
          style: AppTheme.sectionHeaderStyle.copyWith(color: AppTheme.lightText),
        ),
        actions: [
          IconButton(
            tooltip: 'Undo last review',
            icon: Icon(Icons.undo, color: AppTheme.primaryTeal),
            onPressed: () async {
              final cardModel = Provider.of<Cardmodel>(context, listen: false);
              await cardModel.undoLastReview();
              controller.rewind();
            },
          ),
        ],
        backgroundColor: AppTheme.darkBase,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Swipeder(
                      controller: controller,
                      cardWidgets: cardWidgets,
                      cards: _dueCards,
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

class Swipeder extends StatefulWidget {
  const Swipeder({
    super.key,
    required this.controller,
    required this.cardWidgets,
    required this.cards,
  });

  final SwipableStackController controller;
  final List<Widget>? cardWidgets;
  final List<Flashcard>? cards;

  @override
  State<Swipeder> createState() => _SwipederState();
}

class _SwipederState extends State<Swipeder> {
  int _activeItem = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SwipableStack(
          controller: widget.controller,
          horizontalSwipeThreshold: 0.1,
          verticalSwipeThreshold: 0.3,
          detectableSwipeDirections: const {
            SwipeDirection.up,
            SwipeDirection.down,
          },
          swipeAssistDuration: const Duration(milliseconds: 200),
          stackClipBehaviour: Clip.none,
          swipeAnchor: SwipeAnchor.bottom,
          overlayBuilder: (context, properties) {
            final opacity = min(properties.swipeProgress, 1.0);
            switch (properties.direction) {
              case SwipeDirection.up:
                return Opacity(
                  opacity: opacity,
                  child: CardLabel(
                    color: AppTheme.redPrimary,
                    value: "HARD",
                  ),
                );
              case SwipeDirection.down:
                return Opacity(
                  opacity: opacity,
                  child: CardLabel(
                    color: AppTheme.greenPrimary,
                    value: "EASY",
                  ),
                );
              default:
                return const SizedBox.shrink();
            }
          },
          builder: (context, properties) {
            if (widget.cardWidgets == null || widget.cardWidgets!.isEmpty) {
              return Center(
                child: Text(
                  "All cards reviewed!",
                  style: AppTheme.sectionHeaderStyle.copyWith(color: AppTheme.lightText),
                ),
              );
            }
            final itemIndex = properties.index % widget.cardWidgets!.length;
            return widget.cardWidgets![itemIndex];
          },
          onSwipeCompleted: (index, direction) {
            setState(() {
              _activeItem = (index + 1) % (widget.cards?.length ?? 1);
            });
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(6, (i) {
                final isEasy = i >= 3;
                final label = i == 5 ? 'Perfect' : (i == 4 ? 'Easy' : (i == 3 ? 'Good' : (i == 2 ? 'Again' : (i == 1 ? 'Poor' : 'Null'))));
                
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 3,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (widget.cards == null || widget.cards!.isEmpty) return;
                      if (_activeItem >= widget.cards!.length) return;
                      
                      final card = widget.cards![_activeItem];
                      final cardModel = Provider.of<Cardmodel>(context, listen: false);
                      await cardModel.updateCardAfterReview(card, i);

                      final dir = (i >= 3) ? SwipeDirection.down : SwipeDirection.up;
                      widget.controller.next(swipeDirection: dir);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEasy ? AppTheme.greenPrimary.withValues(alpha:0.8) : AppTheme.redPrimary.withValues(alpha:0.8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          i.toString(),
                          style: AppTheme.bodyLargeStyle.copyWith(
                            color: AppTheme.darkBase,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          label,
                          style: AppTheme.bodyMediumStyle.copyWith(
                            color: AppTheme.darkBase,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class CardLabel extends StatelessWidget {
  final Color color;
  final String value;
  const CardLabel({
    super.key,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 4),
          borderRadius: BorderRadius.circular(24),
          color: AppTheme.darkBase.withValues(alpha:0.8),
        ),
        child: Text(
          value,
          style: AppTheme.heroStyle.copyWith(
            color: color,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}

class FlipCardItem extends StatefulWidget {
  final Flashcard? card;
  final String? media;
  const FlipCardItem({super.key, required this.card, required this.media});

  @override
  State<FlipCardItem> createState() => _FlipCardItemState();
}

class _FlipCardItemState extends State<FlipCardItem> {
  @override
  Widget build(BuildContext context) {
    final backKey = GlobalKey<BackSideState>();
    return FlipCard(
      speed: 300,
      front: FrontSide(widget: widget),
      back: BackSide(key: backKey, card: widget.card!, media: widget.media),
      onFlipDone: (isFront) {
        if (!isFront) {
          backKey.currentState?.playSound(
            widget.media!,
            widget.card?.sound ?? '',
          );
        }
      },
    );
  }
}



