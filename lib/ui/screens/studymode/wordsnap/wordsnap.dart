import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/studymode/wordsnap/wordsnap_noti.dart';
import 'package:totoki_extract/ui/screens/studymode/wordsnap/wordsnap_ui.dart';
import 'package:provider/provider.dart';

class WordSnap extends StatefulWidget {
  const WordSnap({super.key, required this.deckId});
  final int deckId;
  @override
  State<WordSnap> createState() => _WordSnapState();
}

class _WordSnapState extends State<WordSnap> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordSnapNoti()..getFlashcardList(widget.deckId),
      child: Consumer<WordSnapNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return WordSnapUI();
        },
      ),
    );
  }
}
