import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';

class InputTable extends StatelessWidget {
  final String headerText;
  final List<String> rowLabels;
  final List<String> inputs;
  final String? constraint;
  final bool answered;
  final int questionIndex;
  final int totalQuestions;
  final void Function(int index, String value) onChanged;

  const InputTable({
    super.key,
    required this.headerText,
    required this.rowLabels,
    required this.inputs,
    this.constraint,
    required this.answered,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Question $questionIndex/$totalQuestions",
                  style: AppTheme.captionStyle.copyWith(fontSize: 13),
                ),
                if (constraint != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    constraint!,
                    style: AppTheme.captionStyle.copyWith(color: Colors.orangeAccent, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                if (headerText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      headerText,
                      style: AppTheme.sectionHeaderStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightText,
                      ),
                    ),
                  ),
                Table(
                  border: TableBorder.all(color: AppTheme.darkBorder, width: 1),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                    _buildHeaderRow(),
                    for (int i = 0; i < rowLabels.length; i++) _buildDataRow(i),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(color: AppTheme.darkCard),
      children: [
        _buildHeaderCell("Label"),
        _buildHeaderCell("Answer"),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: AppTheme.captionStyle.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppTheme.greenPrimary,
        ),
      ),
    );
  }

  TableRow _buildDataRow(int rowIndex) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            rowLabels[rowIndex],
            style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: answered
              ? _buildAnsweredCell(rowIndex)
              : _buildInputField(rowIndex),
        ),
      ],
    );
  }

  Widget _buildAnsweredCell(int rowIndex) {
    final text = rowIndex < inputs.length ? inputs[rowIndex] : "";
    return Text(
      text.isEmpty ? " ___ " : text,
      style: TextStyle(
        color: text.isEmpty ? Colors.redAccent : AppTheme.greenPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildInputField(int rowIndex) {
    return SizedBox(
      height: 32,
      child: TextField(
        onChanged: (v) => onChanged(rowIndex, v),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppTheme.greenPrimary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppTheme.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppTheme.greenPrimary, width: 2),
          ),
        ),
        style: const TextStyle(
          color: AppTheme.greenPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
