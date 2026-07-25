import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/ui/screens/decklist/achievement/achievementNoti.dart';
import 'package:provider/provider.dart';

class AchievementUI extends StatefulWidget {
  const AchievementUI({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<AchievementUI> createState() => _AchievementState();
}

class _AchievementState extends State<AchievementUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Achievementnoti>();
    final flashcards = provider.getCards();
    return Scaffold(
      backgroundColor: AppTheme.darkSurface,
      appBar: widget.showAppBar
          ? AppBar(
      backgroundColor: AppTheme.darkBase,
              title: Text("Achievement", style: AppTheme.screenTitleStyle),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder, size: 24),
                onPressed: () => context.pop(),
              ),
            )
          : null,
      body: flashcards.isEmpty && !provider.isLoading
          ? Center(
              child: Text(
                "No achievement cards found.",
                style: AppTheme.bodyLargeStyle.copyWith(color: AppTheme.lightText.withOpacity(0.7)),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: provider.isLoading && flashcards.isEmpty
                        ? const Center(key: ValueKey('spinner'), child: CircularProgressIndicator())
                        : ListView.builder(
                            key: ValueKey(provider.currentPage),
                            itemCount: flashcards.length + 1,
                            itemBuilder: (context, index) {
                          if (index == flashcards.length) {
                            return Container(
                              color: AppTheme.darkBase,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: provider.hasPrev ? () => provider.prevPage() : null,
                                    icon: const Icon(Icons.chevron_left),
                                    color: provider.hasPrev ? Colors.white : AppTheme.darkBorder,
                                  ),
                                  Text(
                                    "Page ${provider.currentPage} of ${provider.totalPages} (${provider.totalCards} cards)",
                                    style: TextStyle(color: AppTheme.lightText.withOpacity(0.5), fontSize: 13),
                                  ),
                                  IconButton(
                                    onPressed: provider.hasNext ? () => provider.nextPage() : null,
                                    icon: const Icon(Icons.chevron_right),
                                    color: provider.hasNext ? Colors.white : AppTheme.darkBorder,
                                  ),
                                ],
                              ),
                            );
                          }
                          final card = flashcards[index];
                          final due = card.due ?? DateTime.now();
                          final level = card.complexity ?? 1;
                          final learned = card.reps != null && card.reps! > 0;
                          final reps = (card.reps != null && card.reps! >= 0 && card.reps! <= 5)
                              ? card.reps
                              : 0;
                          final path = 'assets/rep/rep$reps.png';

                          final Color levelColor;
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
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.darkBase,
                              border: Border.all(color: AppTheme.darkBorder, width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () {
                                context.push('/stats/card', extra: card);
                              },
                              leading: Image.asset(path, width: 32, height: 32),
                              title: Text(
                                card.word!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: learned ? levelColor : AppTheme.darkBorder,
                                  shadows: learned ? [
                                    Shadow(color: levelColor.withOpacity(0.5), blurRadius: 8),
                                  ] : [],
                                ),
                              ),
                              subtitle: Text(
                                'Due: ${due.day}/${due.month}/${due.year}',
                                style: TextStyle(color: AppTheme.lightText.withOpacity(0.4), fontSize: 12),
                              ),
                              trailing: Text(
                                "Lvl $level",
                                style: TextStyle(
                                  color: learned ? levelColor : AppTheme.darkBorder,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),)
                  ]
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
        backgroundColor: AppTheme.darkBase,
        leading: IconButton(
          onPressed: () => context.pop(),
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
          style: TextStyle(
            color: AppTheme.lightText.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}
