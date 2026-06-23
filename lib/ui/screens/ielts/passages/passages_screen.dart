import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/noti/readingNoti.dart';
import 'package:totoki_extract/widget/reviewScreen.dart';
import 'package:flutter/gestures.dart';

class PassagesScreen extends StatefulWidget {
  const PassagesScreen({super.key});

  @override
  State<PassagesScreen> createState() => _PassagesScreenState();
}

class _PassagesScreenState extends State<PassagesScreen> {
  int _currentQ = 0;
  int? _selected;
  bool _answered = false;
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

  List<InlineSpan> _buildArticleSpans(ReadingNoti noti) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final spans = <InlineSpan>[];
    final wordRegex = RegExp(r"[A-Za-z]+(?:[''][A-Za-z]+)*");
    int lastEnd = 0;
    for (final match in wordRegex.allMatches(noti.articleText)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: noti.articleText.substring(lastEnd, match.start)));
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
    if (lastEnd < noti.articleText.length) {
      spans.add(TextSpan(text: noti.articleText.substring(lastEnd)));
    }
    return spans;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReadingNoti>().loadPassage();
    });
  }

  void _submit() {
    if (_selected == null) return;
    setState(() => _answered = true);
  }

  void _next() {
    final noti = context.read<ReadingNoti>();
    if (_currentQ < noti.questions.length - 1) {
      setState(() {
        _currentQ++;
        _selected = null;
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final noti = context.watch<ReadingNoti>();

    if (noti.isLoading || noti.articleText.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.darkBase,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Reading", style: AppTheme.screenTitleStyle),
          backgroundColor: AppTheme.darkBase,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final q = noti.questions[_currentQ];
    final correct = _selected == q["answer"];

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Reading", style: AppTheme.screenTitleStyle),
        backgroundColor: AppTheme.darkBase,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.darkBorder, width: 2),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              noti.title,
                              style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            RichText(
                              text: TextSpan(
                                style: AppTheme.bodyLargeStyle.copyWith(height: 1.6),
                                children: _buildArticleSpans(noti),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.darkBorder, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Question ${_currentQ + 1}/${noti.questions.length}",
                            style: AppTheme.captionStyle.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            q["q"] as String,
                            style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView(
                              children: List.generate(
                                (q["options"] as List<String>).length,
                                (i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _OptionBtn(
                                    label: (q["options"] as List<String>)[i],
                                    isSelected: _selected == i,
                                    onTap: _answered ? null : () => setState(() => _selected = i),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!_answered)
                            GestureDetector(
                              onTap: _selected != null ? _submit : null,
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: _selected != null ? AppTheme.greenPrimary : AppTheme.darkCard,
                                  boxShadow: _selected != null
                                      ? [BoxShadow(color: AppTheme.greenPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    "SUBMIT ANSWER",
                                    style: AppTheme.bodyLargeStyle.copyWith(
                                      color: _selected != null ? AppTheme.darkBase : AppTheme.lightText.withOpacity(0.5),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              bottom: _answered ? 0 : -MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: ReviewScreen(
                right: correct,
                answer: (q["options"] as List<String>)[q["answer"] as int],
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _OptionBtn({required this.label, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: isSelected ? AppTheme.greenPrimary : AppTheme.darkBorder, width: 2),
          backgroundColor: isSelected ? AppTheme.darkCard : AppTheme.darkSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          label,
          style: AppTheme.bodyLargeStyle.copyWith(
            color: isSelected ? AppTheme.greenPrimary : AppTheme.lightText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
