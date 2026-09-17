import '../helpers/asset_helper.dart';
import '../models/paragraph_group.dart';
import 'question_normalizer.dart';

class QuestionParser {
  static final _inputRegex = RegExp(r'<input(?:=[^>]*)?>');

  static List<ParagraphGroup> parse({
    required Map<String, dynamic> qGroup,
    required Map<int, int> answerLookup,
    required Map<int, String> textAnswerLookup,
    required int seriesId,
  }) {
    final type = qGroup["type"] as String? ?? "unknown";
    if (!QuestionNormalizer.knownTypes.contains(type)) {
      throw UnsupportedError("Unknown question type: $type");
    }
    final body = qGroup["body"] as Map<String, dynamic>? ?? {};
    final start = qGroup["start"] as int? ?? 0;

    switch (type) {
      case "select-given-diagram":
        return _parseSelectDiagram(
          body: body, qGroup: qGroup, start: start,
          answerLookup: answerLookup, seriesId: seriesId,
        );
      case "select-flowchart-given-list":
      case final _ when type.startsWith("select-"):
        return _parseSelect(body: body, start: start, answerLookup: answerLookup, type: type);
      case "option-abc":
        return _parseOptionAbc(body: body, start: start, answerLookup: answerLookup);
      case "option-true-false":
      case "option-yes-no":
        return _parseOptionTfYn(body: body, type: type, start: start, textAnswerLookup: textAnswerLookup);
      case "checkbox":
        return _parseCheckbox(body: body, qGroup: qGroup, start: start, answerLookup: answerLookup);
      case "input-table":
        return _parseInputTable(body: body, qGroup: qGroup, start: start, textAnswerLookup: textAnswerLookup);
      case "input-diagram":
        return _parseInputDiagram(
          body: body, qGroup: qGroup, start: start,
          textAnswerLookup: textAnswerLookup, seriesId: seriesId,
        );
      case "input-note":
        return _parseInputNote(
          body: body, qGroup: qGroup, start: start,
          textAnswerLookup: textAnswerLookup, seriesId: seriesId,
        );
      case "input-flowchart":
        return _parseInputFlowchart(
          body: body, qGroup: qGroup, start: start,
          textAnswerLookup: textAnswerLookup, seriesId: seriesId,
        );
      case final _ when type.startsWith("input-"):
        return _parseInputGeneric(body: body, qGroup: qGroup, start: start, textAnswerLookup: textAnswerLookup, type: type);
      default:
        throw UnsupportedError("Unknown question type: $type");
    }
  }

  static List<ParagraphGroup> _parseSelect({
    required Map<String, dynamic> body,
    required int start,
    required Map<int, int> answerLookup,
    required String type,
  }) {
    final list = (body["list"] as List?)?.map((e) => e.toString().trim()).toList() ?? [];
    final items = body["items"] as List? ?? [];
    int qNum = start;
    final result = <ParagraphGroup>[];

    for (final item in items) {
      if (item is Map && item["type"] == "example") continue;
      if (item is! String) continue;

      final matches = _inputRegex.allMatches(item).toList();
      if (matches.isEmpty) continue;

      final displayText = item
          .replaceAll(_inputRegex, '___')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      final answers = <int>[];
      for (int i = 0; i < matches.length; i++) {
        answers.add(answerLookup[qNum] ?? 0);
        qNum++;
      }

      result.add(ParagraphGroup(
        displayText: displayText,
        options: List<String>.from(list),
        answers: answers,
        type: type,
      ));
    }

    return result;
  }

