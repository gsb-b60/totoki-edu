import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/ielts_card.dart';

class ListeningTab extends StatelessWidget {
  const ListeningTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        IeltsCard(
          co: const Color(0xFF1F7A5C),
          line: "Section 1 – Conversation",
          aPath: "assets/illumode/coach-8.png",
        ),
        IeltsCard(
          co: const Color(0xFF279A72),
          line: "Section 2 – Monologue",
          aPath: "assets/illumode/team-work-2-49.png",
        ),
        IeltsCard(
          co: const Color(0xFF30B888),
          line: "Section 3 – Discussion",
          aPath: "assets/illumode/brainstorming-31.png",
        ),
        IeltsCard(
          co: const Color(0xFF38D09A),
          line: "Section 4 – Lecture",
          aPath: "assets/illumode/easter-meal-36.png",
        ),
        IeltsCard(
          co: const Color(0xFF41E0A8),
          line: "Note Completion",
          aPath: "assets/illumode/easter-balloon-64.png",
        ),
      ],
    );
  }
}
