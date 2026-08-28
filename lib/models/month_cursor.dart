/// A year+month pointer, independent of any particular day. Used as the
/// per-tab navigation cursor for Habits / Sleep / Profile, and to key
/// [MonthData] in storage.
class MonthCursor implements Comparable<MonthCursor> {
  final int year;
  final int month; // 1-12

  const MonthCursor(this.year, this.month);

  factory MonthCursor.fromDate(DateTime d) => MonthCursor(d.year, d.month);

  factory MonthCursor.fromKey(String key) {
    final parts = key.split('-');
    return MonthCursor(int.parse(parts[0]), int.parse(parts[1]));
  }

  static const _names = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
  ];

  String get key => '$year-${month.toString().padLeft(2, '0')}';

  String get label => '${_names[month - 1]} $year';

  String get shortLabel => '${_names[month - 1].substring(0, 3)} $year';

  String get shortName => _names[month - 1].substring(0, 3);

  int get daysInMonth => DateTime(year, month + 1, 0).day;

  MonthCursor addMonths(int delta) {
    final total = year * 12 + (month - 1) + delta;
    return MonthCursor(total ~/ 12, total % 12 + 1);
  }

  @override
  int compareTo(MonthCursor other) {
    if (year != other.year) return year.compareTo(other.year);
    return month.compareTo(other.month);
  }

  bool operator <(MonthCursor other) => compareTo(other) < 0;
  bool operator >(MonthCursor other) => compareTo(other) > 0;
  bool operator <=(MonthCursor other) => compareTo(other) <= 0;
  bool operator >=(MonthCursor other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) => other is MonthCursor && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => key;
}
