package com.example.rp_music

import android.app.Activity
import android.Manifest
import android.app.NotificationManager
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.content.Intent
import android.media.MediaMetadataRetriever
import android.net.Uri
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : AudioServiceActivity() {
    private var picker: MethodChannel.Result? = null
    private var notificationRequest: MethodChannel.Result? = null
    private val worker = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "rp_music/system").setMethodCallHandler { call, result ->
            when (call.method) {
                "notificationsEnabled" -> result.success(notificationsEnabled())
                "playbackDiagnostics" -> {
                    val manager = getSystemService(NotificationManager::class.java)
                    val notifications = manager.activeNotifications.filter { it.notification.category == "transport" }
                    val channel = if (Build.VERSION.SDK_INT >= 26) manager.getNotificationChannel("rp_music.playback") else null
                    result.success(mapOf(
                        "notificationsEnabled" to notificationsEnabled(),
                        "mediaNotifications" to notifications.size,
                        "channelImportance" to channel?.importance,
                        "hasMediaSession" to notifications.any { it.notification.extras.containsKey("android.mediaSession") },
                        "ongoing" to notifications.any { (it.notification.flags and android.app.Notification.FLAG_ONGOING_EVENT) != 0 }
                    ))
                }
                "notificationSettings" -> {
                    val intent = if (Build.VERSION.SDK_INT >= 26) {
                        Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                    } else Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName"))
                    startActivity(intent); result.success(null)
                }
                "requestNotifications" -> {
                    val prefs = getSharedPreferences("system_permissions", MODE_PRIVATE)
                    val firstLaunch = call.argument<Boolean>("firstLaunch") == true
                    if (Build.VERSION.SDK_INT < 33 || checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED ||
                        (firstLaunch && prefs.getBoolean("notificationAsked", false))) {
                        result.success(notificationsEnabled())
                    } else if (notificationRequest != null) {
                        result.success(notificationsEnabled())
                    } else {
                        notificationRequest = result
                        prefs.edit().putBoolean("notificationAsked", true).apply()
                        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 811)
                    }
                }
                else -> result.notImplemented()
            }
        }
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "rp_music/library")
        channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "chooseRoot" -> {
                        if (picker != null) result.error("busy", "Selector abierto", null)
                        else {
                            picker = result
                            try {
                                startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                        Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                                        Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
                                }, 810)
                            } catch (e: Exception) {
                                picker = null
                                result.error("picker", "No se pudo abrir el selector", null)
                            }
                        }
                    }
                    "scan" -> worker.execute {
                        try {
                            val root = Uri.parse(call.argument<String>("root")!!)
                            val cached = call.argument<List<Map<String, Any>>>("cached") ?: emptyList()
                            val value = LibraryScanner(this) { update ->
                                runOnUiThread { channel.invokeMethod("scanProgress", update) }
                            }.scan(root, cached)
                            runOnUiThread { result.success(value) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("scan", "No se pudo leer la carpeta", null) }
                        }
                    }
                    "artwork" -> worker.execute {
                        val retriever = MediaMetadataRetriever()
                        try {
                            retriever.setDataSource(this, Uri.parse(call.argument<String>("id")!!))
                            val bytes = retriever.embeddedPicture
                            runOnUiThread { result.success(bytes) }
                        } catch (e: Exception) {
                            runOnUiThread { result.success(null) }
                        } finally { retriever.release() }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun notificationsEnabled(): Boolean = if (Build.VERSION.SDK_INT >= 24) {
        getSystemService(NotificationManager::class.java).areNotificationsEnabled()
    } else true

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 811) {
            val result = notificationRequest; notificationRequest = null
            result?.success(notificationsEnabled())
        }
    }

    @Deprecated("Uses the platform document picker result")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 810) return
        val result = picker ?: return
        picker = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) { result.success(null); return }
        try {
            contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            result.success(uri.toString())
        } catch (e: Exception) { result.error("permission", "No se pudo conservar el acceso", null) }
    }

}
