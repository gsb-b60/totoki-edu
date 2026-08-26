import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totoki_extract/features/ielts/parsers/reading_passage_parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Parse all IELTS test combinations and report failures', () async {
    final failures = <FailureDetail>[];
    int total = 0, passed = 0;

    for (int seriesId = 1; seriesId <= 19; seriesId++) {
      for (int testId = 1; testId <= 3; testId++) {
        for (int part = 1; part <= 2; part++) {
          final testPath = 'assets/ielts/test/$seriesId-$testId-$part.json';
          final questionPath = 'assets/ielts/question/$seriesId-$testId-$part.json';

          try {
            await rootBundle.loadString(testPath);
          } catch (_) {
            continue;
          }

          int maxGroup = 3;
          try {
            final questionJson = await rootBundle.loadString(questionPath);
            final questionData = jsonDecode(questionJson) as Map<String, dynamic>;
            final qList = questionData['test_question'] as List? ?? [];
            maxGroup = qList.length;
          } catch (_) {
            maxGroup = 3;
          }

          for (int questionGroup = 1; questionGroup <= maxGroup; questionGroup++) {
            total++;
            try {
              final result = await ReadingPassageParser.parse(
                seriesId: seriesId,
                testId: testId,
                part: part,
                questionGroup: questionGroup,
              );
              if (result.questions.isEmpty) {
                failures.add(FailureDetail(
                  seriesId,
                  testId,
                  part,
                  questionGroup,
                  'Empty questions list',
                  FailureType.emptyQuestions,
                ));
              } else {
                passed++;
              }
            } on ReadingPassageException catch (e) {
              final type = e.message.contains('out of range')
                  ? FailureType.outOfRange
                  : FailureType.parserException;
              failures.add(FailureDetail(
                seriesId,
                testId,
                part,
                questionGroup,
                e.message,
                type,
              ));
            } catch (e, st) {
              failures.add(FailureDetail(
                seriesId,
                testId,
                part,
                questionGroup,
                '$e\n$st',
                FailureType.other,
              ));
            }
          }
        }
      }
    }

    final byType = <FailureType, int>{};
    for (final f in failures) {
      byType[f.type] = (byType[f.type] ?? 0) + 1;
    }

    print('=== IELTS Parsing Test Summary ===');
    print('Total: $total | Passed: $passed | Failed: ${failures.length}');
    print('By type: ${byType.entries.map((e) => '${e.key}=${e.value}').join(', ')}');
    print('');

    for (final f in failures) {
      print('FAIL: ${f.seriesId}-${f.testId}-${f.part} (qGroup ${f.questionGroup}) [${f.type}]');
      print('  ${f.error.replaceAll('\n', '\n  ')}');
      print('');
    }
  });
}

enum FailureType { outOfRange, emptyQuestions, parserException, other }

class FailureDetail {
  final int seriesId, testId, part, questionGroup;
  final String error;
  final FailureType type;
  FailureDetail(this.seriesId, this.testId, this.part, this.questionGroup, this.error, this.type);
}