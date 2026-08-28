import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/month_cursor.dart';
import '../state/app_state.dart';
import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';
import '../widgets/add_row.dart';
import '../widgets/header_nav.dart';
import '../widgets/paper_page.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_header.dart';

const _marks = ['✕', '×', '✗'];
const double _colW = 20;
const double _weightColW = 40;

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = context.paper;
    final month = app.habitsMonth;
    final mo = app.monthAt(month);
    final isCurrent = app.monthAtToday(month);
    final showWeight = app.settingsFlags[3];

    final subNote = isCurrent
        ? 'DAY ${app.todayDay} · IN PROGRESS'
        : 'ARCHIVED · ${mo.marks.length} X\'S';

    final daysInMonth = month.daysInMonth;
    final lastDay = isCurrent ? app.todayDay : daysInMonth;
    final habits = app.habits;

    final bestStreak = habits.asMap().entries.fold<int>(
        0, (best, e) => mo.bestStreak(e.key, daysInMonth) > best ? mo.bestStreak(e.key, daysInMonth) : best);
    final todayCount = habits.asMap().entries.where((e) => mo.hasMark(e.key, lastDay)).length;

    return PaperPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderNav(
            title: month.label,
            subNote: subNote,
            onPrev: () => app.goMonth(AppTab.habits, -1),
            onNext: isCurrent ? null : () => app.goMonth(AppTab.habits, 1),
            nextEnabled: !isCurrent,
          ),
          SectionHeader(heading: 'HABIT TRACKER', meta: 'TAP TO X'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _HabitTable(
              month: month,
              habits: habits,
              daysInMonth: daysInMonth,
              lastDay: lastDay,
              showWeight: showWeight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: AddRow(
              glyph: null,
              hint: 'new habit…',
              buttonLabel: '+ HABIT',
              height: 40,
              buttonRadius: const BorderRadius.only(
                topLeft: Radius.circular(11), topRight: Radius.circular(9),
                bottomRight: Radius.circular(12), bottomLeft: Radius.circular(10),
              ),
              onSubmit: app.addHabit,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                PillButton(
                  label: "${mo.marks.length} X'S THIS MONTH",
                  background: t.hiFill,
                  rotationDeg: -.7,
                  radius: const BorderRadius.only(
                    topLeft: Radius.circular(13), topRight: Radius.circular(10),
                    bottomRight: Radius.circular(14), bottomLeft: Radius.circular(11),
                  ),
                ),
                PillButton(
                  label: 'BEST STREAK $bestStreak DAYS',
                  rotationDeg: .6,
                  radius: const BorderRadius.only(
                    topLeft: Radius.circular(10), topRight: Radius.circular(14),
                    bottomRight: Radius.circular(11), bottomLeft: Radius.circular(13),
                  ),
                ),
                PillButton(
                  label: 'TODAY $todayCount/${habits.length} DONE',
                  rotationDeg: -.4,
                  radius: const BorderRadius.only(
                    topLeft: Radius.circular(14), topRight: Radius.circular(11),
                    bottomRight: Radius.circular(13), bottomLeft: Radius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitTable extends StatelessWidget {
  final MonthCursor month;
  final List<String> habits;
  final int daysInMonth;
  final int lastDay;
  final bool showWeight;

  const _HabitTable({
    required this.month,
    required this.habits,
    required this.daysInMonth,
    required this.lastDay,
    required this.showWeight,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    final tableWidth = _colW + (showWeight ? _weightColW : 0) + _colW * habits.length;

    return SizedBox(
      width: tableWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column-label header, 120px tall.
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(width: _colW),
                if (showWeight)
                  SizedBox(
                    width: _weightColW,
                    height: 120,
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text('WEIGHT KG', style: PaperText.small(t.ink, size: 11).copyWith(letterSpacing: .6), overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                ...habits.map((name) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () => _showCannotDeleteDialog(context, name),
                      child: SizedBox(
                        width: _colW,
                        height: 120,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(name, style: PaperText.small(t.ink, size: 11), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          Consumer<AppState>(
            builder: (context, app, _) {
              return Stack(
                children: [
                  Column(
                    children: [
                      for (var d = 1; d <= daysInMonth; d++)
                        _DayRow(month: month, day: d, habits: habits, showWeight: showWeight, isFuture: d > lastDay),
                      _TotalRow(month: month, habits: habits, daysInMonth: daysInMonth, showWeight: showWeight),
                    ],
                  ),
                  Positioned(top: 0, left: 0, right: 0, child: Container(height: 2, color: t.ink65)),
                  Positioned(top: daysInMonth * 20.0, left: 0, right: 0, child: Container(height: 2, color: t.ink65)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCannotDeleteDialog(BuildContext context, String habitName) {
    HapticFeedback.mediumImpact();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nice try.'),
        content: const Text(
          "Not going to let you delete a habit just because you couldn't do it and now "
          "you're deleting it cuz you're ashamed of the commitment you made.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final MonthCursor month;
  final int day;
  final List<String> habits;
  final bool showWeight;
  final bool isFuture;

  const _DayRow({required this.month, required this.day, required this.habits, required this.showWeight, required this.isFuture});

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    final app = context.watch<AppState>();
    final mo = app.monthAt(month);
    final weight = mo.weights[day];

    return SizedBox(
      height: 20,
      child: Opacity(
        opacity: isFuture ? .35 : 1,
        child: Row(
          children: [
            SizedBox(
              width: _colW,
              child: Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Text(day.toString(), textAlign: TextAlign.right, style: PaperText.small(t.ink)),
              ),
            ),
            if (showWeight)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isFuture ? null : () => _editWeight(context, app, day, weight),
                child: Container(
                  width: _weightColW,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border.symmetric(vertical: BorderSide(color: t.ink50, width: 2))),
                  child: Text(weight != null ? weight.toStringAsFixed(1) : '—', style: PaperText.small(t.ink)),
                ),
              ),
            ...habits.asMap().entries.map((e) {
              final hix = e.key;
              final has = mo.hasMark(hix, day);
              final mark = has ? _marks[(hix + day) % 3] : '';
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isFuture ? null : () => app.toggleHabitCell(hix, day),
                child: _HabitCell(mark: mark),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _editWeight(BuildContext context, AppState app, int day, double? current) {
    final controller = TextEditingController(text: current?.toStringAsFixed(1) ?? '');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Weight — day $day'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: 'kg'),
        ),
        actions: [
          if (current != null)
            TextButton(
              onPressed: () {
                app.setWeight(day, null);
                Navigator.pop(ctx);
              },
              child: const Text('Clear'),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              if (v != null) app.setWeight(day, v);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _HabitCell extends StatelessWidget {
  final String mark;
  const _HabitCell({required this.mark});

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return SizedBox(
      width: _colW,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: RotationTransition(
              turns: Tween<double>(begin: -14 / 360, end: 0).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
          ),
          child: Text(mark, key: ValueKey(mark), style: PaperText.gridMark(t.ink)),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final MonthCursor month;
  final List<String> habits;
  final int daysInMonth;
  final bool showWeight;

  const _TotalRow({required this.month, required this.habits, required this.daysInMonth, required this.showWeight});

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    final app = context.watch<AppState>();
    final mo = app.monthAt(month);

    return SizedBox(
      height: 20,
      child: Row(
        children: [
          const SizedBox(width: _colW),
          if (showWeight)
            Container(
              width: _weightColW,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.symmetric(vertical: BorderSide(color: t.ink50, width: 2))),
              child: Text('TOTAL', style: PaperText.small(t.ink, size: 10).copyWith(color: t.ink.withValues(alpha: t.ink.a * .55))),
            ),
          ...habits.asMap().entries.map((e) => SizedBox(
                width: _colW,
                child: Center(child: Text(mo.habitTotal(e.key, daysInMonth).toString(), style: PaperText.small(t.ink, size: 12))),
              )),
        ],
      ),
    );
  }
}
