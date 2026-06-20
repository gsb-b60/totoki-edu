import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/learnSpec/lessonScreen.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/business/flashcard/Deck.dart';
import 'package:totoki_extract/ui/screens/dashboard/dashBoard.dart';
import 'package:totoki_extract/ui/screens/decklist/achievement/achievement.dart';
import 'package:totoki_extract/ui/screens/learnmode/learnmodescreen.dart';
import 'package:provider/provider.dart';
import 'cardlistscreen.dart';
import 'package:totoki_extract/business/flashcard/Flashcard.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  Widget _buildAnimatedTile(dynamic deck, dynamic deckModel, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.darkSurface,
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<Cardmodel>(
                create: (_) => Cardmodel(),
                child: CardListScreen(deckId: deck.id, deckName: deck.name),
              ),
            ),
          );
        },
        trailing: IconButton(
          onPressed: () {
            if (deck.id != null) {
              deckModel.deleteDeck(deck.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red.shade800,
                  content: Text('Deck "${deck.name}" deleted'),
                ),
              );
            }
          },
          icon: const Icon(Icons.delete, color: Colors.white70),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final deckModel = Provider.of<Deckmodel>(context, listen: false);
    deckModel.hadDB().then((hadDB) {
      if (!hadDB) {
        deckModel.filePicker().then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Import process finished.'),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppTheme.darkBase,
        title: const Text(
          "All Decks",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 60),
            child: Consumer<Deckmodel>(
              builder: (context, deckModel, child) => IconButton(
                onPressed: deckModel.isLoading
                    ? null
                    : () async {
                        await deckModel.filePicker();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Import process finished.'),
                            ),
                          );
                        }
                      },
                icon: Icon(
                  Icons.upload_file,
                  color: deckModel.isLoading ? Colors.white38 : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<Deckmodel>(
        builder: (context, deckModel, child) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                child: Column(
                  children: [
                    // const CreateNewDeck(),
                    // const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: deckModel.deck.length,
                        itemBuilder: (context, index) {
                          final deck = deckModel.deck[index];
                          return _buildAnimatedTile(deck, deckModel, index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (deckModel.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
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
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          border: Border(
            top: BorderSide(
              color: AppTheme.darkBorder.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                ButtomNav(
                  value: "Stats",
                  ico: Icons.stars_rounded,
                  screenBuilder: () => Achievement(),
                ),
                ButtomNav(
                  value: "Lesson",
                  ico: Icons.flash_on_rounded,
                  isMain: true,
                  screenBuilder: () => LearnModeScreen(),
                ),
                ButtomNav(
                  value: "Dashboard",
                  ico: Icons.space_dashboard_rounded,
                  screenBuilder: () => DueDayDashBoard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ButtomNav extends StatelessWidget {
  const ButtomNav({
    super.key,
    required this.value,
    required this.ico,
    required this.screenBuilder,
    this.isMain = false,
  });
  final String value;
  final IconData ico;
  final Widget Function() screenBuilder;
  final bool isMain;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screenBuilder()),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: isMain ? 4 : 0),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isMain ? AppTheme.greenPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                ico,
                color: isMain ? AppTheme.darkBase : AppTheme.greenPrimary,
                size: isMain ? 34 : 26,
              ),
              const SizedBox(height: 4),
              Text(
                value.toUpperCase(),
                style: AppTheme.captionStyle.copyWith(
                  color: isMain ? AppTheme.darkBase : AppTheme.greenPrimary,
                  fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
                  fontSize: isMain ? 11 : 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
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
                color: Colors.black.withOpacity(0.2),
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
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryTeal),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.primaryTeal.withOpacity(0.5),
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
