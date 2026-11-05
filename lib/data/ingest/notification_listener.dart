import 'package:flutter/services.dart';

import '../../domain/ingest/payment_event.dart';
import '../../domain/ingest/payment_source_adapter.dart';

/// The Dart half of the Android notification listener.
///
/// Kotlin forwards raw title/text for allowlisted packages only; this class
/// turns them into [PaymentEvent]s using the registry's adapters. The split
/// matters: interpretation stays in unit-tested Dart, and the native side never
/// has to know what a payment looks like.
class NotificationCapture {
  NotificationCapture(this._registry);

  static const MethodChannel _methods =
      MethodChannel('com.paytrail.paytrail/notifications');
  static const EventChannel _events =
      EventChannel('com.paytrail.paytrail/notifications/events');

  final PaymentSourceRegistry _registry;

  /// Whether the user has granted notification access.
  ///
  /// Always asked of the platform rather than cached: access is granted and
  /// revoked in system Settings without the app being notified, so a remembered
  /// answer would let the app claim to be listening when it is not.
  Future<bool> isPermissionGranted() async {
    try {
      return await _methods.invokeMethod<bool>('isPermissionGranted') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      // Running on a host or a platform without the service — not an error,
      // just a channel that does not exist.
      return false;
    }
  }

  /// Opens the system page where notification access is granted.
  ///
  /// Android provides no API to request this permission in-app; taking the user
  /// to Settings is the only route, which is why the consent screen explains
  /// what they will see before this is called.
  Future<void> openPermissionSettings() async {
    try {
      await _methods.invokeMethod<void>('openPermissionSettings');
    } on MissingPluginException {
      // Nothing to open off-device.
    }
  }

  /// Tells the native side which packages are worth capturing.
  ///
  /// Pushed from the adapter registry so adding a platform means writing one
  /// adapter, not also editing Kotlin.
  Future<void> syncAllowedPackages() async {
    try {
      await _methods.invokeMethod<void>(
        'setAllowedPackages',
        _registry.allNotificationPackages.toList(),
      );
    } on MissingPluginException {
      // No native side to configure.
    }
  }

  /// Returns everything captured while the app was closed, and clears it.
  ///
  /// The service runs whether or not Flutter does, so captures are buffered
  /// natively and collected here on launch. Anything no adapter recognises is
  /// dropped silently — most notifications from a marketplace app are messages
  /// and reviews, not payments.
  Future<List<PaymentEvent>> drainPending() async {
    List<Object?>? raw;
    try {
      raw = await _methods.invokeMethod<List<Object?>>('drain');
    } on MissingPluginException {
      return const <PaymentEvent>[];
    } on PlatformException {
      return const <PaymentEvent>[];
    }
    if (raw == null) return const <PaymentEvent>[];

    final List<PaymentEvent> events = <PaymentEvent>[];
    for (final Object? item in raw) {
      final PaymentEvent? event = _interpret(item);
      if (event != null) events.add(event);
    }
    return events;
  }

  /// Payment notifications as they arrive while the app is in the foreground.
  Stream<PaymentEvent> watchLive() {
    return _events
        .receiveBroadcastStream()
        .map(_interpret)
        .where((PaymentEvent? event) => event != null)
        .cast<PaymentEvent>();
  }

  /// Turns one native payload into an event, or null if nothing owns it.
  PaymentEvent? _interpret(Object? payload) {
    if (payload is! Map) return null;

    final String packageName = '${payload['packageName'] ?? ''}';
    if (packageName.isEmpty) return null;

    // Checked again on this side of the channel: the native allowlist is the
    // real gate, and this is the second lock on the same door.
    final PaymentSourceAdapter? adapter =
        _registry.byNotificationPackage(packageName);
    if (adapter == null) return null;

    final int postedMillis = switch (payload['postedAt']) {
      final int value => value,
      final String value => int.tryParse(value) ?? 0,
      _ => 0,
    };

    return adapter.parseNotification(
      NotificationData(
        packageName: packageName,
        title: '${payload['title'] ?? ''}',
        text: '${payload['text'] ?? ''}',
        postedAt: postedMillis == 0
            ? DateTime.now()
            : DateTime.fromMillisecondsSinceEpoch(postedMillis),
      ),
    );
  }
}
