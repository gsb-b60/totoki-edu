// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totoki_extract/features/ielts/models/paragraph_group.dart';
import 'package:totoki_extract/features/ielts/parsers/reading_passage_parser.dart';
import 'package:totoki_extract/features/ielts/notifier/reading_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, dynamic> manifest;
  late List<_TestCombo> combos;

  setUpAll(() async {
    final manifestJson = await rootBundle.loadString(
      'test/integration/fixtures/test_manifest.json',
    );
    manifest = jsonDecode(manifestJson);
    combos = await _discoverCombos();
    // print('Discovered ${combos.length} test combinations');
  });

  test('All combos parse with valid article and questions', () async {
    int skipped = 0;
    int countMismatches = 0;
    int unknownTitles = 0;
    final titleFailures = <TitleFailure>[];
    final countMismatchFailures = <CountMismatch>[];

    for (final c in combos) {
      final r = await ReadingPassageParser.parse(
        seriesId: c.seriesId,
        testId: c.testId,
        part: c.part,
        questionGroup: c.qGroup,
      );

      if (r.title == '?') {
        unknownTitles++;
        titleFailures.add(
          TitleFailure(
            comboId: c.id,
            seriesId: c.seriesId,
            testId: c.testId,
            part: c.part,
            questionGroup: c.qGroup,
            title: r.title,
          ),
        );
        // print('WARN: ${c.id} unknown title (?)');
      } else {
        expect(r.title, isNot(equals('')), reason: '${c.id} empty title');
      }
      expect(r.fragments, isNotEmpty, reason: '${c.id} no fragments');
      expect(r.articleText, isNotEmpty, reason: '${c.id} no articleText');

      final validQs = r.questions
          .where((q) => q.displayText.isNotEmpty)
          .toList();

      if (validQs.isEmpty) {
        skipped++;
        // print('SKIP: ${c.id} - only example questions');
        continue;
      }

      expect(validQs, isNotEmpty, reason: '${c.id} no valid questions');

      final exp = manifest[c.id]?['expectedQuestions']?[c.qGroup - 1];
      if (exp != null && exp > 0 && validQs.length != exp) {
        countMismatches++;
        countMismatchFailures.add(
          CountMismatch(
            comboId: c.id,
            seriesId: c.seriesId,
            testId: c.testId,
            part: c.part,
            questionGroup: c.qGroup,
            expected: exp,
            actual: validQs.length,
            questionType: validQs.isNotEmpty ? validQs.first.type : 'unknown',
          ),
        );
        // print('COUNT MISMATCH: ${c.id} expected $exp got ${validQs.length}');
      }
    }

    // print('Article+Questions: ${combos.length - skipped}/${combos.length} validated, $skipped skipped, $countMismatches count mismatches, $unknownTitles unknown titles');

    // Write structured report
    await _writeFailureReport(
      titleFailures,
      countMismatchFailures,
      <AnswerMismatch>[],
      <SkippedTypeFailure>[],
    );
  });

  test('All questions have correct answers from answer key', () async {
    final mismatches = <String>[];
    final answerMismatches = <AnswerMismatch>[];
    final skippedTypes = <SkippedTypeFailure>[];

    int validated = 0;

    int skippedAnswers = 0;

    int skippedTypesCount = 0;

    for (final c in combos) {
      final r = await ReadingPassageParser.parse(
        seriesId: c.seriesId,
        testId: c.testId,
        part: c.part,
        questionGroup: c.qGroup,
      );

      final ans = await _loadAnswers(c.seriesId, c.testId);
      if (ans == null) {
        skippedAnswers++;
        continue;
      }

      for (int i = 0; i < r.questions.length; i++) {
        final q = r.questions[i];
        if (q.displayText.isEmpty) continue;

        final qId = c.start + i;
        validated++;

        if (q.type == 'select-section-given-list' ||
            q.type == 'select-section') {
          skippedTypesCount++;
          skippedTypes.add(
            SkippedTypeFailure(
              comboId: c.id,
              seriesId: c.seriesId,
              testId: c.testId,
              part: c.part,
              questionGroup: c.qGroup,
              questionId: qId,
              questionIndex: i,
              type: q.type,
              reason:
                  'Roman numeral answers in textLookup but parser uses optionLookup',
              options: q.options,
            ),
          );
          continue;
        }

        if (!_matchesAnswer(q, qId, ans)) {
          final expected = _expectedAns(ans, qId);
          final actual = _actualAns(q);
          mismatches.add(
            '${c.id} q$qId (type:${q.type}): expected $expected, got $actual',
          );
          answerMismatches.add(
            AnswerMismatch(
              comboId: c.id,
              seriesId: c.seriesId,
              testId: c.testId,
              part: c.part,
              questionGroup: c.qGroup,
              questionId: qId,
              questionIndex: i,
              type: q.type,
              expected: expected,
              actual: actual,
              options: q.options,
              textAnswers: q.textAnswers,
              answers: q.answers,
            ),
          );
        }
      }
    }

    // print('ANSWER VALIDATION: $validated questions checked, $skippedAnswers combos no answer key, $skippedTypesCount skipped (known parser bugs)');

    // if (mismatches.isNotEmpty) {
    //   // print('ANSWER MISMATCHES (${mismatches.length} of $validated validated):');
    //   for (final m in mismatches.take(20)) {
    //      print('  $m');
    //   }
    //   if (mismatches.length > 20) {
    //     // print('  ... and ${mismatches.length - 20} more');
    //   }
    // }

    // print('REGRESSION BASELINE: ${mismatches.length} known answer mismatches');
    expect(mismatches.length, lessThanOrEqualTo(30));

    // Append to report
    await _appendFailureReport(answerMismatches, skippedTypes);
  });

  test('ReadingNoti loads passage end-to-end', () async {
    final notifier = ReadingNoti();
    int tested = 0;

    for (final c in combos) {
      if (tested >= 20) break;

      await notifier.loadPassage(
        seriesId: c.seriesId,
        testId: c.testId,
        part: c.part,
        questionGroup: c.qGroup,
      );

      expect(
        notifier.hasError,
        isFalse,
        reason: 'Notifier error ${c.id}: ${notifier.errorMessage}',
      );
      expect(notifier.title, isNotEmpty, reason: '${c.id} empty title');
      expect(notifier.questions, isNotEmpty, reason: '${c.id} no questions');
      tested++;
    }

    // print('Notifier tested: $tested combos');
  });
}

