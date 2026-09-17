import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/ielts_card.dart';

class WritingTab extends StatelessWidget {
  const WritingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        IeltsCard(
          co: const Color(0xFFB87333),
          line: "Task 1 – Report",
          aPath: "assets/illumode/bran-stark-37(1).png",
        ),
        IeltsCard(
          co: const Color(0xFFD4943A),
          line: "Task 2 – Essay",
          aPath: "assets/illumode/bran-stark-37(2).png",
        ),
        IeltsCard(
          co: const Color(0xFFE0A84D),
          line: "Grammar & Vocabulary",
          aPath: "assets/illumode/bran-stark-37(3).png",
        ),
        IeltsCard(
          co: const Color(0xFFEDB960),
          line: "Letter Writing (GT)",
          aPath: "assets/illumode/easter-bunny-49.png",
        ),
      ],
    );
  }
}