  static List<ParagraphGroup> _parseSelectDiagram({
    required Map<String, dynamic> body,
    required Map<String, dynamic> qGroup,
    required int start,
    required Map<int, int> answerLookup,
    required int seriesId,
  }) {
    final imgFilename = body["img"] as String? ?? "";
    final imageAssetPath = imgFilename.isNotEmpty ? AssetHelper.imageAssetPath(seriesId, imgFilename) : null;
    final list = (body["list"] as List?)?.map((e) => e.toString().trim()).toList() ?? [];
    final items = body["items"] as List? ?? [];
    final descText = qGroup["desc"]["text"] as List?;
    final instruction = (descText != null && descText.isNotEmpty) ? descText[0] as String : "";
    final diagramTitle = body["title"] as String?;

    int qNum = start;
    final answers = <int>[];
    final labelParts = <String>[];

    for (final item in items) {
      if (item is Map && item["type"] == "example") continue;
      if (item is! String) continue;

      final matches = _inputRegex.allMatches(item).toList();
      for (int i = 0; i < matches.length; i++) {
        answers.add(answerLookup[qNum] ?? 0);
        labelParts.add("$qNum.");
        qNum++;
      }
    }

    final displayText = labelParts.join(" ___ ");

    return [
      ParagraphGroup(
        displayText: displayText,
        options: List<String>.from(list),
        answers: answers,
        type: "select-given-diagram",
        imageAssetPath: imageAssetPath,
        diagramTitle: instruction.isNotEmpty ? instruction : diagramTitle,
      ),
    ];
  }

  static List<ParagraphGroup> _parseOptionAbc({
    required Map<String, dynamic> body,
    required int start,
    required Map<int, int> answerLookup,
  }) {
    final items = body["items"] as List? ?? [];
    int qNum = start;
    final result = <ParagraphGroup>[];

    for (final item in items) {
      if (item is! Map) continue;
      final title = item["title"] as String? ?? "";
      final options = (item["options"] as List?)?.map((e) => e.toString()).toList() ?? [];

      result.add(ParagraphGroup(
        displayText: title,
        options: options,
        answers: [answerLookup[qNum] ?? 0],
        type: "option-abc",
      ));
      qNum++;
    }

    return result;
  }

  static List<ParagraphGroup> _parseOptionTfYn({
    required Map<String, dynamic> body,
    required String type,
    required int start,
    required Map<int, String> textAnswerLookup,
  }) {
    final items = body["items"] as List? ?? [];
    const tfOptions = ["True", "False", "Not Given"];
    const ynOptions = ["Yes", "No", "Not Given"];
    final options = type == "option-true-false" ? tfOptions : ynOptions;
    int qNum = start;
    final result = <ParagraphGroup>[];

    for (final item in items) {
      if (item is! String) continue;

      final textAns = textAnswerLookup[qNum]?.toUpperCase() ?? "";
      int answerIdx;
      if (textAns == "TRUE" || textAns == "YES") {
        answerIdx = 0;
      } else if (textAns == "FALSE" || textAns == "NO") {
        answerIdx = 1;
      } else {
        answerIdx = 2;
      }

      result.add(ParagraphGroup(
        displayText: item,
        options: List<String>.from(options),
        answers: [answerIdx],
        type: type,
      ));
      qNum++;
    }

    return result;
  }

  static List<ParagraphGroup> _parseCheckbox({
    required Map<String, dynamic> body,
    required Map<String, dynamic> qGroup,
    required int start,
    required Map<int, int> answerLookup,
  }) {
    final title = body["title"] as String? ?? "";
    final opts = (body["options"] as List?)?.map((e) => e.toString()).toList() ?? [];
    final quantity = (qGroup["desc"]["quantity"] as int?) ?? 1;
    int qNum = start;

    final answers = <int>[];
    for (int i = 0; i < quantity; i++) {
      answers.add(answerLookup[qNum] ?? 0);
      qNum++;
    }

    return [
      ParagraphGroup(
        displayText: title,
        options: opts,
        answers: answers,
        type: "checkbox",
      ),
    ];
  }

