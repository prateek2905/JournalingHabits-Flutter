import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/month_cursor.dart';
import '../models/month_data.dart';

enum AppTab { journal, habits, sleep, profile }

const defaultHabits = [
  'COLD EXPOSURE', 'EXERCISE', 'STRETCHING', 'NO PHONE AM', 'MEDITATION',
  'READ 5 PAGES', 'FLOSS TEETH', 'JOURNAL', 'COFFEE', 'SAUNA',
];

const defaultSettingLabels = [
  'NIGHTLY REMINDER 9:30PM',
  'WEEK STARTS MONDAY',
  'SYNC SLEEP FROM RING',
  'SHOW WEIGHT COLUMN',
];

class AppState extends ChangeNotifier {
  static const _boxName = 'journaling_habits';
  static const _stateKey = 'state';

  late Box _box;
  bool _ready = false;
  bool get ready => _ready;

  AppTab tab = AppTab.journal;

  late MonthCursor journalMonth;
  late int journalDay;
  late MonthCursor habitsMonth;
  late MonthCursor sleepMonth;
  late MonthCursor profileMonth;
  int? selectedNightDay;

  List<String> habits = List.of(defaultHabits);
  List<Color?> habitColors = List<Color?>.filled(defaultHabits.length, null, growable: true);
  final Map<String, MonthData> months = {};

  bool dark = false;
  List<bool> settingsFlags = [true, true, true, false];
  String userName = 'YOU';
  late MonthCursor installMonth;

  late final MonthCursor _todayCursor;
  late final int _todayDay;

  MonthCursor get todayCursor => _todayCursor;
  int get todayDay => _todayDay;

  Timer? _saveDebounce;

  Future<void> init() async {
    final now = DateTime.now();
    _todayCursor = MonthCursor.fromDate(now);
    _todayDay = now.day;
    journalMonth = _todayCursor;
    journalDay = _todayDay;
    habitsMonth = _todayCursor;
    sleepMonth = _todayCursor;
    profileMonth = _todayCursor;
    installMonth = _todayCursor;

    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _load();
    _ready = true;
    notifyListeners();
  }

