import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';
import '../widgets/callout_card.dart';
import '../widgets/dotted_line.dart';
import '../widgets/header_nav.dart';
import '../widgets/paper_page.dart';
import '../widgets/profile_icon.dart';
import '../widgets/section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = context.paper;
    final month = app.profileMonth;
    final mo = app.monthAt(month);
    final isCurrent = app.monthAtToday(month);

    final subNote = isCurrent
        ? 'DAY ${app.todayDay} · IN PROGRESS'
        : 'ARCHIVED · ${mo.marks.length} X\'S';

    final daysInMonth = month.daysInMonth;
    final bestStreak = app.habits.asMap().entries.fold<int>(
        0, (best, e) => mo.bestStreak(e.key, daysInMonth) > best ? mo.bestStreak(e.key, daysInMonth) : best);
    final avgSleep = mo.nights.isEmpty ? 0.0 : mo.nights.values.map((n) => n.hours).reduce((a, b) => a + b) / mo.nights.length;
    final notebooks = app.monthsKept();
    final entries = app.totalMomentsAllTime();

    final rows = [
      ('BEST STREAK, ${month.shortName}', '$bestStreak DAYS'),
      ("X'S IN ${month.shortName}", '${mo.marks.length}'),
      ('MOMENTS IN ${month.shortName}', '${mo.moments.length}'),
      ('AVG SLEEP, ${month.shortName}', '${avgSleep.toStringAsFixed(1)}H'),
      ('MONTHS KEPT', '$notebooks'),
    ];

    return PaperPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderNav(
            title: month.label,
            subNote: subNote,
            onPrev: () => app.goMonth(AppTab.profile, -1),
            onNext: isCurrent ? null : () => app.goMonth(AppTab.profile, 1),
            nextEnabled: !isCurrent,
          ),
          SectionHeader(heading: 'ME', meta: 'SINCE ${app.installMonth.label}'),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ProfileIcon(size: 60, glyphColor: t.ink, borderColor: t.ink, borderWidth: 2, background: t.hiSoft),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _editName(context, app),
                        child: Text(app.userName, style: PaperText.name(t.ink)),
                      ),
                      Text(
                        '$notebooks NOTEBOOKS · $entries ENTRIES',
                        style: PaperText.body(t.ink).copyWith(fontSize: 13, color: t.ink.withValues(alpha: t.ink.a * .65)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: rows
                  .map((r) => SizedBox(
                        height: 20,
                        child: Row(
                          children: [
                            Text(r.$1, style: PaperText.body(t.ink)),
                            const SizedBox(width: 8),
                            Expanded(child: DottedLine(color: t.ink30)),
                            const SizedBox(width: 8),
                            Text(r.$2, style: PaperText.body(t.ink)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SETTINGS',
                    style: PaperText.body(t.ink).copyWith(fontSize: 13, color: t.ink.withValues(alpha: t.ink.a * .6))),
                _DarkModeRow(),
                for (var i = 0; i < defaultSettingLabels.length; i++)
                  _SettingRow(index: i),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF export is coming in a future update.')),
              ),
              child: CalloutCard(
                topMargin: 0,
                rotationDeg: .5,
                line1: 'EXPORT ${month.label} AS PDF',
                line2: 'PRINTS ON GRID PAPER, 1:1',
                radius: const BorderRadius.only(
                  topLeft: Radius.circular(14), topRight: Radius.circular(11),
                  bottomRight: Radius.circular(15), bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context, AppState app) {
    final controller = TextEditingController(text: app.userName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(controller: controller, autofocus: true, textCapitalization: TextCapitalization.words),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              app.setUserName(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _DarkModeRow extends StatelessWidget {
  const _DarkModeRow();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = context.paper;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: app.toggleDark,
      child: SizedBox(
        height: 20,
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Center(
                child: Container(
                  width: 32,
                  height: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  alignment: app.dark ? Alignment.centerRight : Alignment.centerLeft,
                  decoration: BoxDecoration(border: Border.all(color: t.ink, width: 1.5), borderRadius: BorderRadius.circular(8)),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: app.dark ? t.hi : t.ink),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text('DARK MODE · ${app.dark ? "ON" : "OFF"}', style: PaperText.body(t.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final int index;
  const _SettingRow({required this.index});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = context.paper;
    final on = app.settingsFlags[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => app.toggleSetting(index),
      child: SizedBox(
        height: 20,
        child: Row(
          children: [
            SizedBox(width: 20, child: Text(on ? '✕' : '', textAlign: TextAlign.center, style: PaperText.body(t.ink).copyWith(fontSize: 15))),
            const SizedBox(width: 8),
            Text(defaultSettingLabels[index], style: PaperText.body(t.ink)),
          ],
        ),
      ),
    );
  }
}