  static List<ParagraphGroup> _parseInputTable({
    required Map<String, dynamic> body,
    required Map<String, dynamic> qGroup,
    required int start,
    required Map<int, String> textAnswerLookup,
  }) {
    final items = body["items"] as List? ?? [];
    final constraint = qGroup["desc"]["constraint"] as String?;
    int qNum = start;

    final tableInputRegex = RegExp(r'<input(?:\[\]|)(?:=[^>]*)?>');

    bool isExample(Object? cell) => cell is Map && cell["type"] == "example";

    bool isSpanLabel(Object? cell) =>
        cell is Map && cell["type"] != "example" && (cell["rowspan"] != null || cell["title"] != null || cell["prefix"] != null);

    (String, int) replaceInputs(String text) {
      int count = 0;
      final result = text.replaceAllMapped(tableInputRegex, (m) {
        final isDouble = m.group(0)!.contains("[]");
        count += isDouble ? 2 : 1;
        return isDouble ? "___ ___" : "___";
      });
      return (result.trim(), count);
    }

    final headers = <String>[];
    if (items.isNotEmpty && items[0] is List) {
      for (final h in (items[0] as List)) {
        headers.add(h.toString().trim());
      }
    }

    final tableCells = <List<String>>[];
    final tableInputCounts = <List<int>>[];
    final textAnswers = <String>[];
    final displayText = body["title"] as String? ?? "";

    final numCols = headers.length;
    final spanRemaining = <int, int>{};

    for (int i = 1; i < items.length; i++) {
      final row = items[i] as List? ?? [];
      if (row.isEmpty) continue;

      final cells = <String>[];
      final counts = <int>[];

      final colsToCheck = spanRemaining.keys.toList();
      for (final col in colsToCheck) {
        final remaining = spanRemaining[col];
        if (remaining != null && remaining <= 0) {
          spanRemaining.remove(col);
        }
      }

      int dataIdx = 0;
      for (int col = 0; col < numCols; col++) {
        if (spanRemaining[col] != null && spanRemaining[col]! > 0) {
          cells.add("");
          counts.add(0);
          spanRemaining[col] = spanRemaining[col]! - 1;
          continue;
        }

        if (dataIdx >= row.length) {
          cells.add("");
          counts.add(0);
          continue;
        }

        final cell = row[dataIdx];
        dataIdx++;

        if (isExample(cell)) {
          final items = cell["items"] as String? ?? "";
          final display = items.replaceAllMapped(tableInputRegex, (m) {
            final raw = m.group(0)!;
            final eqIdx = raw.indexOf("=");
            if (eqIdx != -1) return raw.substring(eqIdx + 1, raw.length - 1);
            return "";
          }).trim();
          cells.add(display);
          counts.add(0);
          continue;
        }

        if (isSpanLabel(cell)) {
          final label = (cell["title"] as String?) ?? (cell["prefix"] as String?) ?? "";
          cells.add(label.trim());
          counts.add(0);
          final span = cell["rowspan"] as int? ?? 1;
          if (span > 1) spanRemaining[col] = span - 1;
          continue;
        }

        if (cell is List) {
          final parts = <String>[];
          int totalInputs = 0;
          for (final sub in cell) {
            final subStr = sub.toString();
            final (display, cnt) = replaceInputs(subStr);
            totalInputs += cnt;
            parts.add(display);
          }
          cells.add(parts.join("\n"));
          counts.add(totalInputs);
          for (int k = 0; k < totalInputs; k++) {
            textAnswers.add(textAnswerLookup[qNum] ?? "");
            qNum++;
          }
          continue;
        }

        if (cell is String) {
          final (display, cnt) = replaceInputs(cell);
          cells.add(display);
          counts.add(cnt);
          for (int k = 0; k < cnt; k++) {
            textAnswers.add(textAnswerLookup[qNum] ?? "");
            qNum++;
          }
          continue;
        }

        if (cell is Map) {
          final txt = (cell["title"] as String?) ?? (cell["prefix"] as String?) ?? cell.toString();
          cells.add(txt.trim());
          counts.add(0);
          continue;
        }

        cells.add(cell.toString().trim());
        counts.add(0);
      }

      tableCells.add(cells);
      tableInputCounts.add(counts);
    }

    return [
      ParagraphGroup(
        displayText: displayText,
        options: [],
        answers: [],
        textAnswers: textAnswers,
        type: "input-table",
        constraint: constraint,
        tableHeaders: headers.isNotEmpty ? headers : null,
        tableCells: tableCells.isNotEmpty ? tableCells : null,
        tableInputCounts: tableInputCounts.isNotEmpty ? tableInputCounts : null,
      ),
    ];
  }