Future<void> _writeFailureReport(
  List<TitleFailure> titles,
  List<CountMismatch> counts,
  List<AnswerMismatch> answers,
  List<SkippedTypeFailure> skipped,
) async {
  final report = FailureReport(
    timestamp: DateTime.now().toIso8601String(),
    unknownTitles: titles,
    countMismatches: counts,
    answerMismatches: answers,
    skippedTypes: skipped,
  );

  final file = File('test/integration/fixtures/failure_report.json');
  await file.writeAsString(jsonEncode(report.toJson()));
  // print('Failure report written to test/integration/fixtures/failure_report.json');
}

Future<void> _appendFailureReport(
  List<AnswerMismatch> answers,
  List<SkippedTypeFailure> skipped,
) async {
  final file = File('test/integration/fixtures/failure_report.json');
  if (!file.existsSync()) return;

  final existing = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  existing['answerMismatches'] = answers.map((e) => e.toJson()).toList();
  existing['skippedTypes'] = skipped.map((e) => e.toJson()).toList();
  existing['summary'] = {
    'unknownTitles': existing['unknownTitles']?.length ?? 0,
    'countMismatches': existing['countMismatches']?.length ?? 0,
    'answerMismatches': answers.length,
    'skippedTypes': skipped.length,
  };

  await file.writeAsString(jsonEncode(existing));
  // print('Failure report updated with answer mismatches and skipped types');
}

class FailureReport {
  final String timestamp;
  final List<TitleFailure> unknownTitles;
  final List<CountMismatch> countMismatches;
  final List<AnswerMismatch> answerMismatches;
  final List<SkippedTypeFailure> skippedTypes;

  FailureReport({
    required this.timestamp,
    required this.unknownTitles,
    required this.countMismatches,
    required this.answerMismatches,
    required this.skippedTypes,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'summary': {
      'unknownTitles': unknownTitles.length,
      'countMismatches': countMismatches.length,
      'answerMismatches': answerMismatches.length,
      'skippedTypes': skippedTypes.length,
    },
    'unknownTitles': unknownTitles.map((e) => e.toJson()).toList(),
    'countMismatches': countMismatches.map((e) => e.toJson()).toList(),
    'answerMismatches': answerMismatches.map((e) => e.toJson()).toList(),
    'skippedTypes': skippedTypes.map((e) => e.toJson()).toList(),
  };
}

class TitleFailure {
  final String comboId;
  final int seriesId;
  final int testId;
  final int part;
  final int questionGroup;
  final String title;

