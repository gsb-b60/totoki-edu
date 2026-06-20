import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/business/flashcard/Flashcard.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/ui/lesson/dailyLesson/learnSpec/lessonScreen.dart';
import 'package:totoki_extract/ui/screens/learnmode/learnmodescreen.dart';
import 'package:url_launcher/url_launcher.dart';

class DueDayDashBoard extends StatefulWidget {
  const DueDayDashBoard({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<DueDayDashBoard> createState() => _DueDayDashBoardState();
}

class _DueDayDashBoardState extends State<DueDayDashBoard> {


  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<Cardmodel>().refreshCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: widget.showAppBar
          ? AppBar(
              elevation: 0,
              backgroundColor: AppTheme.darkBase,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.lightText,
                ),
              ),
              title: Text(
                "DASHBOARD",
                style: AppTheme.sectionHeaderStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Hero Section - Big Pressure
                Consumer<Cardmodel>(
                  builder: (context, value, child) {
                    return Column(
                      children: [
                        Center(
                          child: Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.80,
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(
                                    value.dueCount.toString(),
                                    style: AppTheme.heroStyle.copyWith(
                                      fontSize: 256, // reference size — FittedBox scales it
                                      color: AppTheme.redPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                "CARDS DUE TODAY",
                                style: AppTheme.captionStyle.copyWith(
                                  color: AppTheme.redPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Stats Grid
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatCard(
                                label: "LEARNED",
                                value: value.learnedCount.toString(),
                                icon: Icons.auto_awesome,
                                color: AppTheme.bluePrimary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatCard(
                                label: "MASTERED",
                                value: value.masterCount.toString(),
                                icon: Icons.workspace_premium,
                                color: AppTheme.greenPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Information Section
                _InfoCard(
                  title: "SPACED LEARNING ALGORITHM",
                  content:
                      "Your learning is powered algorithm base on the supermemo2, if the frequency anoying you report to us, we will consider to add a option to turn it off.",
                  icon: Icons.psychology,
                  accentColor: AppTheme.primaryTeal,
                ),

                const SizedBox(height: 16),

                _InfoCard(
                  title: "TOTOKI",
                  content:
                      "Small tool to extract data from anki, and use it to create a flashcard app, if you have any suggestion or feedback, please let us know by click the button below.",
                  icon: Icons.rocket_launch,
                  accentColor: AppTheme.bluePrimary,
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: "TOTOKI IS IN EARLY DEVELOPMENT",
                  content:
                      "I found that many Anki decks are structured differently, causing unstable imports and broken extraction. For this release, I decided to disable custom extraction and ship with a verified deck instead. Better Anki compatibility will come later.",
                  icon: Icons.science,
                  accentColor: AppTheme.pinkPrimary,
                ),

                const SizedBox(height: 40),

                // Thumb Zone Actions
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LearnModeScreen()),
                    ); // Placeholder navigation
                  }, // Action to be connected
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.greenPrimary,
                    foregroundColor: AppTheme.darkBase,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: AppTheme.greenAccent.withOpacity(0.5),
                  ),
                  child: Text(
                    "START DAILY SESSION",
                    style: AppTheme.bodyLargeStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkBase,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: () async {
                    final Uri url = Uri.parse(
                      'https://docs.google.com/forms/d/e/1FAIpQLSfDWLhesLWpvfpsSb3-bx3T1bGGzbkh1QZY7oAsc61Pe4XvLQ/viewform?usp=dialog',
                    );

                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }, // Action to be connected, // Feedback link
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.lightText.withOpacity(0.7),
                    side: BorderSide(
                      color: AppTheme.darkBorder.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "PROVIDE FEEDBACK",
                    style: AppTheme.bodyMediumStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.bodyMediumStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.captionStyle.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightText.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color accentColor;

  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkBase.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkBorder.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.bodySmallStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTheme.bodySmallStyle.copyWith(
              color: AppTheme.lightText.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
