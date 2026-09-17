import 'package:totoki_extract/business/flashcard/flashcard.dart';
import 'package:totoki_extract/data/card_database/find_complexity.dart';

typedef AnkiFieldMapper = Flashcard? Function(List<String> fields, int deckId);

class AnkiModelMapping {
  const AnkiModelMapping({required this.modelIds, required this.mapper});

  final Set<int> modelIds;
  final AnkiFieldMapper mapper;
}

final List<AnkiModelMapping> defaultAnkiMappings = [
  AnkiModelMapping(
    modelIds: {1470756627995},
    mapper: _mapCrystalSevenFieldModel,
  ),
  AnkiModelMapping(
    modelIds: {1434531251879},
    mapper: _mapCrystalEightFieldModel,
  ),
];

final _imgRegex = RegExp(r'<img\s+src="([^"]+)"');
final _soundRegex = RegExp(r'\[sound:([^\]]+)\]');
final _tagRegex = RegExp(r'<[^>]+>');
final _ipaRegex = RegExp(r'(?<=/)[^/]+(?=/)');

Flashcard? mapRowToFlashcard(Map<String, Object?> row, int deckId) {
  final flds = row['flds'] as String? ?? '';
  final fields = flds.split('\x1f');
  final mid = row['mid'] is int
      ? row['mid'] as int
      : int.tryParse('${row['mid']}');

  if (mid != null) {
    for (final mapping in defaultAnkiMappings) {
      if (mapping.modelIds.contains(mid)) {
        return mapping.mapper(fields, deckId);
      }
    }
  }

  return _guessMapping(fields, deckId);
}

Flashcard? _mapCrystalSevenFieldModel(List<String> fields, int deckId) {
  if (fields.length < 7) return _guessMapping(fields, deckId);

  final word = _clean(fields[0]);
  return Flashcard(
    deckId: deckId,
    word: word,
    ipa: _ipaRegex.firstMatch(fields[1])?.group(0),
    sound: _soundRegex.firstMatch(fields[2])?.group(1),
    meaning: _clean(fields[3]).replaceAll('&nbsp;', '\n'),
    example: _clean(fields[4]),
    img: _imgRegex.firstMatch(fields[5])?.group(1),
    synonyms: _imgRegex.firstMatch(fields[6])?.group(1),
    due: DateTime.now(),
    complexity: findComplexity(word),
  );
}

Flashcard? _mapCrystalEightFieldModel(List<String> fields, int deckId) {
  if (fields.length < 8) return _guessMapping(fields, deckId);

  final word = _clean(fields[0]);
  return Flashcard(
    deckId: deckId,
    word: word,
    img: _imgRegex.firstMatch(fields[1])?.group(1),
    sound: _soundRegex.firstMatch(fields[2])?.group(1),
    defSound: _soundRegex.firstMatch(fields[3])?.group(1),
    usageSound: _soundRegex.firstMatch(fields[4])?.group(1),
    meaning: _clean(fields[5]),
    example: _clean(fields[6]),
    ipa: _clean(fields[7]),
    due: DateTime.now(),
    complexity: findComplexity(word),
  );
}

Flashcard? _guessMapping(List<String> fields, int deckId) {
  if (fields.isEmpty) return null;

  final cleaned = fields.map(_clean).toList(growable: false);
  final word = cleaned.firstWhere(
    (field) => field.trim().isNotEmpty && !field.contains('[sound:'),
    orElse: () => cleaned.first,
  );
  if (word.trim().isEmpty) return null;

  final sounds = <String>[
    for (final field in fields)
      if (_soundRegex.firstMatch(field)?.group(1) case final sound?) sound,
  ];
  final images = <String>[
    for (final field in fields)
      if (_imgRegex.firstMatch(field)?.group(1) case final image?) image,
  ];
  final ipa = fields
      .map((field) => _ipaRegex.firstMatch(field)?.group(0))
      .whereType<String>()
      .firstOrNull;

  final meaning = cleaned
      .skip(1)
      .firstWhere(
        (field) =>
            field.trim().isNotEmpty &&
            !field.contains('[sound:') &&
            !_looksLikeMedia(field),
        orElse: () => '',
      );

  return Flashcard(
    deckId: deckId,
    word: word,
    meaning: meaning,
    ipa: ipa,
    sound: sounds.firstOrNull,
    defSound: sounds.length > 1 ? sounds[1] : null,
    usageSound: sounds.length > 2 ? sounds[2] : null,
    img: images.firstOrNull,
    synonyms: images.length > 1 ? images[1] : null,
    due: DateTime.now(),
    complexity: findComplexity(word),
  );
}

String _clean(String value) {
  return value
      .replaceAll(_tagRegex, '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .trim();
}

bool _looksLikeMedia(String value) {
  final lower = value.toLowerCase();
  return lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.gif') ||
      lower.endsWith('.mp3') ||
      lower.endsWith('.ogg') ||
      lower.endsWith('.wav');
}
