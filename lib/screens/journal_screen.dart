import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/month_cursor.dart';
import '../models/month_data.dart';
import '../state/app_state.dart';
import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';
import '../widgets/add_row.dart';
import '../widgets/header_nav.dart';
import '../widgets/paper_page.dart';
import '../widgets/section_header.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  static const _weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = context.paper;
    final month = app.journalMonth;
    final day = app.journalDay;
    final date = DateTime(month.year, month.month, day);
    final mo = app.monthAt(month);

    final title = '${_weekdays[date.weekday % 7]} $day ${month.shortName}';
    final isToday = app.journalAtToday;
    final subNote = month.label + (isToday ? ' · TODAY' : '');

    final dayTasks = mo.tasks.where((tsk) => tsk.day == day).toList();
    final dayMoments = mo.moments.where((m) => m.day == day).toList();
    final openCount = dayTasks.where((tsk) => !tsk.done).length;

    return PaperPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderNav(
            title: title,
            subNote: subNote,
            onPrev: () => app.goJournalDay(-1),
            onNext: isToday ? null : () => app.goJournalDay(1),
            nextEnabled: !isToday,
          ),
          SectionHeader(heading: 'TASKS', meta: '$openCount OPEN · TAP TO CROSS OFF'),
          if (dayTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: SizedBox(
                height: 20,
                child: Text('NOTHING ON THE LIST FOR THIS DAY',
                    style: PaperText.body(t.ink).copyWith(fontSize: 13, color: t.ink.withValues(alpha: t.ink.a * .4))),
              ),
            )
          else
            ...dayTasks.map((tsk) => _TaskRow(task: tsk, onTap: () => app.toggleTask(tsk))),
          const SizedBox(height: 20),
          AddRow(
            glyph: '□',
            hint: 'add a task…',
            buttonLabel: 'ADD',
            buttonRadius: const BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(9),
              bottomRight: Radius.circular(11), bottomLeft: Radius.circular(10),
            ),
            onSubmit: app.addTask,
          ),
          SectionHeader(
            heading: 'MEMORABLE MOMENTS',
            meta: '${mo.moments.length} IN ${month.shortName}',
            topPadding: 20,
          ),
          if (dayMoments.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: SizedBox(
                height: 20,
                child: Text('NO MOMENT WRITTEN YET',
                    style: PaperText.body(t.ink).copyWith(fontSize: 13, color: t.ink.withValues(alpha: t.ink.a * .4))),
              ),
            )
          else
            ...dayMoments.map((m) => _MomentRow(moment: m, onDelete: () => app.deleteMoment(m))),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: AddRow(
              glyph: '+',
              hint: 'write a moment…',
              buttonLabel: 'ADD',
              height: 40,
              buttonRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(12),
                bottomRight: Radius.circular(9), bottomLeft: Radius.circular(11),
              ),
              onSubmit: app.addMoment,
            ),
          ),
          _IntentionsBlock(month: month, mo: mo),
        ],
      ),
    );
  }
}

class _TaskRow extends StatefulWidget {
  final JournalTask task;
  final VoidCallback onTap;
  const _TaskRow({required this.task, required this.onTap});

  @override
  State<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<_TaskRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    final task = widget.task;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        color: _pressed ? t.hiSoft : null,
        constraints: const BoxConstraints(minHeight: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              child: Text(task.done ? '✕' : '□', textAlign: TextAlign.center, style: PaperText.body(t.ink).copyWith(fontSize: 15)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.text,
                style: task.done
                    ? PaperText.body(t.ink).copyWith(
                        decoration: TextDecoration.lineThrough,
                        decorationThickness: 2,
                        color: t.ink.withValues(alpha: t.ink.a * .42),
                      )
                    : PaperText.body(t.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentRow extends StatefulWidget {
  final JournalMoment moment;
  final VoidCallback onDelete;
  const _MomentRow({required this.moment, required this.onDelete});

  @override
  State<_MomentRow> createState() => _MomentRowState();
}

class _MomentRowState extends State<_MomentRow> {
  bool _pressed = false;
  Timer? _holdTimer;

  void _startHold() {
    setState(() => _pressed = true);
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      widget.onDelete();
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    if (mounted) setState(() => _pressed = false);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: Container(
        color: _pressed ? t.hiSoft : null,
        constraints: const BoxConstraints(minHeight: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              child: Text('·', textAlign: TextAlign.center, style: PaperText.body(t.ink).copyWith(fontSize: 15, color: t.ink.withValues(alpha: t.ink.a * .45))),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.moment.text, style: PaperText.body(t.ink))),
          ],
        ),
      ),
    );
  }
}

class _IntentionsBlock extends StatefulWidget {
  final MonthCursor month;
  final MonthData mo;
  const _IntentionsBlock({required this.month, required this.mo});

  @override
  State<_IntentionsBlock> createState() => _IntentionsBlockState();
}

class _IntentionsBlockState extends State<_IntentionsBlock> {
  late TextEditingController _controller;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.mo.intentions);
  }

  @override
  void didUpdateWidget(covariant _IntentionsBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.mo.intentions != widget.mo.intentions) {
      _controller.text = widget.mo.intentions;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.paper;
    final app = context.read<AppState>();
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: t.ink40, width: 2))),
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.month.label} INTENTIONS',
                style: PaperText.body(t.ink).copyWith(fontSize: 13, letterSpacing: 1, color: t.ink.withValues(alpha: t.ink.a * .6))),
            GestureDetector(
              onTap: () => setState(() => _editing = true),
              child: _editing
                  ? TextField(
                      controller: _controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                      maxLines: null,
                      style: PaperText.body(t.ink),
                      decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                      onSubmitted: (v) {
                        app.setIntentions(widget.month, v);
                        setState(() => _editing = false);
                      },
                      onTapOutside: (_) {
                        app.setIntentions(widget.month, _controller.text);
                        setState(() => _editing = false);
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        widget.mo.intentions.isEmpty ? 'TAP TO SET YOUR INTENTIONS FOR THE MONTH' : widget.mo.intentions,
                        style: PaperText.body(t.ink).copyWith(
                          color: widget.mo.intentions.isEmpty ? t.ink.withValues(alpha: t.ink.a * .4) : t.ink,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
