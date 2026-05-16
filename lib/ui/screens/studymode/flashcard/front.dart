import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'newwayreview.dart';

class FrontSide extends StatelessWidget {
  const FrontSide({super.key, required this.widget});

  final FlashCardItem widget;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: AppTheme.darkCard,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.darkBorder, width: 2),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              widget.card?.word ?? '',
              style: AppTheme.heroStyle.copyWith(
                color: AppTheme.bluePrimary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}


