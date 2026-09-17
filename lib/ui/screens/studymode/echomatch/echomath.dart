import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/studymode/echomatch/echomatch_noti.dart';
import 'package:totoki_extract/ui/screens/studymode/echomatch/echomath_ui.dart';
import 'package:provider/provider.dart';

class EchoMatch extends StatefulWidget {
  const EchoMatch({super.key, required this.deckId});
  final int deckId;
  @override
  State<EchoMatch> createState() => _EchoMatchState();
}

class _EchoMatchState extends State<EchoMatch> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EchoMatchNoti()..getFlashcardList(widget.deckId),
      child: Consumer<EchoMatchNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return EchoMatchUI();
        },
      ),
    );
  }
}


