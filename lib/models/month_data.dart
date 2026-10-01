/// A single task on the Journal tab.
class JournalTask {
  final String id;
  final int day;
  String text;
  bool done;

  JournalTask({required this.id, required this.day, required this.text, this.done = false});

  Map<String, dynamic> toJson() => {'id': id, 'day': day, 'text': text, 'done': done};

  factory JournalTask.fromJson(Map json) => JournalTask(
        id: json['id'] as String,
        day: json['day'] as int,
        text: json['text'] as String,
        done: json['done'] as bool,
      );
}

/// A single "memorable moment" on the Journal tab.
class JournalMoment {
  final String id;
  final int day;
  String text;

  JournalMoment({required this.id, required this.day, required this.text});

  Map<String, dynamic> toJson() => {'id': id, 'day': day, 'text': text};

  factory JournalMoment.fromJson(Map json) => JournalMoment(
        id: json['id'] as String,
        day: json['day'] as int,
        text: json['text'] as String,
      );
}

/// One night of recorded sleep.
class SleepNight {
  final int day;
  double hours;
  int score;

  /// True when this night was filled in from the user's watch/band rather than
  /// typed in. Auto-sync refreshes imported nights but never overwrites one the
  /// user entered or corrected by hand.
  final bool imported;

  SleepNight({required this.day, required this.hours, required this.score, this.imported = false});

  Map<String, dynamic> toJson() => {
        'day': day,
        'hours': hours,
        'score': score,
        if (imported) 'imported': true,
      };

  factory SleepNight.fromJson(Map json) => SleepNight(
        day: json['day'] as int,
        hours: (json['hours'] as num).toDouble(),
        score: json['score'] as int,
        imported: json['imported'] as bool? ?? false,
      );

  /// Deterministic score from hours slept — mirrors the design prototype's
  /// formula (minus its random jitter, since real data has no need for it).
  static int scoreFor(double hours) => hours.clamp(0, 24) >= 0
      ? (52 + (hours - 5) * 11).round().clamp(41, 99)
      : 41;
}

/// Everything tracked for one calendar month, keyed by [MonthCursor.key].
class MonthData {
  /// Set of "habitIndex:day" strings — an X on that habit, that day.
  final Set<String> marks;
  final List<JournalTask> tasks;
  final List<JournalMoment> moments;
  final Map<int, SleepNight> nights; // keyed by day
  final Map<int, double> weights; // keyed by day
  String intentions;

  MonthData({
    Set<String>? marks,
    List<JournalTask>? tasks,
    List<JournalMoment>? moments,
    Map<int, SleepNight>? nights,
    Map<int, double>? weights,
    this.intentions = '',
  })  : marks = marks ?? <String>{},
        tasks = tasks ?? [],
        moments = moments ?? [],
        nights = nights ?? {},
        weights = weights ?? {};

  bool hasMark(int habitIndex, int day) => marks.contains('$habitIndex:$day');

  void toggleMark(int habitIndex, int day) {
    final k = '$habitIndex:$day';
    if (marks.contains(k)) {
      marks.remove(k);
    } else {
      marks.add(k);
    }
  }

  int habitTotal(int habitIndex, int daysInMonth) {
    var count = 0;
    for (var d = 1; d <= daysInMonth; d++) {
      if (hasMark(habitIndex, d)) count++;
    }
    return count;
  }

  int bestStreak(int habitIndex, int daysInMonth) {
    var best = 0, run = 0;
    for (var d = 1; d <= daysInMonth; d++) {
      if (hasMark(habitIndex, d)) {
        run++;
        if (run > best) best = run;
      } else {
        run = 0;
      }
    }
    return best;
  }

  Map<String, dynamic> toJson() => {
        'marks': marks.toList(),
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'moments': moments.map((m) => m.toJson()).toList(),
        'nights': nights.values.map((n) => n.toJson()).toList(),
        'weights': weights.map((k, v) => MapEntry(k.toString(), v)),
        'intentions': intentions,
      };

  factory MonthData.fromJson(Map json) {
    final nightsList = (json['nights'] as List? ?? [])
        .map((n) => SleepNight.fromJson(n as Map))
        .toList();
    return MonthData(
      marks: ((json['marks'] as List?) ?? []).cast<String>().toSet(),
      tasks: ((json['tasks'] as List?) ?? []).map((t) => JournalTask.fromJson(t as Map)).toList(),
      moments: ((json['moments'] as List?) ?? []).map((m) => JournalMoment.fromJson(m as Map)).toList(),
      nights: {for (final n in nightsList) n.day: n},
      weights: ((json['weights'] as Map?) ?? {}).map((k, v) => MapEntry(int.parse(k as String), (v as num).toDouble())),
      intentions: json['intentions'] as String? ?? '',
    );
  }
}
