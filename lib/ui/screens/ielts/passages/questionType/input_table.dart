import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';

class InputTable extends StatefulWidget {
  final String headerText;
  final List<String>? tableHeaders;
  final List<List<String>>? tableCells;
  final List<List<int>>? tableInputCounts;
  final List<String> inputs;
  final String? constraint;
  final bool answered;
  final int questionIndex;
  final int totalQuestions;
  final void Function(int index, String value) onChanged;

  const InputTable({
    super.key,
    required this.headerText,
    this.tableHeaders,
    this.tableCells,
    this.tableInputCounts,
    required this.inputs,
    this.constraint,
    required this.answered,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onChanged,
  });

  @override
  State<InputTable> createState() => _InputTableState();
}

class _InputTableState extends State<InputTable> {
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(InputTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inputs != widget.inputs || oldWidget.questionIndex != widget.questionIndex) {
      _syncControllers();
    }
  }

  void _syncControllers() {
    while (_controllers.length < widget.inputs.length) {
      _controllers.add(TextEditingController());
    }
    while (_controllers.length > widget.inputs.length) {
      _controllers.removeLast().dispose();
    }
    for (int i = 0; i < widget.inputs.length; i++) {
      if (_controllers[i].text != widget.inputs[i]) {
        _controllers[i].text = widget.inputs[i];
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  int _cellInputStart(int row, int col) {
    final counts = widget.tableInputCounts;
    if (counts == null || row >= counts.length) return 0;
    int idx = 0;
    for (int r = 0; r < row; r++) {
      final rowCounts = counts[r];
      for (int c = 0; c < rowCounts.length; c++) {
        idx += rowCounts[c];
      }
    }
    final rowCounts = counts[row];
    if (col >= rowCounts.length) return idx;
    for (int c = 0; c < col; c++) {
      idx += rowCounts[c];
    }
    return idx;
  }

  Map<int, TableColumnWidth> _buildColumnWidths(int numCols) {
    return const {};
  }

  @override
  Widget build(BuildContext context) {
    final headers = widget.tableHeaders ?? [];
    final cells = widget.tableCells ?? [];
    final counts = widget.tableInputCounts ?? [];
    final numCols = headers.isNotEmpty ? headers.length : (cells.isNotEmpty ? cells[0].length : 0);

    if (numCols == 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Question ${widget.questionIndex}/${widget.totalQuestions}",
                  style: AppTheme.captionStyle.copyWith(fontSize: 13),
                ),
                if (widget.constraint != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.constraint!,
                    style: AppTheme.captionStyle.copyWith(color: Colors.orangeAccent, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                if (widget.headerText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      widget.headerText,
                      style: AppTheme.sectionHeaderStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightText,
                      ),
                    ),
                  ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(color: AppTheme.darkBorder, width: 1),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    columnWidths: _buildColumnWidths(numCols),
                    children: [
                      _buildHeaderRow(headers),
                      for (int r = 0; r < cells.length; r++)
                        _buildDataRow(
                          r,
                          cells[r],
                          counts.isNotEmpty && r < counts.length ? counts[r] : null,
                          numCols,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TableRow _buildHeaderRow(List<String> headers) {
    return TableRow(
      decoration: const BoxDecoration(color: AppTheme.darkCard),
      children: headers.map((h) => _buildHeaderCell(h)).toList(),
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

  TableRow _buildDataRow(int rowIndex, List<String> rowCells, List<int>? rowCounts, int numCols) {
    return TableRow(
      children: List.generate(numCols, (col) {
        final cellText = col < rowCells.length ? rowCells[col] : "";
        final count = rowCounts != null && col < rowCounts.length ? rowCounts[col] : 0;
        final startIdx = _cellInputStart(rowIndex, col);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: _buildCellContent(cellText, count, startIdx),
        );
      }),
    );
  }

  Widget _buildCellContent(String text, int inputCount, int startIdx) {
    if (inputCount == 0) {
      return Text(
        text,
        style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 14),
      );
    }

    final parts = text.split("___");
    final children = <Widget>[];
    int inputOffset = 0;

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        children.add(
          Text(
            parts[i],
            style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 14),
          ),
        );
      }

      if (inputOffset < inputCount) {
        final idx = startIdx + inputOffset;
        inputOffset++;
        children.add(
          widget.answered
              ? _buildAnsweredField(idx)
              : _buildInputField(idx),
        );
      }
    }

    while (inputOffset < inputCount) {
      final idx = startIdx + inputOffset;
      inputOffset++;
      children.add(
        widget.answered
            ? _buildAnsweredField(idx)
            : _buildInputField(idx),
      );
    }

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildAnsweredField(int idx) {
    final text = idx < widget.inputs.length ? widget.inputs[idx] : "";
    return Text(
      text.isEmpty ? " ___ " : text,
      style: TextStyle(
        color: text.isEmpty ? Colors.redAccent : AppTheme.greenPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildInputField(int idx) {
    final controller = idx < _controllers.length ? _controllers[idx] : null;
    return SizedBox(
      width: 100,
      height: 32,
      child: TextField(
        controller: controller,
        onChanged: (v) => widget.onChanged(idx, v),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
