package com.paytrail.paytrail

import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONArray
import org.json.JSONObject

/**
 * Captures payment notifications posted by the marketplace apps.
 *
 * Two things make this safe to ship in a finance app:
 *
 * 1. **A package allowlist, applied before anything is read.** [onNotificationPosted]
 *    fires for every notification on the device — messages, email, banking. The
 *    first thing this service does is check the posting package against the
 *    allowlist and return. Nothing outside those packages is read, stored or
 *    forwarded.
 * 2. **Nothing is interpreted here.** The service copies title and text and
 *    hands them to Dart. Deciding whether a notification is about money, and
 *    what amount, is the platform adapter's job, where it is unit tested.
 *
 * Android may start this service while the Flutter engine is not running, so
 * captures are appended to a small bounded queue in SharedPreferences and
 * drained by Dart on the next launch. Live events also go straight to the
 * EventChannel when the app is in the foreground.
 */
class PaymentNotificationListenerService : NotificationListenerService() {

    companion object {
        const val PREFS = "paytrail.notifications"
        const val KEY_QUEUE = "queue"
        const val KEY_ALLOWED = "allowed_packages"

        /** Beyond this the oldest captures are dropped. */
        private const val MAX_QUEUED = 200

        /**
         * Fallback allowlist, used only before Dart has pushed the registry's
         * list. Kept in sync with the adapters in `lib/data/ingest/`.
         */
        private val DEFAULT_ALLOWED = setOf(
            "com.fiverr.fiverr",
            "com.upwork.android",
        )

        /** Set while the Flutter side is listening; null otherwise. */
        @Volatile
        var liveSink: ((Map<String, Any?>) -> Unit)? = null

        fun allowedPackages(context: Context): Set<String> {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val stored = prefs.getStringSet(KEY_ALLOWED, null)
            return if (stored.isNullOrEmpty()) DEFAULT_ALLOWED else stored
        }

        /** Returns everything captured since the last drain, and clears it. */
        fun drainQueue(context: Context): List<Map<String, Any?>> {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val raw = prefs.getString(KEY_QUEUE, null) ?: return emptyList()
            prefs.edit().remove(KEY_QUEUE).apply()

            val out = mutableListOf<Map<String, Any?>>()
            try {
                val array = JSONArray(raw)
                for (i in 0 until array.length()) {
                    val item = array.getJSONObject(i)
                    out.add(
                        mapOf(
                            "packageName" to item.optString("packageName"),
                            "title" to item.optString("title"),
                            "text" to item.optString("text"),
                            "postedAt" to item.optLong("postedAt"),
                        )
                    )
                }
            } catch (_: Exception) {
                // A corrupted queue is discarded rather than crashing the app;
                // the worst case is a few missed notifications, and the
                // statement upload path still catches those payments.
                return emptyList()
            }
            return out
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val notification = sbn ?: return

        // The allowlist gate. Everything below this line has already been
        // confirmed to come from a marketplace app the user connected.
        if (notification.packageName !in allowedPackages(applicationContext)) return

        val extras = notification.notification?.extras ?: return
        val title = extras.getCharSequence("android.title")?.toString().orEmpty()
        val text = extras.getCharSequence("android.text")?.toString().orEmpty()
        if (title.isBlank() && text.isBlank()) return

        val payload = mapOf(
            "packageName" to notification.packageName,
            "title" to title,
            "text" to text,
            "postedAt" to notification.postTime,
        )

        liveSink?.invoke(payload)
        enqueue(payload)
    }

    /**
     * Appends to the persisted queue.
     *
     * Written even when [liveSink] delivered the event: the Dart side may be
     * mid-teardown, and a duplicate is harmless — the dedupe key collapses it —
     * whereas a lost payment notice is not.
     */
    private fun enqueue(payload: Map<String, Any?>) {
        val prefs = applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val array = try {
            JSONArray(prefs.getString(KEY_QUEUE, "[]"))
        } catch (_: Exception) {
            JSONArray()
        }

        array.put(
            JSONObject().apply {
                put("packageName", payload["packageName"])
                put("title", payload["title"])
                put("text", payload["text"])
                put("postedAt", payload["postedAt"])
            }
        )

        // Drop from the front once the cap is hit, so an uninstalled app or a
        // long gap between launches cannot grow this without bound.
        val trimmed = if (array.length() > MAX_QUEUED) {
            JSONArray().also { out ->
                for (i in (array.length() - MAX_QUEUED) until array.length()) {
                    out.put(array.get(i))
                }
            }
        } else {
            array
        }

        prefs.edit().putString(KEY_QUEUE, trimmed.toString()).apply()
    }

    override fun onListenerDisconnected() {
        liveSink = null
        super.onListenerDisconnected()
    }
}
