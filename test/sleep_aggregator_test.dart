import 'package:flutter_test/flutter_test.dart';
import 'package:journaling_habits/services/sleep_aggregator.dart';

SleepSpan span(int d1, int h1, int m1, int d2, int h2, int m2) =>
    SleepSpan(DateTime(2026, 9, d1, h1, m1), DateTime(2026, 9, d2, h2, m2));

void main() {
  test('a night crossing midnight is keyed to the wake-up date', () {
    final nights = SleepAggregator.hoursPerNight(stages: [span(9, 23, 0, 10, 7, 0)]);
    expect(nights, {DateTime(2026, 9, 10): 8.0});
  });

  test('stages before and after midnight land on the same night', () {
    final nights = SleepAggregator.hoursPerNight(stages: [
      span(9, 22, 30, 10, 0, 30), // 2h before midnight-ish
      span(10, 0, 30, 10, 6, 30), // 6h after
    ]);
    expect(nights, {DateTime(2026, 9, 10): 8.0});
  });

  test('overlapping phone and watch data is not double-counted', () {
    final nights = SleepAggregator.hoursPerNight(stages: [
      span(9, 23, 0, 10, 7, 0), // watch
      span(9, 23, 30, 10, 6, 30), // phone, fully inside
      span(10, 6, 45, 10, 7, 15), // extends 15 min past the watch
    ]);
    expect(nights[DateTime(2026, 9, 10)], 8.3); // 23:00 -> 07:15
  });

  test('daytime naps are ignored', () {
    final nights = SleepAggregator.hoursPerNight(stages: [
      span(9, 23, 0, 10, 6, 0),
      span(10, 14, 0, 10, 15, 30),
    ]);
    expect(nights, {DateTime(2026, 9, 10): 7.0});
  });

  test('very short nights are dropped', () {
    expect(SleepAggregator.hoursPerNight(stages: [span(9, 23, 0, 9, 23, 20)]), isEmpty);
  });

  test('sessions are used only when a night has no stage data', () {
    final nights = SleepAggregator.hoursPerNight(
      stages: [span(9, 23, 0, 10, 6, 0)], // night of the 10th has stages
      sessions: [
        span(9, 22, 0, 10, 7, 0), // ignored: stages win
        span(10, 23, 0, 11, 7, 0), // night of the 11th: session only
      ],
    );
    expect(nights, {DateTime(2026, 9, 10): 7.0, DateTime(2026, 9, 11): 8.0});
  });
}
