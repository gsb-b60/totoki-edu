import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/ielts_card.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/passages_screen.dart';

class ReadingTab extends StatelessWidget {
  const ReadingTab({super.key});

  static const _seriesColors = [
    Color(0xFF2E5C8A),
    Color(0xFF3A7CA5),
    Color(0xFF4A90D9),
    Color(0xFF5BA3E6),
  ];

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
        const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 12),
          child: Text(
            "ALL PASSAGES",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GridView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.5,
          ),
          children: [
            for (int s = 1; s <= 4; s++)
              for (int t = 1; t <= 4; t++)
                for (int p = 1; p <= 3; p++)
                  for (int g = 1; g <= 2; g++)
                    _GridCell(
                      label: "S$s-T$t-P$p-G$g",
                      color: _seriesColors[s - 1],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PassagesScreen(
                            seriesId: s,
                            testId: t,
                            part: p,
                            questionGroup: g,
                          ),
                        ),
                      ),
                    ),
          ],
        ),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GridCell({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
