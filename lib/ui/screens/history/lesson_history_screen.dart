import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/business/user/history_lesson.dart';
import 'package:totoki_extract/business/user/lesson_type.dart';
import 'package:totoki_extract/features/user/lesson_history_notifier.dart';
import 'package:totoki_extract/features/user/user_notifier.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class LessonHistoryScreen extends StatefulWidget {
  const LessonHistoryScreen({super.key});

  @override
  State<LessonHistoryScreen> createState() => _LessonHistoryScreenState();
}

class _LessonHistoryScreenState extends State<LessonHistoryScreen> {
  late final LessonHistoryNotifier _historyNotifier;
  List<HistoryLesson> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _historyNotifier = LessonHistoryNotifier();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);
    final userId = userNotifier.user?.id ?? '';

    if (userId.isNotEmpty) {
      final history = await _historyNotifier.getHistoryLessons(userId);
      if (mounted) {
        setState(() {
          _historyList = history;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDetailModal(HistoryLesson lesson) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lesson Detail',
                style: AppTheme.sectionHeaderStyle.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('ID', '${lesson.id ?? "N/A"}'),
              _buildDetailRow('User ID', lesson.userId),
              _buildDetailRow('Lesson Type', lesson.lessonType.toString()),
              _buildDetailRow('Accuracy', lesson.accuracy != null ? '${lesson.accuracy}%' : 'N/A'),
              _buildDetailRow('Time Spent', lesson.timeSpent != null ? '${lesson.timeSpent}s' : 'N/A'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.greenPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.lightText)),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBase,
        title: const Text('Lesson History', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyList.isEmpty
              ? const Center(
                  child: Text(
                    'No lesson history found',
                    style: TextStyle(color: AppTheme.lightText),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _historyList.length,
                  itemBuilder: (context, index) {
                    final item = _historyList[index];
                    return Card(
                      color: AppTheme.darkSurface,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.greenPrimary,
                          child: Icon(
                            _getLessonIcon(item.lessonType),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          item.lessonType.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Accuracy: ${item.accuracy ?? 0}% | Time: ${item.timeSpent ?? 0}s',
                          style: const TextStyle(color: AppTheme.lightText),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppTheme.lightText,
                        ),
                        onTap: () => _showDetailModal(item),
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getLessonIcon(LessonType type) {
    return switch (type) {
      LessonType.dailyLearn => Icons.bolt,
      LessonType.ielts => Icons.language,
    };
  }
}
