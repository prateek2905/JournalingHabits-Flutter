import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import 'sleep_aggregator.dart';

/// Where this device keeps its health data — the one place every watch and
/// band (Apple Watch, Galaxy/Pixel Watch, Fitbit, Garmin, WHOOP, Oura…) syncs
/// its sleep to, via that device's own companion app.
enum SleepSourceStatus {
  /// Web / desktop — no health platform to read from.
  unsupported,

  /// Android without the Health Connect app (Android 13 and older, or a
  /// device where it was removed).
  needsHealthConnect,
  ready,
}

/// Reads *sleep and nothing else* from Apple Health (iOS) or Health Connect
/// (Android). Only the sleep data types are ever requested, so the OS
/// permission sheet lists a single "Sleep" item and the app has no access to
/// heart rate, steps, workouts, location or anything else.
class SleepSync {
  static final Health _health = Health();
  static bool _configured = false;

  /// How far back one sync looks. Health Connect only exposes the last 30 days
  /// from the moment access is granted, so there's no point asking for more.
  static const maxLookback = Duration(days: 30);

  static bool get supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static String get platformName => !kIsWeb && Platform.isIOS ? 'APPLE HEALTH' : 'HEALTH CONNECT';

  // Stage types are what both platforms report sleep as. Android's whole-night
  // SLEEP_SESSION is the fallback for watches that don't write stages.
  static List<HealthDataType> get _stageTypes => const [
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_REM,
      ];

  static List<HealthDataType> get _types => [
        ..._stageTypes,
        if (Platform.isAndroid) HealthDataType.SLEEP_SESSION,
      ];

  static Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  static Future<SleepSourceStatus> status() async {
    if (!supported) return SleepSourceStatus.unsupported;
    await _ensureConfigured();
    return await _health.isHealthConnectAvailable() ? SleepSourceStatus.ready : SleepSourceStatus.needsHealthConnect;
  }

  /// Opens the Play Store page for Health Connect (Android only).
  static Future<void> installHealthConnect() => _health.installHealthConnect();

  /// Shows the OS permission sheet for read access to sleep. Returns whether
  /// the request completed — note that iOS never reveals whether read access
  /// was actually granted, so callers should judge by what [fetch] returns.
  static Future<bool> requestAccess() async {
    await _ensureConfigured();
    final types = _types;
    return _health.requestAuthorization(types, permissions: List.filled(types.length, HealthDataAccess.READ));
  }

  /// Drops the app's Health Connect grants. iOS has no API for this — the
  /// user turns access off in Settings ▸ Health ▸ Data Access & Devices.
  static Future<void> revokeAccess() async {
    if (!supported || Platform.isIOS) return;
    await _ensureConfigured();
    await _health.revokePermissions();
  }

  /// Hours slept per night (keyed by wake-up date, local midnight) for every
  /// night whose wake-up date is on or after [since].
  static Future<Map<DateTime, double>> fetch({required DateTime since}) async {
    await _ensureConfigured();
    final now = DateTime.now();
    final floor = now.subtract(maxLookback);
    final fromDay = since.isBefore(floor) ? floor : since;
    final firstDay = DateTime(fromDay.year, fromDay.month, fromDay.day);
    // Start at noon the day before so the night that *ends* on firstDay is
    // included in full.
    final start = firstDay.subtract(const Duration(hours: 12));

    final points = await _health.getHealthDataFromTypes(types: _types, startTime: start, endTime: now);

    final stages = <SleepSpan>[];
    final sessions = <SleepSpan>[];
    for (final p in points) {
      final span = SleepSpan(p.dateFrom.toLocal(), p.dateTo.toLocal());
      (p.type == HealthDataType.SLEEP_SESSION ? sessions : stages).add(span);
    }

    final nights = SleepAggregator.hoursPerNight(stages: stages, sessions: sessions);
    return {
      for (final e in nights.entries)
        if (!e.key.isBefore(firstDay)) e.key: e.value,
    };
  }
}
