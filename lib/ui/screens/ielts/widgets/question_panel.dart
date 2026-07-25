import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/features/ielts/models/paragraph_group.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/select_summary_given_list.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/option_choice.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/checkbox_widget.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/input_answer.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/input_table.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/input_diagram.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/select_given_diagram.dart';

Set<int> _usedOptionIndices(int currentParagraph, Map<int, List<int?>> savedSelections) {
  final used = <int>{};
  for (final entry in savedSelections.entries) {
    if (entry.key == currentParagraph) continue;
    for (final sel in entry.value) {
      if (sel != null) used.add(sel);
    }
  }
  return used;
}

class QuestionPanel extends StatelessWidget {
  final ParagraphGroup pg;
  final List<int?> selections;
  final List<String> textInputs;
  final bool answered;
  final int currentParagraph;
  final Map<int, List<int?>> savedSelections;
  final int totalQuestions;
  final void Function(int blankIdx, int optIdx) onSelectBlank;
  final void Function(int idx, int opt) onCheckboxSelect;
  final void Function(int idx, String value) onInputChanged;

  const QuestionPanel({
    super.key,
    required this.pg,
    required this.selections,
    required this.textInputs,
    required this.answered,
    required this.currentParagraph,
    required this.savedSelections,
    required this.totalQuestions,
    required this.onSelectBlank,
    required this.onCheckboxSelect,
    required this.onInputChanged,
  });

  @override
  Widget build(BuildContext context) {
    final qIdx = currentParagraph + 1;

    if (pg.type == "select-flowchart-given-list") {
      return SelectSummaryGivenList(
        questionText: pg.displayText,
        options: pg.options,
        selected: selections,
        answered: answered,
        questionIndex: qIdx,
        totalQuestions: totalQuestions,
        usedOptionIndices: _usedOptionIndices(currentParagraph, savedSelections),
        onSelect: onSelectBlank,
      );
    }

    if (pg.type == "select-given-diagram" && pg.imageAssetPath != null) {
      return SelectGivenDiagram(
        questionText: pg.displayText,
        options: pg.options,
        selected: selections,
        answered: answered,
        questionIndex: qIdx,
        totalQuestions: totalQuestions,
        usedOptionIndices: _usedOptionIndices(currentParagraph, savedSelections),
        imageAssetPath: pg.imageAssetPath,
        diagramTitle: pg.diagramTitle,
        constraint: pg.constraint,
        onSelect: onSelectBlank,
      );
    }

    if (pg.type.startsWith("select-")) {
      return SelectSummaryGivenList(
        questionText: pg.displayText,
        options: pg.options,
        selected: selections,
        answered: answered,
        questionIndex: qIdx,
        totalQuestions: totalQuestions,
        usedOptionIndices: _usedOptionIndices(currentParagraph, savedSelections),
        onSelect: onSelectBlank,
      );
    }

    if (pg.type == "option-abc" ||
        pg.type == "option-true-false" ||
        pg.type == "option-yes-no") {
      return OptionChoice(
        questionText: pg.displayText,
        options: pg.options,
        selected: selections.isNotEmpty ? selections[0] : null,
        answered: answered,
        questionIndex: qIdx,
        totalQuestions: totalQuestions,
        onSelect: (optIdx) => onSelectBlank(0, optIdx),
      );
    }

    if (pg.type == "checkbox") {
      return CheckboxWidget(
        questionText: pg.displayText,
        options: pg.options,
        selected: selections,
        quantity: pg.answers.length,
        answered: answered,
        questionIndex: qIdx,
        totalQuestions: totalQuestions,
        onSelect: onCheckboxSelect,
      );
    }

    if (pg.type == "input-table") {
      return InputTable(
        headerText: pg.displayText,
        tableHeaders: pg.tableHeaders,
        tableCells: pg.tableCells,
        tableInputCounts: pg.tableInputCounts,
        inputs: textInputs,
        constraint: pg.constraint,
        answered: answered,
        questionIndex: qIdx,
        totalQuestions: totalQuestions,
        onChanged: onInputChanged,
      );
    }

    if (pg.type == "input-diagram") {
      return InputDiagram(
        questionText: pg.displayText,
        imageAssetPath: pg.imageAssetPath,
        diagramTitle: pg.diagramTitle,
        inputs: textInputs,
        constraint: pg.constraint,
        answered: answered,
        questionIndex: qIdx,
        totalQuestions: totalQuestions,
        onChanged: onInputChanged,
      );
    }

    if (pg.type.startsWith("input-")) {
      return InputAnswer(
        questionText: pg.displayText,
        inputs: textInputs,
        constraint: pg.constraint,
        answered: answered,
        questionIndex: qIdx,
        totalQuestions: totalQuestions,
        onChanged: onInputChanged,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withAlpha(80), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 20),
              SizedBox(width: 8),
              Text("Unhandled question type", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            "type: ${pg.type}\n"
            "constraint: ${pg.constraint ?? "—"}\n"
            "options: [${pg.options.join(", ")}]\n"
            "textAnswers: [${pg.textAnswers.join(", ")}]\n"
            "displayText: ${pg.displayText}",
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppTheme.lightText, height: 1.5),
          ),
        ],
      ),
    );
  }
}
