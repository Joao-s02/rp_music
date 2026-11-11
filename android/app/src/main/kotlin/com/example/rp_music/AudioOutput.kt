package com.example.rp_music

import android.content.Context
import android.media.MediaRoute2Info
import android.media.MediaRouter2
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

internal fun registerAudioOutput(context: Context, messenger: BinaryMessenger) {
    val channel = MethodChannel(messenger, "rp_music/audio_output")
    val events = EventChannel(messenger, "rp_music/audio_output/route")
    if (Build.VERSION.SDK_INT >= 34) {
        SystemAudioOutput(context, channel, events)
    } else {
        channel.setMethodCallHandler { _, result -> result.notImplemented() }
        events.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink) = sink.success(null)
            override fun onCancel(arguments: Any?) {}
        })
    }
}

@android.annotation.TargetApi(34)
private class SystemAudioOutput(
    context: Context,
    channel: MethodChannel,
    events: EventChannel,
) : EventChannel.StreamHandler {
    private val router = MediaRouter2.getInstance(context.applicationContext)
    private val executor = context.mainExecutor
    private var sink: EventChannel.EventSink? = null
    private val callback = object : MediaRouter2.ControllerCallback() {
        override fun onControllerUpdated(controller: MediaRouter2.RoutingController) = publish()
    }

    init {
        events.setStreamHandler(this)
        channel.setMethodCallHandler { call, result ->
            if (call.method == "show") result.success(
                runCatching { router.showSystemOutputSwitcher() }.getOrDefault(false)
            ) else result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        this.sink = sink
        router.registerControllerCallback(executor, callback)
        publish()
    }

    override fun onCancel(arguments: Any?) {
        router.unregisterControllerCallback(callback)
        sink = null
    }

    private fun publish() {
        val route = router.systemController.selectedRoutes.firstOrNull()
        val icon = when (route?.type) {
            MediaRoute2Info.TYPE_BUILTIN_SPEAKER -> "phone"
            MediaRoute2Info.TYPE_WIRED_HEADSET, MediaRoute2Info.TYPE_WIRED_HEADPHONES,
            MediaRoute2Info.TYPE_USB_HEADSET -> "headphones"
            MediaRoute2Info.TYPE_BLUETOOTH_A2DP, MediaRoute2Info.TYPE_BLE_HEADSET,
            MediaRoute2Info.TYPE_HEARING_AID -> "bluetooth"
            MediaRoute2Info.TYPE_REMOTE_TV, MediaRoute2Info.TYPE_HDMI -> "tv"
            else -> "speaker"
        }
        sink?.success(mapOf("name" to route?.name?.toString().orEmpty(), "icon" to icon))
    }
}
