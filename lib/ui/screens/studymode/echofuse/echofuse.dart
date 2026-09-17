import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/studymode/echofuse/echofuse_noti.dart';
import 'package:totoki_extract/ui/screens/studymode/echofuse/echofuse_ui.dart';
import 'package:provider/provider.dart';

class EchoFuse extends StatefulWidget {
  const EchoFuse({super.key, required this.deckId});
  final int deckId;
  @override
  State<EchoFuse> createState() => _EchoFuseState();
}

class _EchoFuseState extends State<EchoFuse> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EchoFuseNoti()..getFlashcardList(widget.deckId),
      child: Consumer<EchoFuseNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return EchoFuseUI();
        },
      ),
    );
  }
}


