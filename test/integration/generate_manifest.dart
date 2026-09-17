import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

Future<void> main() async {
  final manifest = <String, dynamic>{};

  for (int seriesId = 1; seriesId <= 19; seriesId++) {
    for (int testId = 1; testId <= 3; testId++) {
      for (int part = 1; part <= 2; part++) {
        final id = '$seriesId-$testId-$part';
        final questionPath = 'assets/ielts/question/$id.json';

        if (!File(questionPath).existsSync()) continue;

        final questionJson = File(questionPath).readAsStringSync();
        final questionData = jsonDecode(questionJson) as Map<String, dynamic>;
        final qList = questionData['test_question'] as List? ?? [];

        if (qList.isEmpty) continue;

        final expectedQuestions = <int>[];
        for (int i = 0; i < qList.length; i++) {
          final group = qList[i] as Map<String, dynamic>;
          final body = group['body'] as Map<String, dynamic>? ?? {};
          final items = body['items'] as List? ?? [];
          int count = _countValidQuestions(items, group['type'] as String? ?? '');
          expectedQuestions.add(count);
        }

        manifest[id] = {
          'groups': qList.length,
          'expectedQuestions': expectedQuestions,
        };
        debugPrint('$id: ${qList.length} groups, questions: $expectedQuestions');
      }
    }
  }

  final outputPath = 'test/integration/fixtures/test_manifest.json';
  final outputFile = File(outputPath);
  outputFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(manifest));
  debugPrint('Manifest written to $outputPath');
}

int _countValidQuestions(List items, String type) {
  int count = 0;
  
  for (final item in items) {
    if (item is Map && item['type'] == 'example') continue;
    
    if (item is String) {
      if (item.contains('<input')) count++;
    } else if (item is List) {
      for (final sub in item) {
        if (sub is String && sub.contains('<input')) count++;
      }
    } else if (item is Map) {
      final title = item['title'] as String? ?? '';
      final prefix = item['prefix'] as String? ?? '';
      if (title.contains('<input') || prefix.contains('<input')) count++;
      
      final subItems = item['items'] as List? ?? [];
      for (final sub in subItems) {
        if (sub is String && sub.contains('<input')) count++;
      }
    }
  }
  
  return count;
}