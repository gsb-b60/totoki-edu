import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/studymode/echospell/echospell_noti.dart';
import 'package:totoki_extract/ui/screens/studymode/echospell/echospell_ui.dart';
import 'package:provider/provider.dart';

class Echospell extends StatefulWidget {
  final int deckId;
  const Echospell({super.key, required this.deckId});

  @override
  State<Echospell> createState() => _EchospellState();
}

class _EchospellState extends State<Echospell> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EchospellNoti()..getFlashcardList(widget.deckId),
      child: Consumer<EchospellNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return EchospellUI();
        },
      ),
    );
  }
}


