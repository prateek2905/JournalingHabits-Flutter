import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/month_cursor.dart';
import '../state/app_state.dart';
import '../theme/habit_colors.dart';
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
    final showWeight = app.settingsFlags[2];

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
          SectionHeader(heading: 'HABIT COLORS', meta: 'TAP TO MARK', topPadding: 24),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (var i = 0; i < habits.length; i++) _HabitColorRow(index: i, name: habits[i])],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitColorRow extends StatelessWidget {
  final int index;
  final String name;
  const _HabitColorRow({required this.index, required this.name});

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    final app = context.watch<AppState>();
    final selected = app.habitColor(index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: PaperText.body(t.ink)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ColorSwatch(
                color: null,
                selected: selected == null,
                onTap: () => app.setHabitColor(index, null),
              ),
              for (final c in habitColorPalette)
                _ColorSwatch(
                  color: c,
                  selected: selected == c,
                  onTap: () => app.setHabitColor(index, c),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color? color; // null = "no color" swatch
  final bool selected;
  final VoidCallback onTap;

  const _ColorSwatch({required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: t.ink, width: selected ? 2 : 1),
        ),
        child: color == null
            ? Text('✕', style: PaperText.small(t.ink, size: 11).copyWith(color: t.ink.withValues(alpha: t.ink.a * .5)))
            : (selected ? Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: t.ink)) : null),
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
    final app = context.watch<AppState>();
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
                ...habits.asMap().entries.map((e) {
                  final color = app.habitColor(e.key);
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: () => _showCannotDeleteDialog(context, e.value),
                    child: SizedBox(
                      width: _colW,
                      height: 120,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: SizedBox(
                              height: 20,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (color != null)
                                    Positioned(
                                      left: 4, right: 4, top: 1.5, bottom: 1.5,
                                      child: Transform.rotate(
                                        angle: ((e.key % 3) - 1) * 1.2 * 3.14159265 / 180,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(4), topRight: Radius.circular(7),
                                              bottomRight: Radius.circular(3), bottomLeft: Radius.circular(6),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  Text(e.value, style: PaperText.small(t.ink, size: 11), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
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
