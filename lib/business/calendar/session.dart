class Session {
  final int? id;
  final String date;
  final int cardsStudied;
  final int correctCount;
  final int wrongCount;
  final int durationSeconds;
  final double accuracy;
  final int? deckId;
  final String? studyMode;
  final DateTime? createdAt;

  Session({
    this.id,
    required this.date,
    required this.cardsStudied,
    required this.correctCount,
    required this.wrongCount,
    required this.durationSeconds,
    required this.accuracy,
    this.deckId,
    this.studyMode,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'cards_studied': cardsStudied,
      'correct_count': correctCount,
      'wrong_count': wrongCount,
      'duration_seconds': durationSeconds,
      'accuracy': accuracy,
      'deck_id': deckId,
      'study_mode': studyMode,
      'created_at': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as int?,
      date: map['date'] as String,
      cardsStudied: map['cards_studied'] as int? ?? 0,
      correctCount: map['correct_count'] as int? ?? 0,
      wrongCount: map['wrong_count'] as int? ?? 0,
      durationSeconds: map['duration_seconds'] as int? ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
      deckId: map['deck_id'] as int?,
      studyMode: map['study_mode'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
    );
  }
}
