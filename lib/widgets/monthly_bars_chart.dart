import 'package:flutter/material.dart';

import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';

/// A month-by-month bar chart, drawn the same bordered/irregular-radius way
/// as the app's other tappable shapes (see PillButton) rather than a filled
/// gradient column.
class MonthlyBarsChart extends StatelessWidget {
  final List<String> labels; // short month names, oldest first
  final List<int> values;
  final int highlightIndex; // -1 for none — usually "this month"
  final double maxHeight;

  const MonthlyBarsChart({
    super.key,
    required this.labels,
    required this.values,
    this.highlightIndex = -1,
    this.maxHeight = 90,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    final peak = values.fold(0, (a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < labels.length; i++)
          _Bar(
            label: labels[i],
            value: values[i],
            heightFrac: peak == 0 ? 0 : values[i] / peak,
            maxHeight: maxHeight,
            highlight: i == highlightIndex,
            t: t,
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int value;
  final double heightFrac;
  final double maxHeight;
  final bool highlight;
  final PaperTokens t;

  const _Bar({
    required this.label,
    required this.value,
    required this.heightFrac,
    required this.maxHeight,
    required this.highlight,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final barHeight = (heightFrac * maxHeight).clamp(3.0, maxHeight);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value.toString(), style: PaperText.small(t.ink, size: 11)),
        const SizedBox(height: 4),
        Container(
          width: 26,
          height: barHeight,
          decoration: BoxDecoration(
            color: highlight ? t.hiFill : null,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(4),
            ),
            border: Border.all(color: t.ink, width: 1.5),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: PaperText.small(t.ink, size: 10).copyWith(color: t.ink.withValues(alpha: t.ink.a * .6))),
      ],
    );
  }
}
