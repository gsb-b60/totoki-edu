import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import '../../models/penpal_message.dart';

class LetterView extends StatelessWidget {
  final PenpalMessage message;
  final String senderName;

  const LetterView({
    super.key,
    required this.message,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final paperColor = isUser ? const Color(0xFF2A2E3D) : const Color(0xFFF7F2E8);
    final textColor = isUser ? Colors.white : const Color(0xFF2C1A04);
    final stampColor = isUser ? AppTheme.sciSpark : const Color(0xFF8B4513);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isUser
            ? Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1)
            : Border.all(color: const Color(0xFFE5D5C5), width: 1.5),
      ),
      child: Stack(
        children: [
          // Letter Lines Background (for non-user letters)
          if (!isUser)
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(
                  painter: _LinedPaperPainter(),
                ),
              ),
            ),
          // Postmark Stamp Design
          Positioned(
            top: 16,
            right: 16,
            child: Opacity(
              opacity: 0.7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: stampColor, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isUser ? 'REPLY' : 'POST',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: stampColor,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'To: $senderName' : 'From: $senderName',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.white70 : const Color(0xFF6B4E3D),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: textColor,
                    fontFamily: isUser ? 'sans-serif' : 'serif',
                    fontStyle: isUser ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _formatDate(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: isUser ? Colors.white38 : const Color(0xFF8B7365),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    double y = 40.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += 24.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}