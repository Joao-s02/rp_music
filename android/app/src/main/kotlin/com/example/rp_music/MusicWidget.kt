package com.example.rp_music

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Handler
import android.os.Looper
import android.support.v4.media.MediaBrowserCompat
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaControllerCompat
import android.support.v4.media.session.PlaybackStateCompat
import android.widget.RemoteViews
import com.ryanheise.audioservice.AudioService

/** Event-driven launcher controls using the same media session as the notification. */
class MusicWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        render(context, false)
        observe(context)
    }
    override fun onDeleted(context: Context, ids: IntArray) {
        if (AppWidgetManager.getInstance(context).getAppWidgetIds(ComponentName(context, MusicWidget::class.java)).isEmpty()) disconnect()
    }
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action != CONTROL) return
        val command = intent.getStringExtra("command") ?: return
        if (command !in setOf("toggle", "previous", "next")) return
        val pending = goAsync()
        var finished = false
        val finish = { if (!finished) { finished = true; pending.finish() } }
        Handler(Looper.getMainLooper()).postDelayed({ finish() }, 8500)
        observe(context, command, finish)
    }

    companion object {
        private const val CONTROL = "com.example.rp_music.WIDGET_CONTROL"
        private var browser: MediaBrowserCompat? = null
        private var controller: MediaControllerCompat? = null
        private var callback: MediaControllerCompat.Callback? = null
        private val waiting = mutableListOf<Pair<String?, (() -> Unit)?>>()

        fun observe(context: Context, command: String? = null, done: (() -> Unit)? = null) {
            val app = context.applicationContext
            controller?.let { current ->
                if (browser?.isConnected == true) {
                    if (command == null || ready(current)) { act(current, command); done?.invoke() }
                    else waiting.add(command to done)
                    return
                }
            }
            waiting.add(command to done)
            if (browser != null) return
            browser = MediaBrowserCompat(app, ComponentName(app, AudioService::class.java), object : MediaBrowserCompat.ConnectionCallback() {
                override fun onConnected() {
                    try {
                        val current = MediaControllerCompat(app, browser!!.sessionToken)
                        controller = current
                        callback = object : MediaControllerCompat.Callback() {
                            override fun onMetadataChanged(metadata: MediaMetadataCompat?) { updateMetadata(app, metadata); render(app, current.playbackState?.state == PlaybackStateCompat.STATE_PLAYING) }
                            override fun onPlaybackStateChanged(state: PlaybackStateCompat?) { render(app, state?.state == PlaybackStateCompat.STATE_PLAYING); flush(current) }
                            override fun onSessionDestroyed() { disconnect(); render(app, false) }
                        }
                        current.registerCallback(callback!!)
                        updateMetadata(app, current.metadata)
                        render(app, current.playbackState?.state == PlaybackStateCompat.STATE_PLAYING)
                        flush(current)
                    } catch (_: Exception) { fail(app) }
                }
                override fun onConnectionFailed() { fail(app) }
                override fun onConnectionSuspended() { fail(app) }
            }, null)
            try { browser!!.connect() } catch (_: Exception) { fail(app) }
        }
        // The service's initial automatic action set lacks next; Dart publishes it
        // only after installing its handler. This prevents losing a cold-start tap.
        private fun ready(current: MediaControllerCompat): Boolean =
            ((current.playbackState?.actions ?: 0L) and PlaybackStateCompat.ACTION_SKIP_TO_NEXT) != 0L
        private fun flush(current: MediaControllerCompat) {
            if (!ready(current)) return
            val jobs = waiting.toList(); waiting.clear()
            jobs.forEach { (action, finish) -> try { act(current, action) } finally { finish?.invoke() } }
        }
        fun diagnostics(context: Context): Map<String, Any?> = mapOf(
            "registered" to AppWidgetManager.getInstance(context).installedProviders.any { it.provider == ComponentName(context, MusicWidget::class.java) },
            "connected" to (browser?.isConnected == true),
            "title" to controller?.metadata?.description?.title?.toString(),
            "playing" to (controller?.playbackState?.state == PlaybackStateCompat.STATE_PLAYING)
        )
        private fun act(current: MediaControllerCompat, command: String?) {
            when (command) {
                "toggle" -> if (current.playbackState?.state == PlaybackStateCompat.STATE_PLAYING) current.transportControls.pause() else current.transportControls.play()
                "previous" -> if (current.metadata == null) current.transportControls.play() else current.transportControls.skipToPrevious()
                "next" -> if (current.metadata == null) current.transportControls.play() else current.transportControls.skipToNext()
            }
        }
        private fun fail(context: Context) {
            waiting.forEach { it.second?.invoke() }; waiting.clear()
            disconnect(); render(context, false)
        }
        private fun disconnect() {
            callback?.let { controller?.unregisterCallback(it) }
            callback = null; controller = null
            browser?.disconnect(); browser = null
        }
        private fun updateMetadata(context: Context, metadata: MediaMetadataCompat?) {
            val prefs = context.getSharedPreferences("home_widget", Context.MODE_PRIVATE)
            val image = metadata?.description?.iconBitmap
            val file = java.io.File(context.cacheDir, "home_widget_cover.png")
            try {
                if (image != null) {
                    val small = Bitmap.createScaledBitmap(image, 160, 160, true)
                    file.outputStream().use { small.compress(Bitmap.CompressFormat.PNG, 100, it) }
                    if (small !== image) small.recycle()
                } else file.delete()
            } catch (_: Exception) { file.delete() }
            prefs.edit().putString("title", metadata?.description?.title?.toString() ?: "Elige tu música")
                .putString("artist", metadata?.description?.subtitle?.toString() ?: "RP Music · biblioteca local").apply()
        }
        private fun render(context: Context, playing: Boolean) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, MusicWidget::class.java))
            if (ids.isEmpty()) return
            val prefs = context.getSharedPreferences("home_widget", Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.music_widget)
            views.setTextViewText(R.id.widget_title, prefs.getString("title", "Elige tu música"))
            views.setTextViewText(R.id.widget_artist, prefs.getString("artist", "RP Music · biblioteca local"))
            val bitmap = BitmapFactory.decodeFile(java.io.File(context.cacheDir, "home_widget_cover.png").path)
            if (bitmap != null) views.setImageViewBitmap(R.id.widget_cover, bitmap)
            else views.setImageViewResource(R.id.widget_cover, R.mipmap.ic_launcher)
            views.setImageViewResource(R.id.widget_toggle, if (playing) R.drawable.rp_pause else R.drawable.rp_play)
            views.setContentDescription(R.id.widget_toggle, if (playing) "Pausar" else "Reproducir")
            for ((id, action) in listOf(R.id.widget_previous to "previous", R.id.widget_toggle to "toggle", R.id.widget_next to "next")) {
                val intent = Intent(context, MusicWidget::class.java).setAction(CONTROL).putExtra("command", action)
                views.setOnClickPendingIntent(id, PendingIntent.getBroadcast(context, id, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
            }
            val open = PendingIntent.getActivity(context, 900, Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP), PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            views.setOnClickPendingIntent(R.id.widget_cover, open)
            views.setOnClickPendingIntent(R.id.widget_title, open)
            manager.updateAppWidget(ids, views)
        }
    }
}
