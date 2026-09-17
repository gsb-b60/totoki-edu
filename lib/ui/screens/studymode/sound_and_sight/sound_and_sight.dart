import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/studymode/sound_and_sight/sound_and_sight_noti.dart';
import 'package:totoki_extract/ui/screens/studymode/sound_and_sight/sound_and_sight_ui.dart';
import 'package:provider/provider.dart';

class SoundNSight extends StatefulWidget {
  const SoundNSight({super.key, required this.deckId});
  final int deckId;
  @override
  State<SoundNSight> createState() => _SoundNSightState();
}

class _SoundNSightState extends State<SoundNSight> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SoundNSightNoti()..getFlashcardList(widget.deckId),
      child: Consumer<SoundNSightNoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return SoundNSightUI();
        },
      ),
    );
  }
}


