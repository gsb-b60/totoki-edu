import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/studymode/mindfield/mindfield_noti.dart';
import 'package:totoki_extract/ui/screens/studymode/mindfield/mindfield_ui.dart';
import 'package:provider/provider.dart';

class MindField extends StatefulWidget {
  const MindField({super.key, required this.deckId});
  final int deckId;

  @override
  State<MindField> createState() => _MindFieldState();
}

class _MindFieldState extends State<MindField> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MindfieldNoti()..getFlashcardList(widget.deckId),
      child: Consumer<MindfieldNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const MindFieldUI();
        },
      ),
    );
  }
}