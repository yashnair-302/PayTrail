import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/providers/app_providers.dart';
import 'presentation/screens/home_shell.dart';
import 'presentation/theme.dart';

/// The app shell.
class PayTrailApp extends ConsumerWidget {
  const PayTrailApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched so choosing Light/Dark/System in Settings repaints the whole app.
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'PayTrail',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeMode,
      home: const HomeShell(),
    );
  }
}

/// Shown when the ledger cannot be opened at all.
///
/// The failure modes are real and worth naming: the SQLCipher key was cleared
/// with app data, or the build was not linked against SQLCipher. Either way the
/// app has no data to show, so it says so plainly instead of crashing into a
/// grey screen.
class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayTrail',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  'The ledger could not be opened',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
