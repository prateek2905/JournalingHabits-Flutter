import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/bottom_tab_bar.dart';
import 'habits_screen.dart';
import 'journal_screen.dart';
import 'profile_screen.dart';
import 'sleep_screen.dart';

/// Persistent shell: paper content area (per-tab, instant switch — no
/// transition, per design spec) + fixed bottom tab bar.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

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