  static List<ParagraphGroup> _parseInputDiagram({
    required Map<String, dynamic> body,
    required Map<String, dynamic> qGroup,
    required int start,
    required Map<int, String> textAnswerLookup,
    required int seriesId,
  }) {
    final imgFilename = body["img"] as String? ?? "";
    final imageAssetPath = imgFilename.isNotEmpty ? AssetHelper.imageAssetPath(seriesId, imgFilename) : null;
    final diagramTitle = body["title"] as String?;
    final constraint = qGroup["desc"]["constraint"] as String?;
    final descText = qGroup["desc"]["text"] as List?;
    final instruction = (descText != null && descText.isNotEmpty) ? descText[0] as String : "";
    final inputItems = body["items"] as List? ?? [];
    int qNum = start;
    final textAnswers = <String>[];

    for (final item in inputItems) {
      if (item is Map) {
        if (item["type"] == "example") continue;
        final text = (item["title"] as String?) ?? (item["prefix"] as String?) ?? "";
        final matches = _inputRegex.allMatches(text).toList();
        for (int i = 0; i < matches.length; i++) {
          textAnswers.add(textAnswerLookup[qNum] ?? "");
          qNum++;
        }
      } else if (item is List) {
        for (final inner in item) {
          if (inner is String) {
            final matches = _inputRegex.allMatches(inner).toList();
            for (int i = 0; i < matches.length; i++) {
              textAnswers.add(textAnswerLookup[qNum] ?? "");
              qNum++;
            }
          }
        }
      } else if (item is String) {
        final matches = _inputRegex.allMatches(item).toList();
        for (int i = 0; i < matches.length; i++) {
          textAnswers.add(textAnswerLookup[qNum] ?? "");
          qNum++;
        }
      }
    }

    return [
      ParagraphGroup(
        displayText: instruction,
        options: [],
        answers: [],
        textAnswers: textAnswers,
        type: "input-diagram",
        constraint: constraint,
        imageAssetPath: imageAssetPath,
        diagramTitle: diagramTitle,
      ),
    ];
  }

