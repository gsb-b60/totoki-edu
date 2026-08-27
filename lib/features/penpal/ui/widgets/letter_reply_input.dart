import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class LetterReplyInput extends StatefulWidget {
  final List<String> keywords;
  final Function(String) onSubmit;
  final int attemptsRemaining;
  final int maxAttempts;

  const LetterReplyInput({
    super.key,
    required this.keywords,
    required this.onSubmit,
    required this.attemptsRemaining,
    required this.maxAttempts,
  });

  @override
  State<LetterReplyInput> createState() => _LetterReplyInputState();
}

class _LetterReplyInputState extends State<LetterReplyInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Map<String, bool> _checkKeywords(String text) {
    final lowerText = text.toLowerCase();
    return {
      for (final keyword in widget.keywords)
        keyword: lowerText.contains(keyword.toLowerCase()),
    };
  }

  @override
  Widget build(BuildContext context) {
    final keywordStatus = _checkKeywords(_controller.text);
    final allKeywordsFound = keywordStatus.values.every((v) => v);
    final hasMinLength = _controller.text.trim().length >= 150;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(
          top: BorderSide(color: AppTheme.darkBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Penning your letter...',
                style: AppTheme.captionStyle.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Attempt ${widget.maxAttempts - widget.attemptsRemaining + 1}/${widget.maxAttempts}',
                style: AppTheme.captionStyle.copyWith(color: AppTheme.sciSpark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 6,
            minLines: 3,
            style: AppTheme.bodyMediumStyle.copyWith(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Dear Penpal, here are my deep reflections...',
              hintStyle: AppTheme.bodyMediumStyle.copyWith(
                color: Colors.white.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: AppTheme.darkBase,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text(
            'Incorporate these deep concepts in your letter:',
            style: AppTheme.captionStyle.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.keywords.map((keyword) {
              final found = keywordStatus[keyword] ?? false;
              return Chip(
                label: Text(
                  keyword,
                  style: AppTheme.captionStyle.copyWith(
                    color: found ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    fontWeight: found ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                backgroundColor: found
                    ? AppTheme.greenPrimary.withValues(alpha: 0.3)
                    : AppTheme.darkBorder.withValues(alpha: 0.3),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (allKeywordsFound && hasMinLength)
                  ? () {
                      widget.onSubmit(_controller.text);
                      _controller.clear();
                      setState(() {});
                    }
                  : null,
              icon: const Icon(Icons.send, size: 16),
              label: Text(
                'Mail Reply',
                style: AppTheme.bodyMediumStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.sciSpark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: AppTheme.darkBorder.withValues(alpha: 0.3),
              ),
            ),
          ),
          if (!hasMinLength)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Minimum 150 characters required (currently ${_controller.text.trim().length})',
                style: AppTheme.captionStyle.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}