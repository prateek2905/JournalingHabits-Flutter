import 'package:flutter/material.dart';

import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';

/// The "ink-density" streak grid — the Progress page's signature chart.
///
/// Same idea as the paper's own 20px grid and the Habit Tracker's X's, just
/// turned into a calendar: one box per day, shaded by how much of that day's
/// habits got done. An empty box is a day tracked but left blank; a lime box
/// is a perfect day — the same highlight color used for a completed streak
/// elsewhere in the app.
class ConsistencyHeatmap extends StatelessWidget {
  final DateTime startDate; // first day covered, inclusive
  final int days; // how many days, ending today
  final bool weekStartsMonday;
  final double? Function(DateTime day) ratioFor; // null = before tracking began

  const ConsistencyHeatmap({
    super.key,
    required this.startDate,
    required this.days,
    required this.weekStartsMonday,
    required this.ratioFor,
  });

  static const double _slot = 18;
  static const double _box = 14;

  @override
  Widget build(BuildContext context) {
    final t = context.paper;

    // ISO weekday: 1=Mon..7=Sun. Re-index so row 0 is the configured first
    // day of the week.
    int rowFor(DateTime d) {
      final iso = d.weekday - 1; // 0=Mon..6=Sun
      return weekStartsMonday ? iso : (iso + 1) % 7;
    }

    final leadRow = rowFor(startDate);
    final cols = ((leadRow + days) / 7).ceil();
    final dayLabels = weekStartsMonday
        ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
        : const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    // grid[col][row] -> ratio, or null for a day outside [startDate, today].
    final grid = List.generate(cols, (_) => List<double?>.filled(7, null));
    final labeled = List.generate(cols, (_) => false); // month-start marker
    final monthLabel = List.generate(cols, (_) => '');
    for (var i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final cell = leadRow + i;
      final col = cell ~/ 7;
      final row = cell % 7;
      grid[col][row] = ratioFor(date);
      if (date.day == 1 || i == 0) {
        labeled[col] = true;
        monthLabel[col] = _monthAbbrev(date.month);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true, // land scrolled to "today" (the right edge)
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekday labels.
              SizedBox(
                width: 14,
                child: Column(
                  children: [
                    const SizedBox(height: 14), // month-label row
                    for (var r = 0; r < 7; r++)
                      SizedBox(
                        height: _slot,
                        child: Text(dayLabels[r], style: PaperText.small(t.ink, size: 8).copyWith(color: t.ink.withValues(alpha: t.ink.a * .5))),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              for (var c = 0; c < cols; c++)
                SizedBox(
                  width: _slot,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 14,
                        child: labeled[c]
                            ? Text(monthLabel[c], style: PaperText.small(t.ink, size: 8).copyWith(color: t.ink.withValues(alpha: t.ink.a * .5)))
                            : null,
                      ),
                      for (var r = 0; r < 7; r++)
                        SizedBox(
                          height: _slot,
                          width: _slot,
                          child: Center(child: _Cell(ratio: grid[c][r])),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _Legend(),
      ],
    );
  }

  static String _monthAbbrev(int month) => const [
        'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
      ][month - 1];
}

class _Cell extends StatelessWidget {
  final double? ratio;
  const _Cell({required this.ratio});

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    const box = ConsistencyHeatmap._box;

    if (ratio == null) {
      return const SizedBox(width: box, height: box);
    }
    if (ratio == 1) {
      return Container(
        width: box,
        height: box,
        decoration: BoxDecoration(color: t.hi, borderRadius: BorderRadius.circular(3), border: Border.all(color: t.ink, width: 1)),
      );
    }
    if (ratio == 0) {
      return Container(
        width: box,
        height: box,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), border: Border.all(color: t.ink30, width: 1)),
      );
    }
    final fill = ratio! <= .34 ? t.ink30 : (ratio! <= .67 ? t.ink50 : t.ink65);
    return Container(
      width: box,
      height: box,
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(3)),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    Widget swatch(Widget cell) => SizedBox(width: 14, height: 14, child: Center(child: cell));
    return Row(
      children: [
        Text('LESS', style: PaperText.small(t.ink, size: 10).copyWith(color: t.ink.withValues(alpha: t.ink.a * .55))),
        const SizedBox(width: 6),
        swatch(_Cell(ratio: 0)),
        const SizedBox(width: 3),
        swatch(_Cell(ratio: .3)),
        const SizedBox(width: 3),
        swatch(_Cell(ratio: .5)),
        const SizedBox(width: 3),
        swatch(_Cell(ratio: .8)),
        const SizedBox(width: 3),
        swatch(_Cell(ratio: 1)),
        const SizedBox(width: 6),
        Text('MORE', style: PaperText.small(t.ink, size: 10).copyWith(color: t.ink.withValues(alpha: t.ink.a * .55))),
      ],
    );
  }
}
