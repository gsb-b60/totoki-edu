import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/learnSpec/lessonScreen.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/business/flashcard/Deck.dart';
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
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.darkerCard,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 239, 239).withOpacity(0.5),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          deck.name,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const Icon(Icons.layers, color: Colors.white),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkSurface,
      appBar: AppBar(
        leading: const Icon(Icons.menu_book, color: Colors.white),
        backgroundColor: AppTheme.darkSurface,
        title: const Text(
          "All Deck Card",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<Deckmodel>(context, listen: false).filePicker();
            },
            icon: const Icon(
              Icons.assignment_returned_rounded,
              color: Colors.white,
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(right: 60),
            child: IconButton(
              onPressed: () {
                Provider.of<Deckmodel>(context, listen: false).filePickerReal();
              },
              icon: const Icon(Icons.upload_file, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CreateNewDeck(),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<Deckmodel>(
                  builder: (context, deckModel, child) {
                    return ListView.builder(
                      itemCount: deckModel.deck.length,
                      itemBuilder: (context, index) {
                        final deck = deckModel.deck[index];
                        return _buildAnimatedTile(deck, deckModel, index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: AppTheme.darkSurface,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtomNav(
              value: "Achievement",
              ico: Icons.stars,
              screenBuilder: () => Achievement(),
            ),
            ButtomNav(
              value: "Lesson",
              ico: Icons.flash_on_rounded,
              screenBuilder: () => LearnModeScreen(),
            ),
          ],
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
  });
  final String value;
  final IconData ico;
  final Widget Function() screenBuilder;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenBuilder()),
        );
      },
      child: Container(
        width: 150,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.greenPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(ico, color: AppTheme.darkSurface, size: 35),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.darkSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: deckController,
                decoration: InputDecoration(labelText: "new deck name"),
                onSubmitted: (_) => _createDeck(context, value),
              ),
            ),
            ElevatedButton(
              onPressed: () => _createDeck(context, value),
              child: Text('them deck'),
            ),
          ],
        );
      },
    );
  }
}


