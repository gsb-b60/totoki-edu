class QuestionNormalizer {
  QuestionNormalizer._();

  static const Set<String> knownTypes = {
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
  };

  /// Safely extract display text from a body.items entry (str or dict).
  static String extractItemText(dynamic item) {
    if (item is Map) {
      if (item.containsKey("items")) return item["items"] as String;
      if (item.containsKey("title")) return item["title"] as String;
      if (item.containsKey("prefix")) return item["prefix"] as String;
      return "";
    }
    return item?.toString() ?? "";
  }

  /// Check if an item is an example marker.
  static bool isExampleItem(dynamic item) {
    return item is Map && item["type"] == "example";
  }

  /// Normalize a raw question group into a predictable shape.
  /// Handles optional fields, str|dict items, and body<->body_smart key differences.
  static Map<String, dynamic> normalizeGroup(Map<String, dynamic> raw) {
    final type = raw["type"] as String? ?? "unknown";
    final desc = raw["desc"] as Map<String, dynamic>? ?? {};
    final body = raw["body"] as Map<String, dynamic>? ?? {};
    final bodySmart = raw["body_smart"] as Map<String, dynamic>? ?? {};

    // img fallback: body.img -> body_smart.image.src
    String? img;
    final bodyImg = body["img"];
    if (bodyImg is String && bodyImg.isNotEmpty) {
      img = bodyImg;
    } else {
      final smartImage = bodySmart["image"];
      if (smartImage is Map) {
        final src = smartImage["src"];
        if (src is String && src.isNotEmpty) {
          img = src;
        }
      }
    }

    return <String, dynamic>{
      "start": raw["start"] as int? ?? 0,
      "end": raw["end"] as int? ?? 0,
      "type": type,
      "desc": <String, dynamic>{
        "constraint": desc["constraint"],
        "optionRange": desc["optionRange"],
        "quantity": desc["quantity"],
        "nb": desc["nb"],
        "text": desc["text"],
        "textReadable": desc["textReadable"],
        "sectionRange": desc["sectionRange"],
        "sectionType": desc["sectionType"],
      },
      "body": <String, dynamic>{
        "items": body["items"] ?? [],
        "title": body["title"],
        "img": img,
        "instruction": body["instruction"],
        "list": body["list"],
        "listTitle": body["listTitle"],
        "options": body["options"],
      },
      "body_smart": <String, dynamic>{
        "items": bodySmart["items"] ?? [],
        "item_qids": bodySmart["item_qids"],
        "image": bodySmart["image"],
        "list": bodySmart["list"],
        "options": bodySmart["options"],
        "title": bodySmart["title"],
      },
    };
  }
}
