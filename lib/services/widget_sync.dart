import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:home_widget/home_widget.dart';

import '../models/month_cursor.dart';
import '../state/app_state.dart';

/// Pushes a snapshot of the app's data to the native home-screen widgets
/// (Android AppWidgets, iOS WidgetKit). Each widget kind reads one JSON blob
/// that already contains everything it draws — including the current paper
/// colors — so the native side has no logic beyond layout.
class WidgetSync {
  static const appGroupId = 'group.com.prateekmishra.journalingHabits';
  static const _androidPackage = 'com.prateekmishra.journaling_habits';

  /// Widget kind -> (storage key, Android provider class).
  static const _kinds = {
    'HabitsWidget': ('habits_data', 'HabitsWidgetProvider'),
    'JournalWidget': ('journal_data', 'JournalWidgetProvider'),
    'SleepWidget': ('sleep_data', 'SleepWidgetProvider'),
  };

  static const _weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  static bool get _supported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  static bool _groupSet = false;

  static Future<void> update(AppState app) async {
    if (!_supported) return;
    try {
      if (!_groupSet) {
        await HomeWidget.setAppGroupId(appGroupId);
        _groupSet = true;
      }
      final payloads = {
        'HabitsWidget': _habits(app),
        'JournalWidget': _journal(app),
        'SleepWidget': _sleep(app),
      };
      for (final e in _kinds.entries) {
        await HomeWidget.saveWidgetData<String>(e.value.$1, jsonEncode(payloads[e.key]));
        await HomeWidget.updateWidget(
          iOSName: e.key,
          qualifiedAndroidName: '$_androidPackage.${e.value.$2}',
        );
      }
    } catch (e) {
      // Widgets are a nicety; never let them break the app.
      debugPrint('WidgetSync: $e');
    }
  }

  static String _hex(Color c) => '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

  static Map<String, String> _theme(AppState app) {
    final t = app.theme.tokens;
    return {
      'paper': _hex(t.paper1),
      'paper2': _hex(t.paper2),
      'ink': _hex(t.ink),
      'inkSoft': _hex(t.ink60),
      'grid': _hex(t.grid),
      'hi': _hex(t.hi),
      'onHi': _hex(t.onHi),
    };
  }

  static DateTime _daysAgo(int n) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - n);
  }

  static int _marksOn(AppState app, DateTime date) {
    final mo = app.monthDataOrNull(MonthCursor.fromDate(date));
    if (mo == null) return 0;
    final suffix = ':${date.day}';
    var n = 0;
    for (final k in mo.marks) {
      if (!k.endsWith(suffix)) continue;
      final idx = int.tryParse(k.substring(0, k.length - suffix.length));
      if (idx != null && idx < app.habits.length) n++;
    }
    return n;
  }

  static Map<String, dynamic> _habits(AppState app) {
    final total = app.habits.length;
    final day = app.todayDay;
    final mo = app.monthAt(app.todayCursor);
    final dim = app.todayCursor.daysInMonth;

    final counts = <(String, int)>[
      for (var i = 0; i < total; i++) (app.habits[i], mo.habitTotal(i, dim)),
    ]..sort((a, b) => b.$2.compareTo(a.$2));

    var monthMarks = 0;
    for (final c in counts) {
      monthMarks += c.$2;
    }
    final possible = total * day;

    var bestStreak = 0;
    for (var i = 0; i < total; i++) {
      final s = mo.bestStreak(i, dim);
      if (s > bestStreak) bestStreak = s;
    }

    int pct(int marks) => total == 0 ? 0 : (marks * 100 / total).round();

    return {
      'theme': _theme(app),
      'month': app.todayCursor.label,
      'todayDone': _marksOn(app, _daysAgo(0)),
      'todayTotal': total,
      'monthPct': possible == 0 ? 0 : (monthMarks * 100 / possible).round(),
      'monthMarks': monthMarks,
      'bestStreak': bestStreak,
      // Oldest -> newest, last 7 days, each 0-100 % of habits done that day.
      'week': [for (var i = 6; i >= 0; i--) pct(_marksOn(app, _daysAgo(i)))],
      'weekLabels': [for (var i = 6; i >= 0; i--) _weekdays[_daysAgo(i).weekday - 1].substring(0, 1)],
      'top': [
        for (final c in counts.take(5))
          {'name': c.$1, 'count': c.$2, 'pct': day == 0 ? 0 : (c.$2 * 100 / day).round()},
      ],
    };
  }

  static Map<String, dynamic> _journal(AppState app) {
    final now = DateTime.now();
    final mo = app.monthDataOrNull(app.todayCursor);
    final tasks = mo == null ? const [] : mo.tasks.where((t) => t.day == now.day).toList();
    final moments = mo == null ? 0 : mo.moments.where((m) => m.day == now.day).length;
    return {
      'theme': _theme(app),
      'date': '${_weekdays[now.weekday - 1]} · ${app.todayCursor.shortName} ${now.day}',
      'day': now.day,
      'tasksDone': tasks.where((t) => t.done).length,
      'tasksTotal': tasks.length,
      'moments': moments,
      'tasks': [
        for (final t in tasks.take(5)) {'text': t.text, 'done': t.done},
      ],
    };
  }

  static Map<String, dynamic> _sleep(AppState app) {
    // Most recent logged night within the last 14 days.
    (DateTime, double, int)? last;
    for (var i = 0; i < 14 && last == null; i++) {
      final d = _daysAgo(i);
      final night = app.monthDataOrNull(MonthCursor.fromDate(d))?.nights[d.day];
      if (night != null) last = (d, night.hours, night.score);
    }

    final mo = app.monthDataOrNull(app.todayCursor);
    final nights = mo?.nights.values.toList() ?? [];
    final avg = nights.isEmpty ? 0.0 : nights.fold<double>(0, (a, n) => a + n.hours) / nights.length;
    final avgScore = nights.isEmpty ? 0 : (nights.fold<int>(0, (a, n) => a + n.score) / nights.length).round();

    double hoursOn(DateTime d) =>
        app.monthDataOrNull(MonthCursor.fromDate(d))?.nights[d.day]?.hours ?? 0;

    return {
      'theme': _theme(app),
      'hasData': last != null,
      'lastHours': last?.$2 ?? 0,
      'lastScore': last?.$3 ?? 0,
      'lastLabel': last == null ? '' : '${_weekdays[last.$1.weekday - 1]} ${last.$1.day}',
      'avgHours': double.parse(avg.toStringAsFixed(1)),
      'avgScore': avgScore,
      'nightsLogged': nights.length,
      'week': [for (var i = 6; i >= 0; i--) hoursOn(_daysAgo(i))],
      'weekLabels': [for (var i = 6; i >= 0; i--) _weekdays[_daysAgo(i).weekday - 1].substring(0, 1)],
    };
  }
}
