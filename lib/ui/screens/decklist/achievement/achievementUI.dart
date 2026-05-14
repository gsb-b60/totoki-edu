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
  Widget build(BuildContext context) {
    final provider = context.watch<Achievementnoti>();
    final flashcards = provider.getCard();
    return Scaffold(
      backgroundColor: AppTheme.darkSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        title: Text(
          "Achievement",
          style: TextStyle(
            color: AppTheme.lightText,
            fontWeight: FontWeight.bold,
            fontSize: 38,
          ),
        ),
        leading: Row(
          children: [
            SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppTheme.darkBorder,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          final card = flashcards[index];
          final due = card.due ?? DateTime.now();
          final Color levelColor;
          final level = card.complexity ?? 1;
          bool Learned = card.reps != null && card.reps! > 0;
          final reps = (card.reps != null && card.reps! >= 0 && card.reps! <= 5)
              ? card.reps
              : 0;
          final path = 'assets/rep/rep$reps.png';

          switch (card.complexity) {
            case 1:
              levelColor = AppTheme.bronze;
              break;
            case 2:
              levelColor = AppTheme.silver;
              break;
            case 3:
              levelColor = AppTheme.amberRank;
              break;
            case 4:
              levelColor = AppTheme.platinum;
              break;
            case 5:
              levelColor = AppTheme.diamond;
              break;
            case 6:
              levelColor = AppTheme.master;
              break;
            case 7:
              levelColor = AppTheme.challenger;
              break;
            default:
              levelColor = Colors.grey;
          }
          //final levelColor=flashcards[index]
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 42, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.darkCard, width: 4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardInforScreen(card: card),
                  ),
                );
              },
              child: ListTile(
                leading: Image.asset(path, width: 30, height: 30),
                title: Text(
                  card.word!,
                  style: TextStyle(
                    color: Learned ? levelColor : AppTheme.darkSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    shadows: [
                      Shadow(
                        color: levelColor.withOpacity(0.8),
                        blurRadius: 10,
                      ),
                      Shadow(
                        color: levelColor.withOpacity(0.6),
                        blurRadius: 20,
                      ),
                      Shadow(
                        color: levelColor.withOpacity(0.4),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  'Due Day: ${due.day}/${due.month}/${due.year}',
                  style: TextStyle(
                    color: AppTheme.lightText.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                trailing: Text(
                  "Level: $level",
                  style: TextStyle(
                    color: levelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    shadows: [
                      Shadow(
                        color: levelColor.withOpacity(0.80),
                        blurRadius: 52,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CardInforScreen extends StatefulWidget {
  CardInforScreen({super.key, required this.card});
  Flashcard card;
  @override
  State<CardInforScreen> createState() => _CardInforScreenState();
}

class _CardInforScreenState extends State<CardInforScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder),
        ),
      ),
      backgroundColor: AppTheme.darkSurface,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                widget.card.word ?? '',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightText,
                ),
                overflow: TextOverflow.fade,
              ),
              if (widget.card.ipa != null)
                Text(
                  "/${widget.card.ipa!}/",
                  style: TextStyle(
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    overflow: TextOverflow.ellipsis,
                    color: AppTheme.lightText,
                    fontFamily: "roboto",
                  ),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MEANING:",
                style: TextStyle(
                  fontSize: 32,
                  overflow: TextOverflow.ellipsis,
                  color: AppTheme.lightText,
                ),
              ),
              SizedBox(
                width: 600,
                child: Text(
                  widget.card.meaning ?? "",
                  style: TextStyle(
                    fontSize: 27,
                    // overflow: TextOverflow.ellipsis,
                    color: AppTheme.lightText,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Example:",
                style: TextStyle(
                  fontSize: 32,
                  overflow: TextOverflow.ellipsis,
                  color: AppTheme.lightText,
                ),
              ),
              SizedBox(
                width: 600,
                child: Text(
                  widget.card.example ?? "",
                  style: TextStyle(
                    fontSize: 27,
                    color: AppTheme.lightText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


