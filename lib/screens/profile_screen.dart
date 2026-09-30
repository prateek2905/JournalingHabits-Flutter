import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/paper_painter.dart';
import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';
import '../widgets/callout_card.dart';
import '../widgets/dotted_line.dart';
import '../widgets/header_nav.dart';
import '../widgets/paper_page.dart';
import '../widgets/profile_icon.dart';
import '../widgets/section_header.dart';
import 'progress_screen.dart';

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
                const _ThemeRow(),
                const _PaperStyleRow(),
                for (var i = 0; i < defaultSettingLabels.length; i++)
                  _SettingRow(index: i),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProgressScreen())),
              child: CalloutCard(
                topMargin: 0,
                rotationDeg: -.5,
                line1: 'SEE YOUR PROGRESS',
                line2: 'STREAKS, CHARTS & TRENDS',
                radius: const BorderRadius.only(
                  topLeft: Radius.circular(11), topRight: Radius.circular(14),
                  bottomRight: Radius.circular(12), bottomLeft: Radius.circular(15),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF export is coming in a future update.')),
            ),
            child: CalloutCard(
              rotationDeg: .5,
              line1: 'EXPORT ${month.label} AS PDF',
              line2: 'PRINTS ON GRID PAPER, 1:1',
              radius: const BorderRadius.only(
                topLeft: Radius.circular(14), topRight: Radius.circular(11),
                bottomRight: Radius.circular(15), bottomLeft: Radius.circular(12),
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

/// Picks the paper colorway: one swatch per [PaperTheme].
class _ThemeRow extends StatelessWidget {
  const _ThemeRow();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = context.paper;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
            child: Text('PAGE COLOR · ${app.theme.label}', style: PaperText.body(t.ink)),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              for (final th in PaperTheme.values)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => app.setTheme(th),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: th.tokens.paper1,
                      border: Border.all(
                        color: app.theme == th ? t.ink : t.ink30,
                        width: app.theme == th ? 2.5 : 1.5,
                      ),
                    ),
                    child: app.theme == th
                        ? Center(child: Icon(Icons.check, size: 16, color: th.tokens.ink))
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Picks the notebook ruling used behind every page in the app.
class _PaperStyleRow extends StatelessWidget {
  const _PaperStyleRow();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = context.paper;
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          Text('PAPER', style: PaperText.body(t.ink)),
          const SizedBox(width: 10),
          for (final s in PaperStyle.values)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => app.setPaperStyle(s),
              child: Container(
                height: 18,
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: app.paperStyle == s ? t.hi : null,
                  border: Border.all(color: app.paperStyle == s ? t.ink : t.ink30, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.label,
                  style: PaperText.small(app.paperStyle == s ? t.onHi : t.ink, size: 10),
                ),
              ),
            ),
        ],
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