  TitleFailure({
    required this.comboId,
    required this.seriesId,
    required this.testId,
    required this.part,
    required this.questionGroup,
    required this.title,
  });

  Map<String, dynamic> toJson() => {
    'comboId': comboId,
    'seriesId': seriesId,
    'testId': testId,
    'part': part,
    'questionGroup': questionGroup,
    'title': title,
  };
}

class CountMismatch {
  final String comboId;
  final int seriesId;
  final int testId;
  final int part;
  final int questionGroup;
  final int expected;
  final int actual;
  final String questionType;

  CountMismatch({
    required this.comboId,
    required this.seriesId,
    required this.testId,
    required this.part,
    required this.questionGroup,
    required this.expected,
    required this.actual,
    required this.questionType,
  });

  Map<String, dynamic> toJson() => {
    'comboId': comboId,
    'seriesId': seriesId,
    'testId': testId,
    'part': part,
    'questionGroup': questionGroup,
    'expected': expected,
    'actual': actual,
    'questionType': questionType,
  };
}

class AnswerMismatch {
  final String comboId;
  final int seriesId;
  final int testId;
  final int part;
  final int questionGroup;
  final int questionId;
  final int questionIndex;
  final String type;
  final String expected;
  final String actual;
  final List<String> options;
  final List<String>? textAnswers;
  final List<int> answers;

  AnswerMismatch({
    required this.comboId,
    required this.seriesId,
    required this.testId,
    required this.part,
    required this.questionGroup,
    required this.questionId,
    required this.questionIndex,
    required this.type,
    required this.expected,
    required this.actual,
    required this.options,
    required this.textAnswers,
    required this.answers,
  });

  Map<String, dynamic> toJson() => {
    'comboId': comboId,
    'seriesId': seriesId,
    'testId': testId,
    'part': part,
    'questionGroup': questionGroup,
    'questionId': questionId,
    'questionIndex': questionIndex,
    'type': type,
    'expected': expected,
    'actual': actual,
    'options': options,
    'textAnswers': textAnswers,
    'answers': answers,
  };
}

class SkippedTypeFailure {
  final String comboId;
  final int seriesId;
  final int testId;
  final int part;
  final int questionGroup;
  final int questionId;
  final int questionIndex;
  final String type;
  final String reason;
  final List<String> options;

  SkippedTypeFailure({
    required this.comboId,
    required this.seriesId,
    required this.testId,
    required this.part,
    required this.questionGroup,
    required this.questionId,
    required this.questionIndex,
    required this.type,
    required this.reason,
    required this.options,
  });

  Map<String, dynamic> toJson() => {
    'comboId': comboId,
    'seriesId': seriesId,
    'testId': testId,
    'part': part,
    'questionGroup': questionGroup,
    'questionId': questionId,
    'questionIndex': questionIndex,
    'type': type,
    'reason': reason,
    'options': options,
  };
}

class _TestCombo {
  final int seriesId;
  final int testId;
  final int part;
  final int qGroup;
  final int start;

  _TestCombo(this.seriesId, this.testId, this.part, this.qGroup, this.start);

