import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/ielts_card.dart';

class SpeakingTab extends StatelessWidget {
  const SpeakingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        IeltsCard(
          co: const Color(0xFF7B4B9A),
          line: "Part 1 – Introduction",
          aPath: "assets/illumode/america-31-d9144.png",
        ),
        IeltsCard(
          co: const Color(0xFF8E5DB5),
          line: "Part 2 – Cue Card",
          aPath: "assets/illumode/america-31-d9144(1).png",
        ),
        IeltsCard(
          co: const Color(0xFFA070CC),
          line: "Part 3 – Discussion",
          aPath: "assets/illumode/mountain-49.png",
        ),
        IeltsCard(
          co: const Color(0xFFB888DD),
          line: "Pronunciation Practice",
          aPath: "assets/illumode/mountain-80.png",
        ),
      ],
    );
  }
}
