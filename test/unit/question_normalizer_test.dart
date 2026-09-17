import 'package:flutter_test/flutter_test.dart';
import 'package:totoki_extract/features/ielts/parsers/question_normalizer.dart';

void main() {
  group('knownTypes', () {
    test('includes all documented question types', () {
      for (final type in const [
        'input-answer',
        'input-diagram',
        'input-flowchart',
        'input-note',
        'input-sentence',
        'input-summary',
        'input-table',
        'option-abc',
        'option-true-false',
        'option-yes-no',
        'select-summary-given-list',
        'select-given-list',
        'select-section-given-list',
        'select-given-diagram',
        'select-flowchart-given-list',
        'select-section',
        'checkbox',
      ]) {
        expect(QuestionNormalizer.knownTypes, contains(type));
      }
    });
  });

  group('extractItemText', () {
    test('returns the string for a plain item', () {
      expect(QuestionNormalizer.extractItemText('hello'), 'hello');
    });

    test('extracts items from a map with an items key', () {
      expect(
        QuestionNormalizer.extractItemText({'items': 'some text', 'type': 'x'}),
        'some text',
      );
    });

    test('extracts title when no items key', () {
      expect(
        QuestionNormalizer.extractItemText({'title': 'A title'}),
        'A title',
      );
    });

    test('extracts prefix when no items/title', () {
      expect(QuestionNormalizer.extractItemText({'prefix': 'pre'}), 'pre');
    });

    test('returns empty string for an unrecognized map', () {
      expect(QuestionNormalizer.extractItemText({'other': 1}), '');
    });

    test('returns empty for null', () {
      expect(QuestionNormalizer.extractItemText(null), '');
    });

    test('stringifies numbers safely', () {
      expect(QuestionNormalizer.extractItemText(42), '42');
    });
  });

  group('isExampleItem', () {
    test('true for a map with type example', () {
      expect(
        QuestionNormalizer.isExampleItem({'type': 'example'}),
        isTrue,
      );
    });

    test('false for non-example maps and strings', () {
      expect(QuestionNormalizer.isExampleItem({'type': 'question'}), isFalse);
      expect(QuestionNormalizer.isExampleItem('x'), isFalse);
    });
  });

  group('normalizeGroup', () {
    test('defaults missing optional fields', () {
      final result = QuestionNormalizer.normalizeGroup({'type': 'option-abc'});

      expect(result['type'], 'option-abc');
      expect(result['start'], 0);
      expect(result['end'], 0);
      expect(result['desc']['constraint'], isNull);
      expect(result['body']['img'], isNull);
      expect(result['body']['items'], isEmpty);
    });

    test('defaults unknown type to "unknown"', () {
      final result = QuestionNormalizer.normalizeGroup({});
      expect(result['type'], 'unknown');
    });

    test('preserves body items as a list when present', () {
      final result = QuestionNormalizer.normalizeGroup({
        'type': 'input-summary',
        'body': {'items': [1, 2, 3]},
      });

      expect(result['body']['items'], [1, 2, 3]);
    });

    test('falls back from body.img to body_smart.image.src', () {
      final result = QuestionNormalizer.normalizeGroup({
        'type': 'input-table',
        'body_smart': {'image': {'src': 'img/abc.png'}},
      });

      expect(result['body']['img'], 'img/abc.png');
    });

    test('prefers body.img over body_smart when both present', () {
      final result = QuestionNormalizer.normalizeGroup({
        'type': 'input-table',
        'body': {'img': 'body.png'},
        'body_smart': {'image': {'src': 'smart.png'}},
      });

      expect(result['body']['img'], 'body.png');
    });

    test('maps desc fields into a normalized shape', () {
      final result = QuestionNormalizer.normalizeGroup({
        'type': 'select-given-list',
        'desc': {
          'constraint': 'no more than two words',
          'optionRange': 'A-H',
          'quantity': 5,
        },
      });

      expect(result['desc']['constraint'], 'no more than two words');
      expect(result['desc']['optionRange'], 'A-H');
      expect(result['desc']['quantity'], 5);
      expect(result['desc']['text'], isNull);
    });

    test('copies body_smart items into the smart section', () {
      final result = QuestionNormalizer.normalizeGroup({
        'type': 'checkbox',
        'body_smart': {'items': ['a', 'b'], 'options': ['x']},
      });

      expect(result['body_smart']['items'], ['a', 'b']);
      expect(result['body_smart']['options'], ['x']);
    });
  });
}
