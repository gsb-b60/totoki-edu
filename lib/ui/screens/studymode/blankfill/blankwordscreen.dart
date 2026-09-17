import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:provider/provider.dart';

class BlankWordScreen extends StatefulWidget {
  final int deckId;
  const BlankWordScreen({super.key, required this.deckId});

  @override
  State<BlankWordScreen> createState() => _BlankWordScreenState();
}

class _BlankWordScreenState extends State<BlankWordScreen> {
  late Future<List<Flashcard>> futureCard;
  late String media;

  Future<List<Flashcard>> _loadDueCard() async {
    final cardModel = Provider.of<Cardmodel>(context, listen: false);
    media = cardModel.media ?? "";
    return cardModel.getDueCards(widget.deckId);
  }

  @override
  void initState() {
    super.initState();
    futureCard = _loadDueCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        title: const Text(
          'Blank Fill',
          style: TextStyle(color: AppTheme.lightText),
        ),
        backgroundColor: AppTheme.darkBase,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.lightText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder(
        future: futureCard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}", style: const TextStyle(color: AppTheme.lightText)),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No cards found", style: TextStyle(color: AppTheme.lightText)),
            );
          }

          final list = snapshot.data!;

          return ChangeNotifierProvider(
            create: (_) => QuizzModel(list: list, media: media),
            child: Consumer<QuizzModel>(
              builder: (context, quiz, _) => Stack(
                children: [
                  BlankWordQuizz(
                    media: quiz.file,
                    onComplete: quiz.nextWord,
                    card: quiz.currentCard,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuizzModel extends ChangeNotifier {
  final List<Flashcard> list;
  final String media;
  QuizzModel({required this.list, required this.media});

  String get file => media;
  int wordIdx = 0;
  Flashcard get currentCard => list[wordIdx];
  void nextWord() {
    wordIdx = (wordIdx + 1) % list.length;
    notifyListeners();
  }
}

class BlankWordQuizz extends StatefulWidget {
  final Flashcard card;
  final String media;
  final VoidCallback onComplete;
  const BlankWordQuizz({
    super.key,
    required this.media,
    required this.onComplete,
    required this.card,
  });

  @override
  State<BlankWordQuizz> createState() => _BlankWordQuizzState();
}

class _BlankWordQuizzState extends State<BlankWordQuizz> {
  String get word => widget.card.word ?? "";
  String get media => widget.media;
  Flashcard get card => widget.card;
  late List<String> blanks;
  int curIdx = 0;
  late List<String> list;
  late List<String> wordList;
  List<bool> visible = [];
  List<bool> trueList = [];
  bool finish = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (word.contains(' ')) {
      list = word.split(' ')..shuffle();
      wordList = word.split(' ');
      blanks = List.filled(list.length, '-------');
      visible = List.filled(list.length, true);
      trueList = List.filled(list.length, true);
    } else {
      list = word.split('')..shuffle();
      wordList = word.split('');
      blanks = List.filled(word.length, '_');
      visible = List.filled(list.length, true);
      trueList = List.filled(list.length, true);
    }
  }

  Future<bool> checkAnswer(String letter, int index) async {
    try {
      if (letter == wordList[curIdx]) {
        setState(() {
          blanks[curIdx] = wordList[curIdx];
          visible[index] = false;
          curIdx++;
        });

        if (curIdx <= wordList.length && curIdx == wordList.length) {
          if (media.isNotEmpty && card.sound != null && card.sound!.isNotEmpty) {
            try {
              await _audioPlayer.play(
                DeviceFileSource(
                  PathService.getFilePath(media, card.sound ?? ""),
                ),
              );
            } catch (e) {
              debugPrint('Unable to play sound: $e');
            }
          }
          setState(() {
            finish = true;
          });
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) setState(() => finish = false);
          });
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) widget.onComplete();
        }
        return true;
      } else {
        setState(() => trueList[index] = false);

        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          setState(() => trueList[index] = true);
        });
        return false;
      }
    } catch (e) {
      debugPrint('Error checking answer: $e');
      return false;
    }
  }

  @override
  void didUpdateWidget(covariant BlankWordQuizz oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.word != widget.card.word) {
      setState(() {
        if (word.contains(' ')) {
          list = word.split(' ')..shuffle();
          wordList = word.split(' ');
          blanks = List.filled(list.length, '-------');
          visible = List.filled(list.length, true);
          trueList = List.filled(list.length, true);
        } else {
          list = word.split('')..shuffle();
          wordList = word.split('');
          blanks = List.filled(word.length, '_');
          visible = List.filled(list.length, true);
          trueList = List.filled(list.length, true);
        }
        curIdx = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card.meaning ?? "",
                        style: AppTheme.sectionHeaderStyle.copyWith(color: AppTheme.lightText),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: blanks.asMap().entries.map((entry) {
                          return Text(
                            "${entry.value} ",
                            style: AppTheme.bodyLargeStyle.copyWith(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(list.length, (index) {
                    final value = list[index];
                    return AnimatedOpacity(
                      opacity: visible[index] ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: () => checkAnswer(value, index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: trueList[index]
                              ? AppTheme.primaryTeal
                              : AppTheme.redPrimary,
                          minimumSize: const Size(64, 64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          value,
                          style: AppTheme.sectionHeaderStyle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
        Visibility(
          visible: finish,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                color: AppTheme.darkCard,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card.word ?? "",
                        style: AppTheme.heroStyle.copyWith(color: AppTheme.greenPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card.meaning ?? "",
                        overflow: TextOverflow.clip,
                        style: AppTheme.bodyMediumStyle.copyWith(color: AppTheme.lightText),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
