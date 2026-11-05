package com.paytrail.paytrail

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges the notification listener to Dart.
 *
 * The method channel is deliberately narrow: check permission, open the system
 * settings page, push the allowlist, drain what was captured while the app was
 * closed. No parsing crosses this boundary — Kotlin forwards raw text and Dart
 * decides what it means.
 */
class MainActivity : FlutterActivity() {

    private companion object {
        const val METHOD_CHANNEL = "com.paytrail.paytrail/notifications"
        const val EVENT_CHANNEL = "com.paytrail.paytrail/notifications/events"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isPermissionGranted" -> result.success(isListenerEnabled())

                    // Android gives no API to request this permission; the user
                    // must grant it in Settings. All the app can do is take them
                    // there, which is why the consent screen explains the
                    // journey before sending them.
                    "openPermissionSettings" -> {
                        startActivity(
                            Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        )
                        result.success(null)
                    }

                    // Dart owns the list of packages worth watching, because the
                    // adapter registry is the single source of truth for which
                    // platforms the app understands.
                    "setAllowedPackages" -> {
                        val packages = call.arguments as? List<*>
                        val values = packages
                            ?.filterIsInstance<String>()
                            ?.toSet()
                            .orEmpty()
                        getSharedPreferences(
                            PaymentNotificationListenerService.PREFS,
                            Context.MODE_PRIVATE,
                        )
                            .edit()
                            .putStringSet(
                                PaymentNotificationListenerService.KEY_ALLOWED,
                                values,
                            )
                            .apply()
                        result.success(null)
                    }

                    "drain" -> result.success(
                        PaymentNotificationListenerService.drainQueue(applicationContext)
                    )

                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        PaymentNotificationListenerService.liveSink = { payload ->
                            // onNotificationPosted runs off the main thread;
                            // EventSink must be touched from it.
                            runOnUiThread { events?.success(payload) }
                        }
                    }

                    override fun onCancel(arguments: Any?) {
                        PaymentNotificationListenerService.liveSink = null
                    }
                }
            )
    }

    /**
     * Whether the user has granted notification access to this app.
     *
     * Read from the secure setting rather than remembered locally: the user can
     * revoke it in Settings at any time without the app being told, so a cached
     * "granted" flag would go stale and the app would claim to be listening
     * when it is not.
     */
    private fun isListenerEnabled(): Boolean {
        val enabled = Settings.Secure.getString(
            contentResolver,
            "enabled_notification_listeners",
        ) ?: return false

        val expected = ComponentName(
            this,
            PaymentNotificationListenerService::class.java,
        )
        return enabled.split(":").any { entry ->
            ComponentName.unflattenFromString(entry) == expected
        }
    }
}
