import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class ReadingNoti extends ChangeNotifier {
  String title = "";
  String articleText = "";
  List<Map<String, dynamic>> questions = [];
  bool isLoading = false;
  Map<String, dynamic> _dictionary = {};

  String? lookupWord(String word) {
    final entry = _dictionary[word.toLowerCase()];
    return entry?["quick_def"] as String?;
  }

  Future<void> loadPassage() async {
    isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      rootBundle.loadString("assets/ielts/test/1-1-1.json"),
      rootBundle.loadString("assets/ielts/jsondictionary.json"),
    ]);
    _dictionary = jsonDecode(results[1]) as Map<String, dynamic>;
    final data = jsonDecode(results[0]) as Map<String, dynamic>;
    final article = data["test_text"]["article"];
    title = article["title"] as String;
    final sections = article["sections"] as List;

    final buffer = StringBuffer();
    for (final section in sections) {
      for (final item in section["items"]) {
        for (final paragraph in item["items"]) {
          for (final sentence in paragraph["items"]) {
            buffer.write(sentence["sentence_raw"] as String);
            buffer.write(" ");
          }
          buffer.write("\n\n");
        }
      }
    }
    articleText = buffer.toString().trim();

    questions = [
      {
        "q": "What did early man believe about fire according to the passage?",
        "options": [
          "It was a divine gift randomly delivered",
          "It could be created by rubbing stones",
          "It was discovered in volcanic regions",
          "It was first used for cooking food",
        ],
        "answer": 0,
      },
      {
        "q": "How did the earliest peoples store fire before they could make it?",
        "options": [
          "By using magnifying glasses",
          "By keeping slow burning logs alight",
          "By rubbing flint stones together",
          "By storing sunlight in crystals",
        ],
        "answer": 1,
      },
      {
        "q": "How was the first man-made fire likely discovered?",
        "options": [
          "By studying lightning strikes",
          "Accidentally during tool-making",
          "By observing volcanic eruptions",
          "Through religious ceremonies",
        ],
        "answer": 1,
      },
    ];

    isLoading = false;
    notifyListeners();
  }
}

