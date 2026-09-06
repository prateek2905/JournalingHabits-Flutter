import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/month_cursor.dart';
import '../state/app_state.dart';
import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';
import '../widgets/consistency_heatmap.dart';
import '../widgets/monthly_bars_chart.dart';
import '../widgets/paper_page.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_header.dart';
import '../widgets/trend_line_chart.dart';

/// Full-history view of habits and sleep — charts and streaks pulled from
/// every month ever kept, not just the one on screen. Reached from the
/// Profile tab; pushed rather than a fifth bottom tab, since it's a
/// drill-down rather than a place you log anything.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = context.paper;

    final today = DateTime(app.todayCursor.year, app.todayCursor.month, app.todayDay);
    final installDate = DateTime(app.installMonth.year, app.installMonth.month, 1);

    // ---- Consistency heatmap: last 98 days ----
    const heatmapDays = 98;
    final heatmapStart = today.subtract(const Duration(days: heatmapDays - 1));
    double? ratioFor(DateTime date) {
      if (date.isBefore(installDate)) return null;
      if (app.habits.isEmpty) return 0;
      final mo = app.monthDataOrNull(MonthCursor.fromDate(date));
      if (mo == null) return 0;
      var count = 0;
      for (var i = 0; i < app.habits.length; i++) {
        if (mo.hasMark(i, date.day)) count++;
      }
      return count / app.habits.length;
    }

    // ---- Last 6 months, oldest first ----
    final monthCursors = List.generate(6, (i) => app.todayCursor.addMonths(i - 5));
    final monthLabels = monthCursors.map((c) => c.shortName).toList();
    final monthTotals = monthCursors.map((c) => app.monthDataOrNull(c)?.marks.length ?? 0).toList();

    final sleepAvgs = monthCursors.map((c) {
      final mo = app.monthDataOrNull(c);
      if (mo == null || mo.nights.isEmpty) return null;
      return mo.nights.values.map((n) => n.hours).reduce((a, b) => a + b) / mo.nights.length;
    }).toList();
    final hasSleepData = sleepAvgs.any((v) => v != null);

    // ---- Best streak per habit, all time ----
    final streaks = app.habits.asMap().entries.map((e) => (e.value, app.allTimeBestStreak(e.key), app.habitColor(e.key))).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    final maxStreak = streaks.isEmpty ? 0 : streaks.first.$2;

    final notebooks = app.monthsKept();
    final totalXs = app.allTimeMarksTotal();
    final longest = app.allTimeBestStreakOverall();

    return PaperPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProgressHeader(),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                PillButton(
                  label: '$notebooks NOTEBOOKS KEPT',
                  rotationDeg: -.6,
                  radius: const BorderRadius.only(
                    topLeft: Radius.circular(13), topRight: Radius.circular(10),
                    bottomRight: Radius.circular(14), bottomLeft: Radius.circular(11),
                  ),
                ),
                PillButton(
                  label: "$totalXs X'S ALL TIME",
                  background: t.hiFill,
                  rotationDeg: .5,
                  radius: const BorderRadius.only(
                    topLeft: Radius.circular(10), topRight: Radius.circular(14),
                    bottomRight: Radius.circular(11), bottomLeft: Radius.circular(13),
                  ),
                ),
                PillButton(
                  label: '$longest DAY LONGEST STREAK',
                  rotationDeg: -.4,
                  radius: const BorderRadius.only(
                    topLeft: Radius.circular(14), topRight: Radius.circular(11),
                    bottomRight: Radius.circular(13), bottomLeft: Radius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          SectionHeader(heading: 'CONSISTENCY', meta: 'LAST 14 WEEKS', topPadding: 24),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ConsistencyHeatmap(
              startDate: heatmapStart,
              days: heatmapDays,
              weekStartsMonday: app.settingsFlags[1],
              ratioFor: ratioFor,
            ),
          ),
          SectionHeader(heading: "MONTHLY X'S", meta: 'LAST 6 MONTHS', topPadding: 24),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: MonthlyBarsChart(labels: monthLabels, values: monthTotals, highlightIndex: monthLabels.length - 1),
          ),
          SectionHeader(heading: 'BEST STREAKS', meta: 'ALL TIME', topPadding: 24),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                for (final s in streaks) _StreakRow(name: s.$1, days: s.$2, maxDays: maxStreak, color: s.$3),
              ],
            ),
          ),
          SectionHeader(heading: 'SLEEP TREND', meta: hasSleepData ? 'AVG HOURS / MONTH' : 'NO DATA YET', topPadding: 24),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 4, right: 4),
            child: hasSleepData
                ? TrendLineChart(
                    labels: monthLabels,
                    values: sleepAvgs,
                    loValue: 4,
                    hiValue: 10,
                    formatValue: (v) => '${v.toStringAsFixed(1)}h',
                  )
                : Text('LOG A NIGHT ON THE SLEEP TAB TO START THIS CHART.',
                    style: PaperText.body(t.ink).copyWith(fontSize: 13, color: t.ink.withValues(alpha: t.ink.a * .4))),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    final app = context.watch<AppState>();
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BackButton(onTap: () => Navigator.of(context).pop()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: -.5 * 3.14159265 / 180,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('PROGRESS', style: PaperText.title(t.ink), maxLines: 1, overflow: TextOverflow.visible),
                      Container(height: 2, color: t.ink, margin: const EdgeInsets.only(top: 2)),
                    ],
                  ),
                ),
                Text('ALL-TIME · SINCE ${app.installMonth.label}', style: PaperText.subNote(t.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _pressed = false;
  static const _radius = BorderRadius.only(
    topLeft: Radius.circular(14),
    topRight: Radius.circular(5),
    bottomRight: Radius.circular(4),
    bottomLeft: Radius.circular(13),
  );

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        width: 28,
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(borderRadius: _radius, color: _pressed ? t.hi : null),
        foregroundDecoration: BoxDecoration(border: Border.all(color: t.ink, width: 2), borderRadius: _radius),
        child: Text('‹', style: PaperText.navArrow(_pressed ? t.onHi : t.ink)),
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  final String name;
  final int days;
  final int maxDays;
  final Color? color; // the habit's tagged highlighter color, if any

  const _StreakRow({required this.name, required this.days, required this.maxDays, this.color});

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    final frac = maxDays == 0 ? 0.0 : days / maxDays;
    final isTop = days == maxDays && days > 0;
    final fill = color == null
        ? (isTop ? t.hi : t.hiFill)
        : color!.withValues(alpha: isTop ? 1 : .45);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 20,
        child: Row(
          children: [
            SizedBox(
              width: 108,
              child: Text(name, style: PaperText.body(t.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(height: 10, decoration: BoxDecoration(border: Border.all(color: t.ink30, width: 1), borderRadius: BorderRadius.circular(5))),
                  FractionallySizedBox(
                    widthFactor: frac.clamp(0.0, 1.0),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: fill,
                        border: Border.all(color: t.ink, width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 46,
              child: Text('$days D', textAlign: TextAlign.right, style: PaperText.small(t.ink, size: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
