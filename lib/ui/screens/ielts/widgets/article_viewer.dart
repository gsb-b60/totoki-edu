import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/features/ielts/notifier/reading_notifier.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/picture_viewer.dart';

class ArticleViewer extends StatefulWidget {
  final ReadingNoti noti;

  const ArticleViewer({super.key, required this.noti});

  @override
  State<ArticleViewer> createState() => _ArticleViewerState();
}

class _ArticleViewerState extends State<ArticleViewer> {
  final List<TapGestureRecognizer> _recognizers = [];
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showWordDefinition(String word, String definition, Offset globalPosition) {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    const popupWidth = 280.0;
    const popupHeight = 120.0;

    double dx = globalPosition.dx - popupWidth / 2;
    double dy = globalPosition.dy + 20;
    if (dx < 12) dx = 12;
    if (dx + popupWidth > screenSize.width - 12) {
      dx = screenSize.width - popupWidth - 12;
    }
    if (dy + popupHeight > screenSize.height - 12) {
      dy = globalPosition.dy - popupHeight - 10;
    }
    if (dy < 12) dy = 12;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Container(color: Colors.transparent),
            Positioned(
              left: dx,
              top: dy,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.darkSurface,
                child: GestureDetector(
                  onTap: _removeOverlay,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: popupWidth),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          word,
                          style: AppTheme.bodyLargeStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          definition,
                          style: AppTheme.bodyLargeStyle.copyWith(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  List<InlineSpan> _buildArticleSpans(String text) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final spans = <InlineSpan>[];
    final wordRegex = RegExp(r"[A-Za-z]+(?:[''][A-Za-z]+)*");
    int lastEnd = 0;
    final noti = widget.noti;
    for (final match in wordRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      final word = match.group(0)!;
      final recognizer = TapGestureRecognizer()
        ..onTapUp = (details) {
          final def = noti.lookupWord(word);
          if (def != null) {
            _showWordDefinition(word, def, details.globalPosition);
          }
        };
      _recognizers.add(recognizer);
      spans.add(TextSpan(
        text: word,
        recognizer: recognizer,
        style: const TextStyle(decoration: TextDecoration.underline, decorationColor: AppTheme.greenPrimary, decorationThickness: 0.5),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final noti = widget.noti;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            noti.title,
            style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...noti.articleFragments.map((fragment) {
            if (fragment.type == "text") {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.bodyLargeStyle.copyWith(height: 1.6),
                    children: _buildArticleSpans(fragment.text!),
                  ),
                ),
              );
            } 
            else if (fragment.type == "heading") {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 8),
                child: Text(
                  fragment.text!,
                  style: AppTheme.sectionHeaderStyle.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            } 
            else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PictureViewer(imageAssetPath: fragment.imageAssetPath!),
              );
            }
          }),
        ],
      ),
    );
  }
}
