import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/business/path_service.dart';
import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

class BackSide extends StatefulWidget {
  final Flashcard card;
  final String? media;
  const BackSide({super.key, required this.card, required this.media});

  @override
  State<BackSide> createState() => BackSideState();
}

class BackSideState extends State<BackSide> {
  final AudioPlayer _audio = AudioPlayer();

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  void playSound(String media, String path) async {
    String soundPath = PathService.getFilePath(media, path);
    try {
      await _audio.play(DeviceFileSource(soundPath));
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dir = PathService.getDeckMediaPath(widget.media!);
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: AppTheme.darkCard,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.darkBorder, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Section
                if (widget.card.img != null)
                  SizedBox(
                    height: 200,
                    child: Image.file(
                      File('$dir/${widget.card.img}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Word & IPA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              widget.card.word ?? '',
                              style: AppTheme.sectionHeaderStyle.copyWith(
                                color: AppTheme.bluePrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          ),
                          if (widget.card.ipa != null)
                            Text(
                              "/${widget.card.ipa!}/",
                              style: AppTheme.bodySmallStyle.copyWith(
                                color: AppTheme.lightText.withValues(alpha:0.6),
                                fontStyle: FontStyle.italic,
                                fontSize: 18,
                              ),
                            ),
                        ],
                      ),
                      const Divider(color: AppTheme.darkBorder, height: 32),

                      // Meaning
                      if (widget.card.meaning != null) ...[
                        Text(
                          "MEANING",
                          style: AppTheme.bodySmallStyle.copyWith(
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.card.meaning ?? '',
                          style: AppTheme.bodyLargeStyle.copyWith(
                            color: AppTheme.lightText,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Example
                      if (widget.card.example != null && widget.card.example != "") ...[
                        Text(
                          "EXAMPLE",
                          style: AppTheme.bodySmallStyle.copyWith(
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.card.example ?? '',
                          style: AppTheme.bodyMediumStyle.copyWith(
                            color: AppTheme.lightText.withValues(alpha:0.9),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Sound Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (widget.card.sound != null)
                            _SoundButton(
                              icon: Icons.volume_up,
                              label: "Word",
                              onPressed: () => playSound(widget.media!, widget.card.sound!),
                            ),
                          if (widget.card.usageSound != null)
                            _SoundButton(
                              icon: Icons.play_circle_outline,
                              label: "Usage",
                              onPressed: () => playSound(widget.media!, widget.card.usageSound!),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SoundButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon, color: AppTheme.bluePrimary),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.darkSurface,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmallStyle.copyWith(
            color: AppTheme.lightText.withValues(alpha:0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}




