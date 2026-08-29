import 'dart:convert';
import 'package:uuid/uuid.dart';

class SeedDataGenerator {
  static List<User> generateSampleUsers() {
    return [
      User(
        id: Uuid().v4(),
        createdAt: DateTime(2024, 1, 15),
        name: 'Hải',
        avatarUrl: 'https://example.com/avatar1.jpg',
        email: 'hai@example.com',
        phoneNumber: '+84901234567',
      ),
      User(
        id: Uuid().v4(),
        createdAt: DateTime(2024, 2, 10),
        name: 'Lan',
        avatarUrl: 'https://example.com/avatar2.jpg',
        email: 'lan@example.com',
        phoneNumber: '+84909876543',
      ),
      User(
        id: Uuid().v4(),
        createdAt: DateTime(2024, 3, 5),
        name: 'Minh',
        avatarUrl: 'https://example.com/avatar3.jpg',
        email: 'minh@example.com',
        phoneNumber: '+84905555555',
      ),
    ];
  }

  static List<HistoryLesson> generateSampleLessons() {
    final lessonTypes = LessonType.values;
    final users = generateSampleUsers();
    final List<HistoryLesson> lessons = [];

    // Generate 3 months of data (approx 90 days)
    for (int i = 0; i < 90; i++) {
      final random = Random();
      final user = users[random.nextInt(users.length)];
      
      for (final type in lessonTypes) {
        final minutesSpent = random.nextInt(60) + 10; // 10-70 minutes
        final accuracy = random.nextInt(100); // 0-99%
        
        lessons.add(HistoryLesson(
          id: Uuid().v4(),
          userId: user.id,
          lessonType: type,
          accuracy: accuracy.toInt(),
          timeSpent: minutesSpent.toInt(),
        ));
      }
    }
    return lessons;
  }

  static List<CardHistory> generateSampleCardHistory() {
    final users = generateSampleUsers();
    final List<CardHistory> histories = [];
    
    // Generate 200 card history entries
    for (int i = 0; i < 200; i++) {
      final user = users[Random().nextInt(generateSampleUsers().length)];
      final cardId = Random().nextInt(1000) + 1;
      final success = Random().nextDouble() > 0.7; // 70% success rate
      
      histories.add(CardHistory(
        id: Uuid().v4(),
        userId: user.id,
        cardId: cardId,
        success: success,
      ));
    }
    return histories;
  }

  static List<DailyUsage> generateSampleDailyUsage() {
    final users = generateSampleUsers();
    final List<DailyUsage> usages = [];
    
    // Generate 6 months of data (approx 180 days)
    final now = DateTime.now();
    for (int i = 0; i < 180; i++) {
      final date = now.subtract(Duration(days: i));
      final user = users[Random().nextInt(generateSampleUsers().length)];
      
      final amount = Random().nextInt(50) + 1; // 1-50
      
      usages.add(DailyUsage(
        userId: user.id,
        date: '${date.day}/${date.month}/${date.year}',
        amount: amount,
      ));
    }
    return usages;
  }
}

// Sample User class
class User {
  final String id;
  final DateTime createdAt;
  final String? name;
  final String? avatarUrl;
  final String? email;
  final String? phoneNumber;

  User({
    required this.id,
    required this.createdAt,
    this.name,
    this.avatarUrl,
    this.email,
    this.phoneNumber,
  });
}

// Sample HistoryLesson class
class HistoryLesson {
  final String? id;
  final String userId;
  final LessonType lessonType;
  final int? accuracy;
  final int? timeSpent;

  HistoryLesson({
    this.id,
    required this.userId,
    required this.lessonType,
    this.accuracy,
    this.timeSpent,
  });
}

// Sample CardHistory class
class CardHistory {
  final String? id;
  final String userId;
  final int cardId;
  final bool success;

  CardHistory({
    this.id,
    required this.userId,
    required this.cardId,
    required this.success,
  });
}

// Sample DailyUsage class
class DailyUsage {
  final String userId;
  final String date; // dd/MM/yyyy
  final int amount;

  DailyUsage({
    required this.userId,
    required this.date,
    required this.amount,
  });
}