  static List<ParagraphGroup> _parseInputNote({
    required Map<String, dynamic> body,
    required Map<String, dynamic> qGroup,
    required int start,
    required Map<int, String> textAnswerLookup,
    required int seriesId,
  }) {
    final imgFilename = body["img"] as String? ?? "";
    final imageAssetPath = imgFilename.isNotEmpty ? AssetHelper.imageAssetPath(seriesId, imgFilename) : null;
    final constraint = qGroup["desc"]["constraint"] as String?;
    final title = body["title"] as String?;
    final items = body["items"] as List? ?? [];
    int qNum = start;
    final groups = <ParagraphGroup>[];

    // Case 1: items is a flat list of strings (sentences with inputs) - e.g., 10-3-2 qG2
    if (items.isNotEmpty && items.every((e) => e is String)) {
      final sentences = items.cast<String>();
      final displayText = sentences.join(" ");
      final answers = <String>[];
      for (final sentence in sentences) {
        final matches = _inputRegex.allMatches(sentence).toList();
        for (int i = 0; i < matches.length; i++) {
          answers.add(textAnswerLookup[qNum] ?? "");
          qNum++;
        }
      }
      if (answers.isNotEmpty) {
        groups.add(ParagraphGroup(
          displayText: displayText,
          options: [],
          answers: [],
          textAnswers: answers,
          type: "input-note",
          constraint: constraint,
          imageAssetPath: imageAssetPath,
        ));
      }
      return groups;
    }

    // Case 2: items is a list containing a list of strings - e.g., 15-1-1, 18-1-1
    if (items.length == 1 && items[0] is List) {
      final sentences = (items[0] as List).cast<String>();
      final displayText = sentences.join(" ");
      final answers = <String>[];
      for (final sentence in sentences) {
        final matches = _inputRegex.allMatches(sentence).toList();
        for (int i = 0; i < matches.length; i++) {
          answers.add(textAnswerLookup[qNum] ?? "");
          qNum++;
        }
      }
      if (answers.isNotEmpty) {
        groups.add(ParagraphGroup(
          displayText: displayText,
          options: [],
          answers: [],
          textAnswers: answers,
          type: "input-note",
          constraint: constraint,
          imageAssetPath: imageAssetPath,
        ));
      }
      return groups;
    }

    // Case 3: items is a list of maps (mixed: input-table, title+inputs) - e.g., 8-2-1 qG1
    for (final item in items) {
      if (item is Map) {
        if (item["type"] == "example") continue;
        if (item["type"] == "input-table") {
          final tableItems = item["items"] as List? ?? [];
          final tableResult = _parseInputTableFromItems(
            items: tableItems,
            qGroup: qGroup,
            start: qNum,
            textAnswerLookup: textAnswerLookup,
          );
          groups.addAll(tableResult);
          for (final g in tableResult) {
            qNum += g.textAnswers.length + g.answers.length;
          }
        } else {
          final itemTitle = item["title"] as String?;
          final itemInputs = item["items"] as List? ?? [];
          if (itemInputs.isNotEmpty) {
            final displayText = itemTitle ?? title ?? "";
            final answers = <String>[];
            for (final input in itemInputs) {
              if (input is String && _inputRegex.hasMatch(input)) {
                answers.add(textAnswerLookup[qNum] ?? "");
                qNum++;
              }
            }
            if (answers.isNotEmpty) {
              groups.add(ParagraphGroup(
                displayText: displayText,
                options: [],
                answers: [],
                textAnswers: answers,
                type: "input-note",
                constraint: constraint,
                imageAssetPath: imageAssetPath,
              ));
            }
          }
}
      }
    }
    return groups;
  }

  static List<ParagraphGroup> _parseInputFlowchart({
    required Map<String, dynamic> body,
    required Map<String, dynamic> qGroup,
    required int start,
    required Map<int, String> textAnswerLookup,
    required int seriesId,
  }) {
    final imgFilename = body["img"] as String? ?? "";
    final imageAssetPath = imgFilename.isNotEmpty ? AssetHelper.imageAssetPath(seriesId, imgFilename) : null;
    final constraint = qGroup["desc"]["constraint"] as String?;
    final items = body["items"] as List? ?? [];
    int qNum = start;
    final groups = <ParagraphGroup>[];

    // items is a list containing a list of stage strings
    if (items.length == 1 && items[0] is List) {
      final stages = (items[0] as List).cast<String>();
      final displayText = stages.join(" → ");
      final answers = <String>[];
      for (final stage in stages) {
        final matches = _inputRegex.allMatches(stage).toList();
        for (int i = 0; i < matches.length; i++) {
          answers.add(textAnswerLookup[qNum] ?? "");
          qNum++;
        }
      }
      if (answers.isNotEmpty) {
        groups.add(ParagraphGroup(
          displayText: displayText,
          options: [],
          answers: [],
          textAnswers: answers,
          type: "input-flowchart",
          constraint: constraint,
          imageAssetPath: imageAssetPath,
        ));
      }
    }

    return groups;
  }

