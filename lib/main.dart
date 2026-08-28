import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'state/app_state.dart';
import 'theme/paper_tokens.dart';

void main() {
  runApp(const JournalingHabitsApp());
}

class JournalingHabitsApp extends StatelessWidget {
  const JournalingHabitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState()..init(),
      child: Consumer<AppState>(
        builder: (context, app, _) {
          final tokens = app.ready && app.dark ? PaperTokens.dark : PaperTokens.light;
          if (app.ready) {
            SystemChrome.setSystemUIOverlayStyle(
              app.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            );
          }
          return MaterialApp(
            title: 'Journaling Habits',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: tokens == PaperTokens.dark ? Brightness.dark : Brightness.light,
              scaffoldBackgroundColor: tokens.paper1,
              extensions: [tokens],
            ),
            home: app.ready
                ? const HomeShell()
                : Scaffold(backgroundColor: tokens.paper1, body: const Center(child: CircularProgressIndicator())),
          );
        },
      ),
    );
  }
}