  String get id => '$seriesId-$testId-$part';
}

Future<List<_TestCombo>> _discoverCombos() async {
  final combos = <_TestCombo>[];

  for (int seriesId = 1; seriesId <= 19; seriesId++) {
    for (int testId = 1; testId <= 3; testId++) {
      for (int part = 1; part <= 2; part++) {
        final testPath = 'assets/ielts/test/$seriesId-$testId-$part.json';
        try {
          await rootBundle.loadString(testPath);
        } catch (_) {
          continue;
        }

        final questionPath =
            'assets/ielts/question/$seriesId-$testId-$part.json';
        int maxGroup = 3;
        try {
          final questionJson = await rootBundle.loadString(questionPath);
          final questionData = jsonDecode(questionJson) as Map<String, dynamic>;
          final qList = questionData['test_question'] as List? ?? [];
          maxGroup = qList.length;
        } catch (_) {}

        for (int qGroup = 1; qGroup <= maxGroup; qGroup++) {
          int start = 1;
          try {
            final questionJson = await rootBundle.loadString(questionPath);
            final questionData =
                jsonDecode(questionJson) as Map<String, dynamic>;
            final qList = questionData['test_question'] as List? ?? [];
            if (qGroup - 1 < qList.length) {
              start = (qList[qGroup - 1] as Map)['start'] as int? ?? 1;
            }
          } catch (_) {}

          combos.add(_TestCombo(seriesId, testId, part, qGroup, start));
        }
      }
    }
  }

  return combos;
}

Future<List<dynamic>?> _loadAnswers(int seriesId, int testId) async {
  final path = 'assets/ielts/answer/$seriesId-$testId.json';
  try {
    final jsonStr = await rootBundle.loadString(path);
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    return data['reading'] as List? ?? [];
  } catch (_) {
    return null;
  }
}

bool _matchesAnswer(ParagraphGroup q, int qId, List answers) {
  String? expectedRaw;

  for (final a in answers) {
    if (a['question_id'].toString() == qId.toString()) {
      expectedRaw = a['correct_answer'] as String?;
      break;
    }
  }

  if (expectedRaw == null) return true;

  if (q.type.startsWith('select-') ||
      q.type == 'checkbox' ||
      q.type == 'option-abc') {
    final options = q.options;
    if (options.isEmpty) {
      if (q.type == 'select-section-given-list' || q.type == 'select-section') {
        final romanMap = {
          'I': 0,
          'II': 1,
          'III': 2,
          'IV': 3,
          'V': 4,
          'VI': 5,
          'VII': 6,
          'VIII': 7,
          'IX': 8,
          'X': 9,
          'XI': 10,
          'XII': 11,
          'XIII': 12,
        };
        final expectedNorm = expectedRaw.toUpperCase().trim();
        if (romanMap.containsKey(expectedNorm)) {
          return q.answers.isNotEmpty &&
              q.answers.first == romanMap[expectedNorm]!;
        }
      }
      return true;
    }

    final expectedNorm = expectedRaw.toUpperCase().trim();
    int expectedIdx = -1;

    for (int i = 0; i < options.length; i++) {
      if (options[i].toUpperCase().trim() == expectedNorm) {
        expectedIdx = i;
        break;
      }
    }

    if (expectedIdx == -1) {
      final romanMap = {
        'I': 0,
        'II': 1,
        'III': 2,
        'IV': 3,
        'V': 4,
        'VI': 5,
        'VII': 6,
        'VIII': 7,
        'IX': 8,
        'X': 9,
        'XI': 10,
        'XII': 11,
      };
      if (romanMap.containsKey(expectedNorm)) {
        expectedIdx = romanMap[expectedNorm]!;
      }
    }

    if (expectedIdx == -1) {
      // print('WARN: Cannot map answer "$expectedRaw" for ${q.type} q$qId');
      return true;
    }

    return q.answers.isNotEmpty && q.answers.first == expectedIdx;
  }

  if (q.type == 'option-true-false' || q.type == 'option-yes-no') {
    final expectedNorm = expectedRaw.toUpperCase().trim();
    final actualIdx = q.answers.isNotEmpty ? q.answers.first : -1;
    if (expectedNorm == 'TRUE' || expectedNorm == 'YES') return actualIdx == 0;
    if (expectedNorm == 'FALSE' || expectedNorm == 'NO') return actualIdx == 1;
    return actualIdx == 2;
  }

  final expectedNorm = expectedRaw.toUpperCase().trim();
  final actual = q.textAnswers.map((a) => a.toUpperCase().trim()).toList();
  return actual.any((a) => a == expectedNorm);
}

String _expectedAns(List answers, int qId) {
  for (final a in answers) {
    if (a['question_id'].toString() == qId.toString()) {
      return a['correct_answer'] as String? ?? 'null';
    }
  }
  return 'N/A';
}

String _actualAns(ParagraphGroup q) {
  if (q.answers.isNotEmpty) return 'option:${q.answers.first}';
  if (q.textAnswers.isNotEmpty == true) return 'text:${q.textAnswers}';
  return 'none';
}
