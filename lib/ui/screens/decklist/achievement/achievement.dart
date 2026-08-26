import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/decklist/achievement/achievementNoti.dart';
import 'package:totoki_extract/ui/screens/decklist/achievement/achievementUI.dart';
import 'package:provider/provider.dart';

class Achievement extends StatelessWidget {
  const Achievement({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Achievementnoti()..fetchCard(),
      child: AchievementUI(),
    );
  }
}

