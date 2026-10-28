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
open class MusicWidget : AppWidgetProvider() {
    override fun onAppWidgetOptionsChanged(context: Context, manager: AppWidgetManager, id: Int, options: android.os.Bundle) {
        render(context, controller?.playbackState?.state == PlaybackStateCompat.STATE_PLAYING)
    }
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        render(context, controller?.playbackState?.state == PlaybackStateCompat.STATE_PLAYING)
        observe(context)
    }
    override fun onDeleted(context: Context, ids: IntArray) {
        if (providers.all { AppWidgetManager.getInstance(context).getAppWidgetIds(ComponentName(context, it)).isEmpty() }) disconnect()
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
        private val providers = listOf(MusicWidget::class.java, CompactMusicWidget::class.java, ArtworkMusicWidget::class.java)
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
            prefs.edit().putString("title", metadata?.description?.title?.toString() ?: "Elige tu mÃºsica")
                .putString("artist", metadata?.description?.subtitle?.toString() ?: "RP Music Â· biblioteca local").apply()
        }
        private fun render(context: Context, playing: Boolean) {
            val manager = AppWidgetManager.getInstance(context)
            for (provider in providers) for (id in manager.getAppWidgetIds(ComponentName(context, provider))) {
            val options = manager.getAppWidgetOptions(id)
            val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 250)
            val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 56)
            val prefs = context.getSharedPreferences("home_widget", Context.MODE_PRIVATE)
            val layout = if (provider == ArtworkMusicWidget::class.java && height >= 140) R.layout.music_widget_artwork else if (provider == MusicWidget::class.java && height >= 100) R.layout.music_widget else R.layout.music_widget_compact
            val views = RemoteViews(context.packageName, layout)
            views.setViewVisibility(R.id.widget_previous, if (width >= 270) android.view.View.VISIBLE else android.view.View.GONE)
            views.setViewVisibility(R.id.widget_next, if (width >= 220) android.view.View.VISIBLE else android.view.View.GONE)
            views.setViewVisibility(R.id.widget_artist, if (height >= 56) android.view.View.VISIBLE else android.view.View.GONE)
            views.setViewVisibility(R.id.widget_cover, if (width >= 160 || layout == R.layout.music_widget_artwork) android.view.View.VISIBLE else android.view.View.GONE)
            views.setTextViewText(R.id.widget_title, prefs.getString("title", "Elige tu mÃºsica"))
            views.setTextViewText(R.id.widget_artist, prefs.getString("artist", "RP Music Â· biblioteca local"))
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
            manager.updateAppWidget(id, views)
            }
        }
    }
}

class CompactMusicWidget : MusicWidget()
class ArtworkMusicWidget : MusicWidget()
