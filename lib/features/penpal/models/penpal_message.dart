class PenpalMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const PenpalMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}