  void _load() {
    final raw = _box.get(_stateKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      habits = ((json['habits'] as List?) ?? defaultHabits).cast<String>();
      habitColors = ((json['habitColors'] as List?) ?? [])
          .map((v) => v == null ? null : Color(v as int))
          .toList();
      while (habitColors.length < habits.length) {
        habitColors.add(null);
      }
      if (habitColors.length > habits.length) {
        habitColors = habitColors.sublist(0, habits.length);
      }
      dark = json['dark'] as bool? ?? false;
      settingsFlags = ((json['settingsFlags'] as List?) ?? settingsFlags).cast<bool>();
      userName = json['userName'] as String? ?? userName;
      if (json['installMonth'] != null) {
        installMonth = MonthCursor.fromKey(json['installMonth'] as String);
      }
      final monthsJson = (json['months'] as Map?) ?? {};
      monthsJson.forEach((key, value) {
        months[key as String] = MonthData.fromJson(value as Map);
      });
      if (json['journalMonth'] != null) {
        journalMonth = MonthCursor.fromKey(json['journalMonth'] as String);
      }
      journalDay = json['journalDay'] as int? ?? journalDay;
      if (json['habitsMonth'] != null) habitsMonth = MonthCursor.fromKey(json['habitsMonth'] as String);
      if (json['sleepMonth'] != null) sleepMonth = MonthCursor.fromKey(json['sleepMonth'] as String);
      if (json['profileMonth'] != null) profileMonth = MonthCursor.fromKey(json['profileMonth'] as String);
      selectedNightDay = json['selectedNightDay'] as int?;
      // Clamp restored cursors so they never sit beyond "today" (e.g. after
      // a device clock change or restoring an older backup).
      if (journalMonth > _todayCursor) journalMonth = _todayCursor;
      if (habitsMonth > _todayCursor) habitsMonth = _todayCursor;
      if (sleepMonth > _todayCursor) sleepMonth = _todayCursor;
      if (profileMonth > _todayCursor) profileMonth = _todayCursor;
    } catch (e) {
      debugPrint('AppState: failed to load persisted state: $e');
    }
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 300), _save);
  }

  Future<void> _save() async {
    final json = {
      'habits': habits,
      'habitColors': habitColors.map((c) => c?.toARGB32()).toList(),
      'dark': dark,
      'settingsFlags': settingsFlags,
      'userName': userName,
      'installMonth': installMonth.key,
      'journalMonth': journalMonth.key,
      'journalDay': journalDay,
      'habitsMonth': habitsMonth.key,
      'sleepMonth': sleepMonth.key,
      'profileMonth': profileMonth.key,
      'selectedNightDay': selectedNightDay,
      'months': months.map((k, v) => MapEntry(k, v.toJson())),
    };
    await _box.put(_stateKey, jsonEncode(json));
  }

  void _touch() {
    notifyListeners();
    _scheduleSave();
  }

  MonthData monthAt(MonthCursor c) => months.putIfAbsent(c.key, () => MonthData());

  MonthData get currentMonthDataForTab {
    switch (tab) {
      case AppTab.journal:
        return monthAt(journalMonth);
      case AppTab.habits:
        return monthAt(habitsMonth);
      case AppTab.sleep:
        return monthAt(sleepMonth);
      case AppTab.profile:
        return monthAt(profileMonth);
    }
  }

  // ---- Tab / navigation ----

  void setTab(AppTab t) {
    tab = t;
    _touch();
  }

  void goJournalDay(int delta) {
    var m = journalMonth;
    var d = journalDay + delta;
    if (d < 1) {
      m = m.addMonths(-1);
      d = m.daysInMonth;
    } else if (d > m.daysInMonth) {
      m = m.addMonths(1);
      d = 1;
    }
    final target = MonthCursor(m.year, m.month);
    if (target > _todayCursor || (target == _todayCursor && d > _todayDay)) {
      return; // capped at today
    }
    journalMonth = target;
    journalDay = d;
    _touch();
  }

  void goMonth(AppTab t, int delta) {
    MonthCursor cur;
    switch (t) {
      case AppTab.journal:
        return;
      case AppTab.habits:
        cur = habitsMonth;
        break;
      case AppTab.sleep:
        cur = sleepMonth;
        break;
      case AppTab.profile:
        cur = profileMonth;
        break;
    }
    var next = cur.addMonths(delta);
    if (next > _todayCursor) next = _todayCursor;
    switch (t) {
      case AppTab.journal:
        break;
      case AppTab.habits:
        habitsMonth = next;
        break;
      case AppTab.sleep:
        sleepMonth = next;
        selectedNightDay = null;
        break;
      case AppTab.profile:
        profileMonth = next;
        break;
    }
    _touch();
  }

  bool get journalAtToday => journalMonth == _todayCursor && journalDay == _todayDay;

  bool monthAtToday(MonthCursor c) => c == _todayCursor;

  // ---- Journal: tasks ----

  int _idCounter = 0;
  String _newId() => '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  void addTask(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    monthAt(journalMonth).tasks.add(JournalTask(id: _newId(), day: journalDay, text: t.toUpperCase()));
    _touch();
  }

  void toggleTask(JournalTask task) {
    task.done = !task.done;
    _touch();
  }

  // ---- Journal: moments ----

  void addMoment(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    monthAt(journalMonth).moments.add(JournalMoment(id: _newId(), day: journalDay, text: t.toUpperCase()));
    _touch();
  }

  void deleteMoment(JournalMoment moment) {
    monthAt(journalMonth).moments.removeWhere((m) => m.id == moment.id);
    _touch();
  }

  void setIntentions(MonthCursor month, String text) {
    monthAt(month).intentions = text.toUpperCase();
    _touch();
  }

  // ---- Habits ----

  void addHabit(String name) {
    final t = name.trim();
    if (t.isEmpty) return;
    habits.add(t.toUpperCase());
    habitColors.add(null);
    _touch();
  }

  /// The highlighter color a habit's been tagged with, or null if untagged.
  Color? habitColor(int habitIndex) =>
      habitIndex >= 0 && habitIndex < habitColors.length ? habitColors[habitIndex] : null;

  void setHabitColor(int habitIndex, Color? color) {
    if (habitIndex < 0 || habitIndex >= habitColors.length) return;
    habitColors[habitIndex] = color;
    _touch();
  }

  void toggleHabitCell(int habitIndex, int day) {
    monthAt(habitsMonth).toggleMark(habitIndex, day);
    _touch();
  }

  void setWeight(int day, double? value) {
    final mo = monthAt(habitsMonth);
    if (value == null) {
      mo.weights.remove(day);
    } else {
      mo.weights[day] = value;
    }
    _touch();
  }

  // ---- Sleep ----

  void logSleep(int day, double hours) {
    final mo = monthAt(sleepMonth);
    final score = SleepNight.scoreFor(hours);
    mo.nights[day] = SleepNight(day: day, hours: hours, score: score);
    selectedNightDay = day;
    _touch();
  }

  void selectNight(int day) {
    selectedNightDay = day;
    _touch();
  }

  // ---- Profile / settings ----

  void toggleDark() {
    dark = !dark;
    _touch();
  }

  void toggleSetting(int index) {
    settingsFlags[index] = !settingsFlags[index];
    _touch();
  }

  void setUserName(String name) {
    final t = name.trim();
    if (t.isEmpty) return;
    userName = t.toUpperCase();
    _touch();
  }

  // ---- Aggregates ----

  int totalMomentsAllTime() => months.values.fold(0, (a, m) => a + m.moments.length);

  int monthsKept() => months.values.where((m) =>
      m.tasks.isNotEmpty || m.moments.isNotEmpty || m.marks.isNotEmpty || m.nights.isNotEmpty).length;

  /// Read-only month lookup — unlike [monthAt], never creates an entry.
  /// Safe to call for arbitrary past months while aggregating history.
  MonthData? monthDataOrNull(MonthCursor c) => months[c.key];

  /// Total X's ever logged, across every month.
  int allTimeMarksTotal() => months.values.fold(0, (a, m) => a + m.marks.length);

  /// Longest run of consecutive days for one habit, across all months (each
  /// month's streak resets at the month boundary, same as the per-month
  /// figure shown on the Habits tab — this just takes the best of those).
  int allTimeBestStreak(int habitIndex) {
    var best = 0;
    months.forEach((key, mo) {
      final s = mo.bestStreak(habitIndex, MonthCursor.fromKey(key).daysInMonth);
      if (s > best) best = s;
    });
    return best;
  }

  /// Longest streak of any single habit, across all habits and all months.
  int allTimeBestStreakOverall() =>
      habits.asMap().keys.fold(0, (best, i) => allTimeBestStreak(i) > best ? allTimeBestStreak(i) : best);
}
