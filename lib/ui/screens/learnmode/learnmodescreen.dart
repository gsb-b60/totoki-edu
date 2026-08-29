import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/features/lesson/models/storage.dart';



class LearnModeScreen extends StatefulWidget {
  const LearnModeScreen({super.key});

  @override
  State<LearnModeScreen> createState() => _LearnModeScreenState();
}

class _LearnModeScreenState extends State<LearnModeScreen> {
  int index = 0;
  final List<Widget> _screens = [
    const DailyLearnScreenNav(),
    const LevelLearnScreenNav(),
    const LearnByMode(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      body: Column(
        children: [
          Container(
            color: AppTheme.darkBase,
            child: Row(
              children: List.generate(3, (i) {
                final selected = index == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => index = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected
                                ? AppTheme.greenPrimary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        const ['Daily', 'Levels', 'Modes'][i],
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyMediumStyle.copyWith(
                          color: selected
                              ? AppTheme.greenPrimary
                              : AppTheme.lightText.withValues(alpha:0.5),
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          fontSize: selected ? 15 : 13,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(child: _screens[index]),
        ],
      ),
    );
  }
}

class LearnByMode extends StatelessWidget {
  const LearnByMode({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        LearnModeCard(
          co: AppTheme.meanFuse,
          line: "Mean Fuse",
          onTap: () => context.push('/learn/mode', extra: StudyMode.meanfuse),
          aPath: "assets/illumode/fitness-1-44.png",
        ),
        LearnModeCard(
          co: AppTheme.wordSnap,
          line: "Word Snap",
          onTap: () => context.push('/learn/mode', extra: StudyMode.wordsnap),
          aPath: "assets/illumode/surfing-91.png",
        ),
        LearnModeCard(
          co: AppTheme.mindField,
          line: "Mind Field",
          onTap: () => context.push('/learn/mode', extra: StudyMode.mindField),
          aPath: "assets/illumode/baseball-22.png",
        ),
        LearnModeCard(
          co: AppTheme.echoSpell,
          line: "Echo Spell",
          onTap: () => context.push('/learn/mode', extra: StudyMode.echoSpell),
          aPath: "assets/illumode/coach-82.png",
        ),
        LearnModeCard(
          co: AppTheme.echoMatch,
          line: "Echo Match",
          onTap: () => context.push('/learn/mode', extra: StudyMode.echoMatch),
          aPath: "assets/illumode/diving-71.png",
        ),
        LearnModeCard(
          co: AppTheme.echoFuse,
          line: "Echo Fuse",
          onTap: () => context.push('/learn/mode', extra: StudyMode.echofuse),
          aPath: "assets/illumode/soccer-64.png",
        ),
        LearnModeCard(
          co: AppTheme.neuroPick,
          line: "Neuro Pick",
          onTap: () => context.push('/learn/mode', extra: StudyMode.neuropick),
          aPath: "assets/illumode/parachute-11.png",
        ),
        LearnModeCard(
          co: AppTheme.wordPulse,
          line: "Word Pulse",
          onTap: () => context.push('/learn/mode', extra: StudyMode.wordpulse),
          aPath: "assets/illumode/video-call-1-72.png",
        ),
        LearnModeCard(
          co: AppTheme.soundSight,
          line: "Sound and Sight",
          onTap: () => context.push('/learn/mode', extra: StudyMode.soundAndSight),
          aPath: "assets/illumode/fitness-99.png",
        ),
        LearnModeCard(
          co: AppTheme.phoneMix,
          line: "Phonemix",
          onTap: () => context.push('/learn/mode', extra: StudyMode.phonemix),
          aPath: "assets/illumode/rocket-launch-59.png",
        ),
      ],
    );
  }
}

class LevelLearnScreenNav extends StatelessWidget {
  const LevelLearnScreenNav({super.key});

  static const List<Map<String, dynamic>> _levels = [
    {"level": 1, "co": Color(0xFF7A4A21), "path": "assets/illumode/global-warming-68.png"},
    {"level": 2, "co": Color(0xFF4D4DBB), "path": "assets/illumode/global-warming-2-100.png"},
    {"level": 3, "co": Color(0xFFAA7A13), "path": "assets/illumode/global-warming-4.png"},
    {"level": 4, "co": Color(0xFF7094FF), "path": "assets/illumode/global-warming-2-30.png"},
    {"level": 5, "co": Color(0xFF0F6F82), "path": "assets/illumode/global-warming-1-5.png"},
    {"level": 6, "co": Color(0xFFA01717), "path": "assets/illumode/global-warming-2-50.png"},
    {"level": 7, "co": Color(0xFF351A6E), "path": "assets/illumode/global-warming-76.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _levels.length,
      itemBuilder: (context, i) {
        return LearnModeCard(
          co: _levels[i]["co"],
          line: "Level ${_levels[i]["level"]}",
          onTap: () => context.push('/learn/level/${_levels[i]["level"]}'),
          aPath: _levels[i]["path"],
        );
      },
    );
  }
}

class DailyLearnScreenNav extends StatelessWidget {
  const DailyLearnScreenNav({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        LearnModeCard(
          co: AppTheme.greenAccent,
          line: "DAILY LEARN",
          onTap: () => context.push('/learn/lesson', extra: LearnMode.daily),
          aPath: "assets/illumode/school-75.png",
        ),
        LearnModeCard(
          co: AppTheme.yellowAccent,
          line: "Super Memo 2",
          onTap: () => context.push('/learn/lesson', extra: LearnMode.sm),
          aPath: "assets/illumode/team-brainstorming-5-1.png",
        ),
        LearnModeCard(
          co: AppTheme.pinkPrimary,
          line: "ALL MODE",
          onTap: () => context.push('/learn/lesson', extra: LearnMode.all),
          aPath: "assets/illumode/super-dad-28.png",
        ),
        LearnModeCard(
          co: AppTheme.bluePrimary,
          line: "SHUFFLE MODE",
          onTap: () => context.push('/learn/lesson', extra: LearnMode.shuffle),
          aPath: "assets/illumode/twitter-66.png",
        ),
      ],
    );
  }
}

class LearnModeCard extends StatelessWidget {
  const LearnModeCard({
    super.key,
    required this.co,
    required this.line,
    required this.onTap,
    required this.aPath,
  });

  final Color co;
  final String line;
  final VoidCallback onTap;
  final String aPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 120,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: co,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (aPath.isNotEmpty)
                Positioned(
                  right: -20,
                  top: -20,
                  bottom: -20,
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      aPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    line.toUpperCase(),
                    style: AppTheme.sectionHeaderStyle.copyWith(
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [
                        const Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


