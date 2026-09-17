import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/studymode/phonemix/phonemix_noti.dart';
import 'package:totoki_extract/ui/screens/studymode/phonemix/phonemix_ui.dart';
import 'package:provider/provider.dart';

class Phonemix extends StatefulWidget {
  const Phonemix({super.key, required this.deckId});
  final int deckId;

  @override
  State<Phonemix> createState() => _PhonemixState();
}

class _PhonemixState extends State<Phonemix> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PhonemixNoti()..getFlashcardList(widget.deckId),
      child: Consumer<PhonemixNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return PhonemixUI();
        },
      ),
    );
  }
}


