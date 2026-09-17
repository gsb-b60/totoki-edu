import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/studymode/wordpulse/wordpulse_noti.dart';
import 'package:totoki_extract/ui/screens/studymode/wordpulse/wordpulse_ui.dart';
import 'package:provider/provider.dart';

class WordPulse extends StatefulWidget {
  const WordPulse({super.key, required this.deckId});
  final int deckId;
  @override
  State<WordPulse> createState() => _WordPulseState();
}

class _WordPulseState extends State<WordPulse> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordPulseNoti()..getFlashcardList(widget.deckId),
      child: Consumer<WordPulseNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return WordPulseUI();
        },
      ),
    );
  }
}
