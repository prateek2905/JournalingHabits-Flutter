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
          if (!app.ready) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }
          final tokens = app.dark ? PaperTokens.dark : PaperTokens.light;
          SystemChrome.setSystemUIOverlayStyle(
            app.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          );
          return MaterialApp(
            title: 'Journaling Habits',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: app.dark ? Brightness.dark : Brightness.light,
              scaffoldBackgroundColor: tokens.paper1,
              extensions: [tokens],
            ),
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
