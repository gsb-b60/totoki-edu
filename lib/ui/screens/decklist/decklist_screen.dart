import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/business/flashcard/deck.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/ui/screens/decklist/cardlistscreen.dart';

class DeckListTab extends StatelessWidget {
  const DeckListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Deckmodel>(
      builder: (context, deckModel, child) => Scaffold(
        backgroundColor: AppTheme.darkBase,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppTheme.darkBase,
          title: const Text(
            'All Decks',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.lightText),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                tooltip: 'Import deck',
                onPressed: deckModel.isLoading
                    ? null
                    : () async {
                        await deckModel.filePicker();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Import process finished.'),
                            ),
                          );
                        }
                      },
                icon: Icon(
                  Icons.upload_file,
                  color: deckModel.isLoading
                      ? Colors.white38
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: _buildDecksTab(deckModel),
      ),
    );
  }

  Widget _buildAnimatedTile(BuildContext context, dynamic deck, dynamic deckModel, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.darkSurface,
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha:0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          Deck.extractCardName(deck.name),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const Icon(Icons.layers, color: AppTheme.greenPrimary),
        onTap: () {
          context.push('/decks/${deck.id}/cards', extra: {'deckName': deck.name});
        },
        trailing: IconButton(
          onPressed: () {
            if (deck.id != null) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text('Delete Deck?', style: TextStyle(color: Colors.white)),
                  content: Text(
                    'This will permanently delete "${deck.name}" and all its cards.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        deckModel.deleteDeck(deck.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red.shade800,
                            content: Text('Deck "${deck.name}" deleted'),
                          ),
                        );
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            }
          },
          icon: const Icon(Icons.delete, color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildDecksTab(dynamic deckModel) {
    return Stack(
      children: [
        if (deckModel.hasError)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    deckModel.error ?? 'An error occurred',
                    style: const TextStyle(color: AppTheme.lightText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => deckModel.fetchDecks(),
                    icon: const Icon(Icons.refresh, color: AppTheme.darkSurface),
                    label: const Text('Retry', style: TextStyle(color: AppTheme.darkSurface)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (!deckModel.isLoading && deckModel.deck.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.layers_outlined, color: AppTheme.lightText, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'No decks yet',
                    style: TextStyle(color: AppTheme.lightText, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Import an Anki deck to get started',
                    style: TextStyle(color: AppTheme.lightText, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await deckModel.fetchDecks();
                    },
                    child: ListView.builder(
                      itemCount: deckModel.deck.length,
                      itemBuilder: (context, index) {
                        final deck = deckModel.deck[index];
                        return _buildAnimatedTile(context, deck, deckModel, index);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (deckModel.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha:0.4),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primaryTeal,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Importing Deck...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CreateNewDeck extends StatefulWidget {
  const CreateNewDeck({super.key});

  @override
  State<CreateNewDeck> createState() => _CreateNewDeckState();
}

class _CreateNewDeckState extends State<CreateNewDeck> {
  final deckController = TextEditingController();

  void _createDeck(BuildContext context, Deckmodel value) {
    final deckName = deckController.text.trim();
    if (deckName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deck name cannot be empty')));
      return;
    }
    final deckExists = value.deck.any((deck) => deck.name == deckName);
    if (deckExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deck "$deckName" already exists')),
      );
      return;
    }
    value.insertDeck(deckName);
    deckController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Deckmodel>(
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: deckController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: "New deck name",
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha:0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryTeal),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.primaryTeal.withValues(alpha:0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryTeal),
                    ),
                    filled: true,
                    fillColor: AppTheme.darkSurface,
                  ),
                  onSubmitted: (_) => _createDeck(context, value),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _createDeck(context, value),
                icon: const Icon(Icons.add, color: AppTheme.darkSurface),
                label: const Text(
                  'Add Deck',
                  style: TextStyle(
                    color: AppTheme.darkSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
