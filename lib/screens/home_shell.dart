import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/bottom_tab_bar.dart';
import 'habits_screen.dart';
import 'journal_screen.dart';
import 'profile_screen.dart';
import 'sleep_screen.dart';

/// Persistent shell: paper content area (per-tab, instant switch — no
/// transition, per design spec) + fixed bottom tab bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  StreamSubscription<Uri?>? _widgetTaps;

  @override
  void initState() {
    super.initState();
    // Home-screen widgets deep-link to journalinghabits://<tab>.
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_openFromWidget).catchError((_) {});
    _widgetTaps = HomeWidget.widgetClicked.listen(_openFromWidget, onError: (_) {});
  }

  @override
  void dispose() {
    _widgetTaps?.cancel();
    super.dispose();
  }

  void _openFromWidget(Uri? uri) {
    if (uri == null || !mounted) return;
    final tab = switch (uri.host) {
      'journal' => AppTab.journal,
      'habits' => AppTab.habits,
      'sleep' => AppTab.sleep,
      _ => null,
    };
    if (tab != null) context.read<AppState>().setTab(tab);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      body: IndexedStack(
        index: app.tab.index,
        children: const [
          JournalScreen(),
          HabitsScreen(),
          SleepScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomTabBar(tab: app.tab, onSelect: app.setTab),
    );
  }
}
