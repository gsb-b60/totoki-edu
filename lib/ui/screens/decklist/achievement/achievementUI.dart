import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/business/flashcard/Flashcard.dart';
import 'package:totoki_extract/ui/screens/decklist/achievement/achievementNoti.dart';
import 'package:provider/provider.dart';

class AchievementUI extends StatefulWidget {
  const AchievementUI({super.key});

  @override
  State<AchievementUI> createState() => _AchievementState();
}

class _AchievementState extends State<AchievementUI> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Achievementnoti>(context, listen: false).fetchCard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Achievementnoti>();
    final flashcards = provider.getCard();
    return Scaffold(
      backgroundColor: AppTheme.darkSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        title: const Text(
          "Achievement",
          style: AppTheme.screenTitleStyle,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.darkBorder,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : flashcards.isEmpty
              ? Center(
                  child: Text(
                    "No achievement cards found.",
                    style: AppTheme.bodyLargeStyle.copyWith(color: AppTheme.lightText.withOpacity(0.7)),
                  ),
                )
              : ListView.builder(
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          final card = flashcards[index];
          final due = card.due ?? DateTime.now();
          final Color levelColor;
          final level = card.complexity ?? 1;
          bool learned = card.reps != null && card.reps! > 0;
          final reps = (card.reps != null && card.reps! >= 0 && card.reps! <= 5)
              ? card.reps
              : 0;
          final path = 'assets/rep/rep$reps.png';

          switch (card.complexity) {
            case 1: levelColor = AppTheme.bronze; break;
            case 2: levelColor = AppTheme.silver; break;
            case 3: levelColor = AppTheme.amberRank; break;
            case 4: levelColor = AppTheme.platinum; break;
            case 5: levelColor = AppTheme.diamond; break;
            case 6: levelColor = AppTheme.master; break;
            case 7: levelColor = AppTheme.challenger; break;
            default: levelColor = Colors.grey;
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.darkBase,
              border: Border.all(color: AppTheme.darkCard, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardInforScreen(card: card),
                  ),
                );
              },
              leading: Image.asset(path, width: 32, height: 32),
              title: Text(
                card.word!,
                style: AppTheme.sectionHeaderStyle.copyWith(
                  color: learned ? levelColor : AppTheme.darkCard,
                  shadows: learned ? [
                    Shadow(color: levelColor.withOpacity(0.5), blurRadius: 8),
                  ] : [],
                ),
              ),
              subtitle: Text(
                'Due Day: ${due.day}/${due.month}/${due.year}',
                style: AppTheme.captionStyle.copyWith(
                  color: AppTheme.lightText.withOpacity(0.6),
                ),
              ),
              trailing: Text(
                "Lvl $level",
                style: AppTheme.bodyLargeStyle.copyWith(
                  color: levelColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CardInforScreen extends StatelessWidget {
  const CardInforScreen({super.key, required this.card});
  final Flashcard card;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder),
        ),
      ),
      backgroundColor: AppTheme.darkSurface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    card.word ?? '',
                    style: AppTheme.heroStyle,
                  ),
                ),
                if (card.ipa != null)
                  Text(
                    "/${card.ipa!}/",
                    style: AppTheme.sectionHeaderStyle.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.lightText.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            _InfoSection(label: "MEANING", value: card.meaning ?? "No meaning provided."),
            const SizedBox(height: 24),
            _InfoSection(label: "EXAMPLE", value: card.example ?? "No example provided."),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String label;
  final String value;

  const _InfoSection({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyLargeStyle.copyWith(
            color: AppTheme.primaryTeal,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.bodyMediumStyle,
        ),
      ],
    );
  }
}


