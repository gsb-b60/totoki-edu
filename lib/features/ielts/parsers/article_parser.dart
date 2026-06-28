import '../models/article_fragment.dart';

class ArticleParser {
  static ({String title, List<ArticleFragment> fragments, String articleText}) parse(
    Map<String, dynamic> data,
    int seriesId,
  ) {
    final article = data["test_text"]["article"];
    final title = article?["title"] as String? ?? "";
    final sections = article?["sections"] as List? ?? [];
    final fragments = <ArticleFragment>[];
    final buffer = StringBuffer();

    for (final section in sections) {
      final sectionItems = section["items"] as List? ?? [];
      for (final item in sectionItems) {
        if (item["type"] == "image") {
          final text = buffer.toString().trim();
          if (text.isNotEmpty) {
            fragments.add(ArticleFragment(type: "text", text: text));
          }
          buffer.clear();
          final filenames = (item["items"] as List?)?.cast<String>() ?? [];
          for (final filename in filenames) {
            final cleaned = filename.replaceAll('.jpg', '.jpeg');
            fragments.add(ArticleFragment(
              type: "image",
              imageAssetPath: "assets/ielts/picture/$seriesId/$cleaned",
            ));
          }
        } else {
          final paragraphs = item["items"] as List? ?? [];
          for (final paragraph in paragraphs) {
            final sentences = paragraph["items"] as List? ?? [];
            for (final sentence in sentences) {
              final raw = sentence["sentence_raw"] as String?;
              if (raw != null) {
                buffer.write(raw);
                buffer.write(" ");
              }
            }
            buffer.write("\n\n");
          }
        }
      }
    }

    final remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      fragments.add(ArticleFragment(type: "text", text: remaining));
    }

    final articleText = fragments
        .where((f) => f.type == "text")
        .map((f) => f.text!)
        .join("\n\n");

    return (title: title, fragments: fragments, articleText: articleText);
  }
}
