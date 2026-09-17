import 'package:flutter_test/flutter_test.dart';
import 'package:totoki_extract/data/card_database/find_complexity.dart';

void main() {
  group('countSyllables', () {
    test('single syllable words return 1', () {
      expect(countSyllables('cat'), 1);
      expect(countSyllables('dog'), 1);
    });

    test('trailing e is dropped before counting', () {
      expect(countSyllables('he'), 1);
    });

    test('counts vowel groups', () {
      expect(countSyllables('education'), 4);
    });

    test('treats y as a vowel', () {
      expect(countSyllables('gym'), 1);
      expect(countSyllables('bicycle'), 2);
      expect(countSyllables('apply'), 2);
    });

    test('returns 0 for empty or non-alpha input', () {
      expect(countSyllables(''), 0);
    });

    test('ignores spaces and punctuation', () {
      expect(countSyllables("it's"), 1);
    });
  });

  group('findLengthRule', () {
    test('returns 0 for dashed or spaced words', () {
      expect(findLengthRule('mother-in-law'), 0);
      expect(findLengthRule('ice cream'), 0);
    });

    test('short words map to low rules', () {
      expect(findLengthRule('cat'), 1);
      expect(findLengthRule('cafe'), 2);
      expect(findLengthRule('planet'), 3);
      expect(findLengthRule('capacity'), 4);
    });

    test('long words map to higher rules', () {
      expect(findLengthRule('international'), 6);
    });
  });

  group('checkSuffix', () {
    test('recognizes common suffixes', () {
      expect(checkSuffix('education'), isTrue);
      expect(checkSuffix('biology'), isTrue);
      expect(checkSuffix('decision'), isTrue);
    });

    test('recognizes common prefixes', () {
      expect(checkSuffix('unhappy'), isTrue);
      expect(checkSuffix('impossible'), isTrue);
      expect(checkSuffix('disagree'), isTrue);
      expect(checkSuffix('international'), isTrue);
    });

    test('returns false for plain words', () {
      expect(checkSuffix('cat'), isFalse);
      expect(checkSuffix('apple'), isFalse);
    });
  });

  group('findComplexity', () {
    test('basic words get a positive complexity score', () {
      expect(findComplexity('cat'), greaterThanOrEqualTo(1));
      expect(findComplexity('education'), greaterThan(findComplexity('cat')));
    });

    test('longer, suffixed words score higher than short words', () {
      final short = findComplexity('cup');
      final long = findComplexity('internationalization');
      expect(long, greaterThan(short));
    });

    test('empty input returns 0 (no syllables, no length)', () {
      expect(findComplexity(''), 0);
    });
  });
}