  static List<ParagraphGroup> _parseInputTableFromItems({
    required List items,
    required Map<String, dynamic> qGroup,
    required int start,
    required Map<int, String> textAnswerLookup,
  }) {
    final constraint = qGroup["desc"]["constraint"] as String?;
    final tableInputRegex = RegExp(r'<input(?:\[\]|)(?:=[^>]*)?>');
    int qNum = start;
    final textAnswers = <String>[];
    final headers = <String>[];
    final tableCells = <List<String>>[];
    final tableInputCounts = <List<int>>[];

    if (items.isNotEmpty && items[0] is List) {
      for (final h in (items[0] as List)) {
        headers.add(h.toString().trim());
      }
    }

    for (int i = 1; i < items.length; i++) {
      final row = items[i] as List? ?? [];
      if (row.isEmpty) continue;
      final cells = <String>[];
      final counts = <int>[];
      for (final cell in row) {
        String display = "";
        int cnt = 0;
        if (cell is String) {
          cnt = _inputRegex.allMatches(cell).length;
          display = cell.replaceAllMapped(tableInputRegex, (m) {
            final isDouble = m.group(0)!.contains("[]");
            return isDouble ? "___ ___" : "___";
          }).trim();
        } else if (cell is List) {
          final parts = <String>[];
          for (final sub in cell) {
            final subStr = sub.toString();
            cnt += _inputRegex.allMatches(subStr).length;
            parts.add(subStr.replaceAllMapped(tableInputRegex, (m) {
              final isDouble = m.group(0)!.contains("[]");
              return isDouble ? "___ ___" : "___";
            }).trim());
          }
          display = parts.join("\n");
        } else if (cell is Map) {
          display = (cell["title"] as String?) ?? (cell["prefix"] as String?) ?? "";
        }
        cells.add(display);
        counts.add(cnt);
        for (int k = 0; k < cnt; k++) {
          textAnswers.add(textAnswerLookup[qNum] ?? "");
          qNum++;
        }
      }
      tableCells.add(cells);
      tableInputCounts.add(counts);
    }

    return [
      ParagraphGroup(
        displayText: "",
        options: [],
        answers: [],
        textAnswers: textAnswers,
        type: "input-table",
        constraint: constraint,
        tableHeaders: headers.isNotEmpty ? headers : null,
        tableCells: tableCells.isNotEmpty ? tableCells : null,
        tableInputCounts: tableInputCounts.isNotEmpty ? tableInputCounts : null,
      ),
    ];
  }

  static List<ParagraphGroup> _parseInputGeneric({
    required Map<String, dynamic> body,
    required Map<String, dynamic> qGroup,
    required int start,
    required Map<int, String> textAnswerLookup,
    required String type,
  }) {
    final items = body["items"] as List? ?? [];
    final constraint = qGroup["desc"]["constraint"] as String?;
    int qNum = start;
    final result = <ParagraphGroup>[];

    for (final item in items) {
      if (item is Map && item["type"] == "example") continue;

      String text;
      String displayText;
      if (item is String) {
        text = item;
        displayText = item.replaceAll(_inputRegex, '___').replaceAll(RegExp(r'\s+'), ' ').trim();
      } else if (item is Map) {
        final title = item["title"] as String? ?? "";
        final prefix = item["prefix"] as String? ?? "";
        final combined = "$title $prefix".trim();
        text = combined;
        displayText = combined.replaceAll(_inputRegex, '___').replaceAll(RegExp(r'\s+'), ' ').trim();
      } else {
        continue;
      }

      final matches = _inputRegex.allMatches(text).toList();
      if (matches.isEmpty) continue;

      final textAnswers = <String>[];
      for (int i = 0; i < matches.length; i++) {
        textAnswers.add(textAnswerLookup[qNum] ?? "");
        qNum++;
      }

      result.add(ParagraphGroup(
        displayText: displayText,
        options: [],
        answers: [],
        textAnswers: textAnswers,
        type: type, // preserves the input-* subtype
        constraint: constraint,
      ));
    }

    return result;
  }
}
