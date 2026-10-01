import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sleep_sync.dart';
import '../state/app_state.dart';
import '../theme/paper_tokens.dart';
import '../theme/text_styles.dart';
import 'pill_button.dart';

/// Short status shown on the right of the SLEEP WATCH settings row.
String sleepWatchStatus(AppState app) {
  if (!app.sleepSyncEnabled) return 'CONNECT';
  if (app.sleepSyncing) return 'SYNCING…';
  if (app.sleepSyncFailed) return 'SYNC FAILED';
  return 'ON · ${SleepSync.platformName}';
}

void showSleepWatchSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SleepWatchSheet(),
  );
}

class _SleepWatchSheet extends StatefulWidget {
  const _SleepWatchSheet();

  @override
  State<_SleepWatchSheet> createState() => _SleepWatchSheetState();
}

class _SleepWatchSheetState extends State<_SleepWatchSheet> {
  bool _busy = false;
  String? _message;
  bool _needsHealthConnect = false;

  Future<void> _connect(AppState app) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final result = await app.connectSleepSource();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _needsHealthConnect = result == SleepConnectResult.needsHealthConnect;
      _message = switch (result) {
        SleepConnectResult.connected => null,
        SleepConnectResult.needsHealthConnect => 'HEALTH CONNECT ISN\'T INSTALLED ON THIS PHONE YET.',
        SleepConnectResult.unsupported => 'WATCH SYNC WORKS ON THE ANDROID AND IPHONE APPS.',
        SleepConnectResult.declined => 'ACCESS WASN\'T GRANTED. YOU CAN TRY AGAIN ANY TIME.',
        SleepConnectResult.failed => 'COULDN\'T READ SLEEP DATA. TRY AGAIN IN A MOMENT.',
      };
    });
  }

  String _lastSyncLabel(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m${d.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = context.paper;
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    final body = PaperText.body(t.ink);
    final soft = body.copyWith(fontSize: 13, color: t.ink.withValues(alpha: t.ink.a * .7));
    final on = app.sleepSyncEnabled;

    final works = ios
        ? 'APPLE WATCH, OR ANY BAND WHOSE APP SHARES SLEEP TO APPLE HEALTH — WHOOP, OURA, GARMIN, FITBIT.'
        : 'GALAXY WATCH, PIXEL WATCH, FITBIT, GARMIN, WHOOP, OURA — ANY BAND WHOSE APP SHARES SLEEP TO HEALTH CONNECT.';
    final prep = ios
        ? 'IN THE HEALTH APP, ALLOW YOUR WATCH\'S APP TO WRITE SLEEP.'
        : 'IN YOUR WATCH\'S APP, TURN ON SHARING SLEEP WITH HEALTH CONNECT.';

    Widget bullet(String text) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 20, child: Text('✕', textAlign: TextAlign.center, style: body.copyWith(fontSize: 14))),
              const SizedBox(width: 6),
              Expanded(child: Text(text, style: soft)),
            ],
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: t.paper1,
        border: Border(top: BorderSide(color: t.ink, width: 2)),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(11)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 20 + MediaQuery.of(context).padding.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SLEEP WATCH', style: PaperText.sectionHeading(t.ink)),
            const SizedBox(height: 8),
            Text('FILL YOUR SLEEP GRID AUTOMATICALLY FROM YOUR WATCH OR BAND.', style: body),
            const SizedBox(height: 8),
            Text(works, style: soft),
            const SizedBox(height: 4),
            Text('FIRST: $prep', style: soft),
            const SizedBox(height: 14),
            Text('YOUR PRIVACY', style: body.copyWith(fontSize: 13, color: t.ink.withValues(alpha: t.ink.a * .6))),
            bullet('SLEEP ONLY. NO HEART RATE, STEPS, WORKOUTS OR LOCATION — NEVER ASKED FOR.'),
            bullet('READ-ONLY. THIS APP NEVER WRITES TO ${SleepSync.platformName}.'),
            bullet('STAYS ON THIS PHONE. NOTHING IS UPLOADED OR SHARED.'),
            bullet('NIGHTS YOU TYPE IN YOURSELF ARE NEVER OVERWRITTEN.'),
            const SizedBox(height: 16),
            if (on) ...[
              Text(
                app.sleepSyncFailed
                    ? 'LAST SYNC FAILED — WILL RETRY WHEN YOU REOPEN THE APP.'
                    : app.lastSleepSync == null
                        ? 'CONNECTED · SYNCING…'
                        : 'CONNECTED · SYNCED ${_lastSyncLabel(app.lastSleepSync!)}',
                style: body,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  PillButton(
                    label: app.sleepSyncing ? 'SYNCING…' : 'SYNC NOW',
                    height: 28,
                    background: t.hiFill,
                    onTap: app.sleepSyncing ? null : () => app.syncSleep(force: true),
                  ),
                  const SizedBox(width: 10),
                  PillButton(
                    label: 'DISCONNECT',
                    height: 28,
                    onTap: () async {
                      await app.disconnectSleepSource();
                      if (!context.mounted) return;
                      setState(() => _message = ios
                          ? 'TO REMOVE ACCESS COMPLETELY: SETTINGS ▸ HEALTH ▸ DATA ACCESS & DEVICES.'
                          : 'NIGHTS ALREADY IMPORTED STAY IN YOUR JOURNAL.');
                    },
                  ),
                ],
              ),
            ] else
              Row(
                children: [
                  PillButton(
                    label: _busy ? 'CONNECTING…' : 'CONNECT ${ios ? 'APPLE HEALTH' : 'HEALTH CONNECT'}',
                    height: 28,
                    background: t.hiFill,
                    onTap: _busy ? null : () => _connect(app),
                  ),
                ],
              ),
            if (_message != null) ...[
              const SizedBox(height: 10),
              Text(_message!, style: soft),
              if (_needsHealthConnect) ...[
                const SizedBox(height: 8),
                PillButton(label: 'GET HEALTH CONNECT', height: 28, onTap: SleepSync.installHealthConnect),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
