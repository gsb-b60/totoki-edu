import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/studymode/neuropick/neuropick_noti.dart';
import 'package:totoki_extract/ui/screens/studymode/neuropick/neuropick_ui.dart';
import 'package:provider/provider.dart';

class NeuroPick extends StatefulWidget {
  const NeuroPick({super.key, required this.deckId});
  final int deckId;
  @override
  State<NeuroPick> createState() => _NeuroPickState();
}

class _NeuroPickState extends State<NeuroPick> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NeuroPickNoti()..getFlashcardList(widget.deckId),
      child: Consumer<NeuroPickNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return NeuroPickUI();
        },
      )
    );
  }
}

