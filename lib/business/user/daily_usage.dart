class DailyUsage {
  final int? id;
  final String userId;
  final String date;
  final int amount;

  DailyUsage({
    this.id,
    required this.userId,
    required this.date,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'date': date,
      'amount': amount,
    };
  }

  factory DailyUsage.fromMap(Map<String, dynamic> map) {
    return DailyUsage(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      date: map['date'] as String,
      amount: map['amount'] as int,
    );
  }
}