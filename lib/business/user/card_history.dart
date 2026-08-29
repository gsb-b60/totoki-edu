class CardHistory {
  final int? id;
  final String userId;
  final int cardId;
  final bool success;

  CardHistory({
    this.id,
    required this.userId,
    required this.cardId,
    required this.success,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'card_id': cardId,
      'success': success ? 1 : 0,
    };
  }

  factory CardHistory.fromMap(Map<String, dynamic> map) {
    return CardHistory(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      cardId: map['card_id'] as int,
      success: (map['success'] as int) == 1,
    );
  }
}