import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/month_cursor.dart';
import '../models/month_data.dart';
import '../state/app_state.dart';
import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';
import '../widgets/callout_card.dart';
import '../widgets/header_nav.dart';
import '../widgets/paper_page.dart';
import '../widgets/section_header.dart';
import '../widgets/sleep_chart_painter.dart';

const double _plotWidth = 280;
const double _loHours = 4;
const double _hiHours = 10;

double _xFor(double hours) {
  final clamped = hours.clamp(_loHours, _hiHours);
  return (clamped - _loHours) / (_hiHours - _loHours) * (_plotWidth - 8) + 4;
}

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = context.paper;
    final month = app.sleepMonth;
    final mo = app.monthAt(month);
    final isCurrent = app.monthAtToday(month);

    final subNote = isCurrent
        ? 'DAY ${app.todayDay} · IN PROGRESS'
        : 'ARCHIVED · ${mo.marks.length} X\'S';

    final daysInMonth = month.daysInMonth;
    final nightsSorted = mo.nights.values.toList()..sort((a, b) => a.day.compareTo(b.day));
    final avg = nightsSorted.isEmpty ? 0.0 : nightsSorted.map((n) => n.hours).reduce((a, b) => a + b) / nightsSorted.length;

    final selDay = app.selectedNightDay ?? (nightsSorted.isNotEmpty ? nightsSorted.last.day : null);
    final sel = selDay == null ? null : mo.nights[selDay];

    return PaperPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderNav(
            title: month.label,
            subNote: subNote,
            onPrev: () => app.goMonth(AppTab.sleep, -1),
            onNext: isCurrent ? null : () => app.goMonth(AppTab.sleep, 1),
            nextEnabled: !isCurrent,
          ),
          SectionHeader(heading: 'SLEEP', meta: 'AVG ${avg.toStringAsFixed(1)}h'),
          SizedBox(
            height: 20,
            child: Row(
              children: [
                const SizedBox(width: 20),
                SizedBox(
                  width: _plotWidth,
                  height: 20,
                  child: Stack(
                    children: [
                      for (var v = 4; v <= 10; v++)
                        Positioned(
                          left: _xFor(v.toDouble()) - 8,
                          top: 0,
                          width: 16,
                          child: Text(
                            v.toString(),
                            textAlign: TextAlign.center,
                            style: PaperText.small(t.ink, size: 10).copyWith(color: t.ink.withValues(alpha: t.ink.a * .6)),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text('SCORE', textAlign: TextAlign.right, style: PaperText.small(t.ink, size: 10).copyWith(color: t.ink.withValues(alpha: t.ink.a * .6))),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                child: Column(
                  children: [
                    for (var d = 1; d <= daysInMonth; d++)
                      SizedBox(
                        height: 20,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(d.toString(), style: PaperText.small(t.ink, size: 10).copyWith(color: t.ink.withValues(alpha: t.ink.a * .6))),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: _plotWidth,
                height: daysInMonth * 20.0,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: SleepChartPainter(nights: nightsSorted, xFor: _xFor, ink: t.ink),
                      ),
                    ),
                    Positioned(top: 0, bottom: 0, left: 0, child: Container(width: 2, color: t.ink60)),
                    Positioned(top: 0, bottom: 0, right: 0, child: Container(width: 2, color: t.ink50)),
                    for (var d = 1; d <= daysInMonth; d++)
                      Positioned(
                        top: (d - 1) * 20.0,
                        left: 0,
                        right: 0,
                        height: 20,
                        child: _NightRow(
                          month: month,
                          day: d,
                          night: mo.nights[d],
                          selected: d == selDay,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    for (var d = 1; d <= daysInMonth; d++)
                      SizedBox(
                        height: 20,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            mo.nights[d]?.score.toString() ?? '—',
                            style: PaperText.small(t.ink, size: 11).copyWith(color: t.ink.withValues(alpha: t.ink.a * .75)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (sel != null)
            CalloutCard(
              rotationDeg: -.6,
              line1: '${month.shortName} ${sel.day} · ${sel.hours}H · SCORE ${sel.score}',
              line2: sel.hours >= 8
                  ? 'SOLID NIGHT. WOKE UP EASY.'
                  : sel.hours >= 7
                      ? 'DECENT. COULD GO TO BED EARLIER.'
                      : 'SHORT ONE — LATE EDIT SESSION.',
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text('TAP A NIGHT TO LOG YOUR SLEEP',
                  style: PaperText.body(t.ink).copyWith(fontSize: 13, color: t.ink.withValues(alpha: t.ink.a * .4))),
            ),
        ],
      ),
    );
  }
}

class _NightRow extends StatefulWidget {
  final MonthCursor month;
  final int day;
  final SleepNight? night;
  final bool selected;

  const _NightRow({required this.month, required this.day, required this.night, required this.selected});

  @override
  State<_NightRow> createState() => _NightRowState();
}

class _NightRowState extends State<_NightRow> {
  bool _pressed = false;

  void _onTap(BuildContext context) {
    final app = context.read<AppState>();
    if (widget.night != null) {
      app.selectNight(widget.day);
    } else {
      _openEditor(context, app);
    }
  }

  void _openEditor(BuildContext context, AppState app) {
    final controller = TextEditingController(text: widget.night?.hours.toString() ?? '');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sleep — ${widget.month.shortName} ${widget.day}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: 'hours'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              if (v != null) app.logSleep(widget.day, v);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(context),
      onLongPress: widget.night == null ? null : () => _openEditor(context, context.read<AppState>()),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(color: _pressed ? t.hiSoft : null),
    );
  }
}
