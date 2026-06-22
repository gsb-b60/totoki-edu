import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';

class IeltsTraining extends StatelessWidget {
  const IeltsTraining({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.darkBase,
      child: const Center(
        child: Text(
          'IELTS Training',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
