import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notifier/penpal_notifier.dart';
import 'ui/penpal_screen.dart';

class Penpal extends StatelessWidget {
  const Penpal({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PenpalNotifier(),
      child: const PenpalScreen(),
    );
  }
}