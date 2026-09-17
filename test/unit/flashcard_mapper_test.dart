import 'package:flutter_test/flutter_test.dart';
import 'package:totoki_extract/data/card_database/flashCard_Mapper.dart';

const _sevenFieldModelId = 1470756627995;
const _eightFieldModelId = 1434531251879;

void main() {
  group('mapRowToFlashcard', () {
    test('maps a 7-field crystal model row correctly', () {
      final flds = [
        'serendipity',
        '/ˌserənˈdɪpəti/',
        '[sound:serendipity.mp3]',
        'the fact of finding interesting things by chance',
        'Finding a great cafe was pure serendipity.',
        '<img src="serendipity.jpg">',
        '<img src="synonyms.jpg">',
      ].join('\x1f');

      final card = mapRowToFlashcard({
        'flds': flds,
        'mid': _sevenFieldModelId,
      }, 3);

      expect(card, isNotNull);
      expect(card!.deckId, 3);
      expect(card.word, 'serendipity');
      expect(card.ipa, 'ˌserənˈdɪpəti');
      expect(card.sound, 'serendipity.mp3');
      expect(card.meaning, contains('finding interesting things by chance'));
      expect(card.example, contains('pure serendipity'));
      expect(card.img, 'serendipity.jpg');
      expect(card.synonyms, 'synonyms.jpg');
    });

    test('maps an 8-field crystal model row correctly', () {
      final flds = [
        'resilience',
        '<img src="resilience.png">',
        '[sound:resilience.mp3]',
        '[sound:resilience-def.mp3]',
        '[sound:resilience-usage.mp3]',
        'the capacity to recover quickly',
        'She showed great resilience.',
        '/rɪˈzɪliəns/',
      ].join('\x1f');

      final card = mapRowToFlashcard({
        'flds': flds,
        'mid': _eightFieldModelId,
      }, 7);

      expect(card, isNotNull);
      expect(card!.deckId, 7);
      expect(card.word, 'resilience');
      expect(card.img, 'resilience.png');
      expect(card.sound, 'resilience.mp3');
      expect(card.defSound, 'resilience-def.mp3');
      expect(card.usageSound, 'resilience-usage.mp3');
      expect(card.meaning, contains('capacity to recover'));
      expect(card.ipa, '/rɪˈzɪliəns/');
    });

    test('falls back to guess mapping when model id is unknown', () {
      final flds = [
        'phenomenon',
        '[sound:phenomenon.mp3]',
        'a fact or situation observed to exist',
      ].join('\x1f');

      final card = mapRowToFlashcard({'flds': flds, 'mid': 999}, 5);

      expect(card, isNotNull);
      expect(card!.word, 'phenomenon');
      expect(card.sound, 'phenomenon.mp3');
      expect(card.meaning, contains('fact or situation'));
    });

    test('guess mapping extracts ipa between slashes', () {
      final flds = [
        'ephemeral',
        '/ɪˈfemərəl/',
        '[sound:eph.mp3]',
        'lasting for a very short time',
      ].join('\x1f');

      final card = mapRowToFlashcard({'flds': flds, 'mid': 999}, 1);

      expect(card!.ipa, 'ɪˈfemərəl');
    });

    test('guess mapping skips media fields when picking meaning', () {
      final flds = [
        'whimsical',
        '[sound:whimsical.mp3]',
        'playfully quaint or fanciful',
        '<img src="whimsical.jpg">',
      ].join('\x1f');

      final card = mapRowToFlashcard({'flds': flds, 'mid': 999}, 2);

      expect(card!.meaning, 'playfully quaint or fanciful');
      expect(card.img, 'whimsical.jpg');
    });

    test('returns null for empty fields', () {
      final card = mapRowToFlashcard({'flds': '', 'mid': 999}, 1);
      expect(card, isNull);
    });

    test('returns null when fields only contain whitespace', () {
      final card = mapRowToFlashcard({
        'flds': '   \x1f  \x1f ',
        'mid': 999,
      }, 1);
      expect(card, isNull);
    });

    test('handles mid given as a String', () {
      final flds = [
        'whimsical',
        '<img src="w.jpg">',
        '[sound:w.mp3]',
        '[sound:wd.mp3]',
        '[sound:wu.mp3]',
        'quaint or fanciful',
        'example',
        '/ˈwɪmzɪkəl/',
      ].join('\x1f');

      final card = mapRowToFlashcard({
        'flds': flds,
        'mid': '$_eightFieldModelId',
      }, 4);

      expect(card, isNotNull);
      expect(card!.word, 'whimsical');
    });

    test('cleans html tags and entities from meaning', () {
      final flds = [
        'query',
        '[sound:query.mp3]',
        'a question &amp; query&nbsp;line',
      ].join('\x1f');

      final card = mapRowToFlashcard({'flds': flds, 'mid': 999}, 1);

      expect(card!.meaning, contains('a question & query'));
    });
  });
}
