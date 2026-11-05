import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/ingest/payment_event.dart';
import '../../domain/repositories/ingest_repository.dart';
import '../providers/app_providers.dart';
import 'client_list_screen.dart';
import 'dashboard_screen.dart';
import 'data_sources_screen.dart';
import 'reminders_screen.dart';
import 'review_queue_screen.dart';
import 'settings_screen.dart';

/// The app's four destinations.
///
/// Dashboard first: the reason the app exists is the answer to "how much am I
/// owed", and it should be the first thing on screen rather than something to
/// navigate to.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  int _index = 0;
  StreamSubscription<PaymentEvent>? _liveNotifications;

  static const List<Widget> _destinations = <Widget>[
    DashboardScreen(),
    ClientListScreen(),
    RemindersScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Deferred to the first frame so the providers are ready and a failure here
    // cannot stop the UI from appearing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _collectNotifications();
      _listenForLiveNotifications();
      _syncEmail();
    });
  }

  @override
  void dispose() {
    _liveNotifications?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The listener service keeps running while the app is backgrounded, so
    // anything it captured is collected on the way back in.
    if (state == AppLifecycleState.resumed) {
      _collectNotifications();
      _syncEmail();
    }
  }

  /// Scans Gmail for new payment mail automatically, so the user never has to
  /// tap "Check now". Runs on launch and on every resume, but throttled: a
  /// network round-trip on each resume would be wasteful, so it only runs when
  /// the last scan was a while ago. A failure is swallowed — the manual button
  /// and the other sources still cover everything this misses.
  static const Duration _emailSyncInterval = Duration(minutes: 15);

  Future<void> _syncEmail() async {
    if (!ref.read(consentProvider(SettingKeys.consentEmail))) return;
    try {
      final IngestRepository repo = ref.read(ingestRepositoryProvider);
      final String? account = await repo.getSetting(SettingKeys.gmailAccount);
      if (account == null || account.isEmpty) return; // Not connected.

      final String? lastSyncedRaw =
          await repo.getSetting(SettingKeys.gmailLastSyncedAt);
      final DateTime? lastSynced =
          lastSyncedRaw == null ? null : DateTime.tryParse(lastSyncedRaw);
      if (lastSynced != null &&
          DateTime.now().difference(lastSynced) < _emailSyncInterval) {
        return; // Scanned recently enough.
      }

      final Set<String> customSenders = parseSenderList(
        await repo.getSetting(SettingKeys.customEmailSenders),
      ).toSet();

      final IngestResult result =
          await ref.read(gmailClientProvider).fetchPayments(
                since: lastSynced,
                customSenders: customSenders,
              );
      await repo.stage(result.events, issues: result.issues);
      await repo.setSetting(
        SettingKeys.gmailLastSyncedAt,
        DateTime.now().toIso8601String(),
      );
    } catch (_) {
      // Quiet: the user can still pull manually, and the badge only updates when
      // something was actually found.
    }
  }

  /// Drains whatever the native listener buffered and queues it for review.
  Future<void> _collectNotifications() async {
    if (!ref.read(consentProvider(SettingKeys.consentNotifications))) return;
    try {
      await ref.read(notificationCaptureProvider).syncAllowedPackages();
      final List<PaymentEvent> events =
          await ref.read(notificationCaptureProvider).drainPending();
      if (events.isEmpty) return;
      await ref.read(ingestRepositoryProvider).stage(events);
    } catch (_) {
      // A failed drain is not worth interrupting the user for: the statement
      // upload path still catches every payment the listener misses.
    }
  }

  void _listenForLiveNotifications() {
    if (!ref.read(consentProvider(SettingKeys.consentNotifications))) return;
    _liveNotifications?.cancel();
    _liveNotifications = ref
        .read(notificationCaptureProvider)
        .watchLive()
        .listen(
          (PaymentEvent event) => ref
              .read(ingestRepositoryProvider)
              .stage(<PaymentEvent>[event]),
          onError: (_) {},
        );
  }

  @override
  Widget build(BuildContext context) {
    // Watched so the badge updates the moment a statement is parsed.
    final int pendingCount =
        ref.watch(pendingIngestProvider).value?.length ?? 0;

    return Scaffold(
      body: IndexedStack(index: _index, children: _destinations),
      floatingActionButton: pendingCount == 0
          ? null
          : FloatingActionButton.extended(
              heroTag: 'review-queue',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const ReviewQueueScreen(),
                ),
              ),
              icon: const Icon(Icons.inbox_outlined),
              label: Text(
                '$pendingCount to review',
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int index) => setState(() => _index = index),
        destinations: <Widget>[
          const NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clients',
          ),
          const NavigationDestination(
            icon: Icon(Icons.mark_email_unread_outlined),
            selectedIcon: Icon(Icons.mark_email_unread),
            label: 'Reminders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
