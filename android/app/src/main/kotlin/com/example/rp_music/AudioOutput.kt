package com.example.rp_music

import android.content.Context
import android.content.Intent
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.media.MediaRoute2Info
import android.media.MediaRouter
import android.media.MediaRouter2
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

internal fun registerAudioOutput(context: Context, messenger: BinaryMessenger) {
    val channel = MethodChannel(messenger, "rp_music/audio_output")
    val events = EventChannel(messenger, "rp_music/audio_output/route")
    val modern = if (Build.VERSION.SDK_INT >= 30) ModernAudioRoute(context) else null
    val routes = modern ?: LegacyAudioRoute(context)
    events.setStreamHandler(routes)
    channel.setMethodCallHandler { call, result ->
        when (call.method) {
            "show" -> result.success(
                Build.VERSION.SDK_INT >= 34 &&
                    runCatching { modern?.showSwitcher() == true }.getOrDefault(false)
            )
            "routes" -> result.success(runCatching { modern?.availableRoutes().orEmpty() }.getOrDefault(emptyList()))
            "transfer" -> result.success(runCatching {
                modern?.transfer(call.argument<String>("id").orEmpty()) == true
            }.getOrDefault(false))
            "soundSettings", "bluetoothSettings" -> {
                val action = if (call.method == "soundSettings") Settings.ACTION_SOUND_SETTINGS
                    else Settings.ACTION_BLUETOOTH_SETTINGS
                result.success(runCatching {
                    context.startActivity(Intent(action).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    true
                }.getOrDefault(false))
            }
            else -> result.notImplemented()
        }
    }
}

private abstract class AudioRouteEvents : EventChannel.StreamHandler {
    protected var sink: EventChannel.EventSink? = null
    protected fun emit(name: String, icon: String) {
        sink?.success(mapOf("name" to name, "icon" to icon))
    }
}

@android.annotation.TargetApi(30)
private class ModernAudioRoute(context: Context) : AudioRouteEvents() {
    private val router = MediaRouter2.getInstance(context.applicationContext)
    private val executor = context.mainExecutor
    private val callback = object : MediaRouter2.ControllerCallback() {
        override fun onControllerUpdated(controller: MediaRouter2.RoutingController) = publish()
    }

    @android.annotation.TargetApi(34)
    fun showSwitcher(): Boolean = router.showSystemOutputSwitcher()

    private fun transferableRoutes(): List<MediaRoute2Info> =
        router.systemController.transferableRoutes.filter { it.isSystemRoute }

    fun availableRoutes() = transferableRoutes().map { route ->
        mapOf("id" to route.id, "name" to route.name.toString())
    }

    fun transfer(id: String): Boolean {
        val route = transferableRoutes().firstOrNull { it.id == id } ?: return false
        router.transferTo(route)
        return true
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
        emit(route?.name?.toString().orEmpty(), icon)
    }
}

@Suppress("DEPRECATION")
private class LegacyAudioRoute(private val context: Context) : AudioRouteEvents() {
    private val router = context.getSystemService(Context.MEDIA_ROUTER_SERVICE) as MediaRouter
    private val manager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val callback = object : MediaRouter.SimpleCallback() {
        override fun onRouteSelected(router: MediaRouter, type: Int, info: MediaRouter.RouteInfo) = publish()
        override fun onRouteChanged(router: MediaRouter, info: MediaRouter.RouteInfo) = publish()
    }
    private val devices = object : AudioDeviceCallback() {
        override fun onAudioDevicesAdded(devices: Array<out AudioDeviceInfo>) = publish()
        override fun onAudioDevicesRemoved(devices: Array<out AudioDeviceInfo>) = publish()
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        this.sink = sink
        router.addCallback(MediaRouter.ROUTE_TYPE_LIVE_AUDIO, callback)
        manager.registerAudioDeviceCallback(devices, Handler(Looper.getMainLooper()))
        publish()
    }

    override fun onCancel(arguments: Any?) {
        router.removeCallback(callback)
        manager.unregisterAudioDeviceCallback(devices)
        sink = null
    }

    private fun publish() {
        val route = router.getSelectedRoute(MediaRouter.ROUTE_TYPE_LIVE_AUDIO)
        val type = if (Build.VERSION.SDK_INT >= 24) route.deviceType else 0
        val icon = when {
            type == MediaRouter.RouteInfo.DEVICE_TYPE_BLUETOOTH || manager.isBluetoothA2dpOn -> "bluetooth"
            type == MediaRouter.RouteInfo.DEVICE_TYPE_TV -> "tv"
            manager.isWiredHeadsetOn -> "headphones"
            else -> "speaker"
        }
        val name = if (icon == "headphones") "Auriculares con cable" else route.getName(context).toString()
        emit(name, icon)
    }
}
