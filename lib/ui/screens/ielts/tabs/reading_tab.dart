import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/ielts_card.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/passages_screen.dart';

class ReadingTab extends StatelessWidget {
  const ReadingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        IeltsCard(
          co: const Color(0xFF2E5C8A),
          line: "Passages",
          aPath: "assets/illumode/alien-2-87.png",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PassagesScreen())),
        ),
        IeltsCard(
          co: const Color(0xFF3A7CA5),
          line: "True / False / Not Given",
          aPath: "assets/illumode/bran-stark-37.png",
        ),
        IeltsCard(
          co: const Color(0xFF4A90D9),
          line: "Multiple Choice",
          aPath: "assets/illumode/balloon-46.png",
        ),
        IeltsCard(
          co: const Color(0xFF5BA3E6),
          line: "Fill in the Blanks",
          aPath: "assets/illumode/rocket-launch-61.png",
        ),
        IeltsCard(
          co: const Color(0xFF3D6FA0),
          line: "Matching Headings",
          aPath: "assets/illumode/conversation-29.png",
        ),
      ],
    );
  }
}
