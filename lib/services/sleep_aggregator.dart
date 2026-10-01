/// One span of time the health platform says the user was asleep (a sleep
/// stage) or in a sleep session (the whole night, stages not broken out).
class SleepSpan {
  final DateTime start;
  final DateTime end;
  const SleepSpan(this.start, this.end);
}

/// Turns raw spans from Apple Health / Health Connect into one number per
/// night: hours asleep, keyed by the calendar date you woke up on (the same
/// convention Apple Health, Fitbit and Oura use for "last night").
///
/// Pure Dart on purpose — no plugin calls — so the tricky parts (overlapping
/// phone + watch data, midnight crossings, naps) are unit-testable.
class SleepAggregator {
  /// Spans that *start* in this local-hour window are treated as daytime naps
  /// and ignored, so a 3pm nap doesn't get added to the following night.
  static const napStartHour = 12;
  static const napEndHour = 18;

  /// Nights shorter than this are dropped as noise (a watch glitching on for a
  /// few minutes on the couch shouldn't mark a night as logged).
  static const minNight = Duration(minutes: 30);

  /// [stages] are the asleep spans (light/deep/REM/asleep); [sessions] are
  /// whole-night spans used only for nights that have no stage data (many
  /// Android watches write sessions without stages).
  static Map<DateTime, double> hoursPerNight({
    required Iterable<SleepSpan> stages,
    Iterable<SleepSpan> sessions = const [],
  }) {
    final fromStages = _totals(stages);
    final fromSessions = _totals(sessions);
    final result = <DateTime, double>{};
    for (final key in {...fromStages.keys, ...fromSessions.keys}) {
      final total = fromStages[key] ?? fromSessions[key]!;
      if (total < minNight) continue;
      // One decimal place, like the manual entry field in the sleep editor.
      result[key] = (total.inMinutes / 6).round() / 10;
    }
    return result;
  }

  /// Wake-up date a span belongs to. Shifting by 12h maps an evening start
  /// (22:30) and an after-midnight start (01:00) onto the same morning.
  static DateTime _nightKey(DateTime start) {
    final shifted = start.add(const Duration(hours: 12));
    return DateTime(shifted.year, shifted.month, shifted.day);
  }

  static bool _isNap(DateTime start) => start.hour >= napStartHour && start.hour < napEndHour;

  static Map<DateTime, Duration> _totals(Iterable<SleepSpan> spans) {
    final byNight = <DateTime, List<SleepSpan>>{};
    for (final s in spans) {
      if (!s.end.isAfter(s.start) || _isNap(s.start)) continue;
      byNight.putIfAbsent(_nightKey(s.start), () => []).add(s);
    }
    return byNight.map((k, v) => MapEntry(k, _unionLength(v)));
  }

  /// Total covered time of possibly-overlapping spans. Phone and watch often
  /// both report the same night; summing would double-count it.
  static Duration _unionLength(List<SleepSpan> spans) {
    spans.sort((a, b) => a.start.compareTo(b.start));
    var total = Duration.zero;
    DateTime? curStart;
    DateTime? curEnd;
    for (final s in spans) {
      if (curEnd == null || s.start.isAfter(curEnd)) {
        if (curStart != null) total += curEnd!.difference(curStart);
        curStart = s.start;
        curEnd = s.end;
      } else if (s.end.isAfter(curEnd)) {
        curEnd = s.end;
      }
    }
    if (curStart != null) total += curEnd!.difference(curStart);
    return total;
  }
}
