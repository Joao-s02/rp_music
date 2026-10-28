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
    private var writeRequest: MethodChannel.Result? = null
    private var writeRoot: Uri? = null
    private var picker: MethodChannel.Result? = null
    private var downloadPicker: MethodChannel.Result? = null
    private var notificationRequest: MethodChannel.Result? = null
    private val worker = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        val updates = AppUpdates(this, worker)
        MethodChannel(engine.dartExecutor.binaryMessenger, "rp_music/updates").setMethodCallHandler(updates::handle)
        MethodChannel(engine.dartExecutor.binaryMessenger, "rp_music/system").setMethodCallHandler { call, result ->
            when (call.method) {
                "connectWidget" -> {
                    val manager = android.appwidget.AppWidgetManager.getInstance(this)
                    if (manager.getAppWidgetIds(android.content.ComponentName(this, MusicWidget::class.java)).isNotEmpty()) MusicWidget.observe(applicationContext)
                    result.success(null)
                }
                "pinWidget" -> {
                    val manager = android.appwidget.AppWidgetManager.getInstance(this)
                    result.success(Build.VERSION.SDK_INT >= 26 && manager.isRequestPinAppWidgetSupported && manager.requestPinAppWidget(android.content.ComponentName(this, MusicWidget::class.java), null, null))
                }
                "notificationsEnabled" -> result.success(notificationsEnabled())
                "playbackDiagnostics" -> {
                    val manager = getSystemService(NotificationManager::class.java)
                    val notifications = manager.activeNotifications.filter { it.notification.category == "transport" }
                    val channel = if (Build.VERSION.SDK_INT >= 26) manager.getNotificationChannel("rp_music.playback") else null
                    result.success(mapOf(
                        "notificationsEnabled" to notificationsEnabled(),
                        "android" to Build.VERSION.RELEASE,
                        "api" to Build.VERSION.SDK_INT,
                        "manufacturer" to Build.MANUFACTURER,
                        "model" to Build.MODEL,
                        "batteryUnrestricted" to getSystemService(android.os.PowerManager::class.java).isIgnoringBatteryOptimizations(packageName),
                        "mediaNotifications" to notifications.size,
                        "channelImportance" to channel?.importance,
                        "hasMediaSession" to notifications.any { it.notification.extras.containsKey("android.mediaSession") },
                        "foreground" to notifications.any { (it.notification.flags and android.app.Notification.FLAG_FOREGROUND_SERVICE) != 0 },
                        "ongoing" to notifications.any { (it.notification.flags and android.app.Notification.FLAG_ONGOING_EVENT) != 0 }
                    ))
                }
                "testWidgetState" -> {
                    if ((applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0) result.success(MusicWidget.diagnostics(this))
                    else result.notImplemented()
                }
                "testWidgetControl" -> {
                    if ((applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
                        val command = call.argument<String>("command")
                        if (command !in setOf("toggle", "previous", "next")) result.error("command", "Acción inválida", null)
                        else MusicWidget.observe(applicationContext, command) { result.success(null) }
                    } else result.notImplemented()
                }
                "testMoveToBackground" -> {
                    if ((applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
                        moveTaskToBack(true); result.success(null)
                    } else result.notImplemented()
                }
                "batterySettings" -> {
                    startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)); result.success(null)
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
                    "lyricsFile" -> worker.execute {
                        var temporary: java.io.File? = null
                        try {
                            val uri = Uri.parse(call.argument<String>("id")!!)
                            require(uri.scheme == "content")
                            val directory = java.io.File(cacheDir, "lyrics_read").apply { mkdirs() }
                            // Clean interrupted reads without deleting a current reader's file.
                            directory.listFiles()?.filter { System.currentTimeMillis() - it.lastModified() > 3600000 }?.forEach { it.delete() }
                            val copy = java.io.File.createTempFile("tags", ".audio", directory)
                            temporary = copy
                            val deadline = android.os.SystemClock.elapsedRealtime() + 30000
                            contentResolver.openInputStream(uri)!!.use { input ->
                                copy.outputStream().use { output ->
                                    val buffer = ByteArray(65536)
                                    var total = 0L
                                    while (true) {
                                        val count = input.read(buffer)
                                        if (count < 0) break
                                        total += count
                                        check(total <= 256L * 1024 * 1024 && android.os.SystemClock.elapsedRealtime() < deadline)
                                        output.write(buffer, 0, count)
                                    }
                                }
                            }
                            val path = copy.absolutePath
                            runOnUiThread { result.success(path) }
                        } catch (e: Exception) {
                            temporary?.delete()
                            runOnUiThread { result.error("lyrics", "No se pudieron leer las etiquetas del archivo", null) }
                        }
                    }
                    "ensureWritable" -> {
                        val root = Uri.parse(call.argument<String>("root")!!)
                        if (contentResolver.persistedUriPermissions.any { it.uri == root && it.isWritePermission }) result.success(true)
                        else if (writeRequest != null || picker != null) result.error("busy", "Selector abierto", null)
                        else {
                            writeRequest = result; writeRoot = root
                            try {
                                startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
                                    if (Build.VERSION.SDK_INT >= 26) putExtra(android.provider.DocumentsContract.EXTRA_INITIAL_URI, root)
                                }, 812)
                            } catch (e: Exception) {
                                writeRequest = null; writeRoot = null
                                result.error("permission", "No se pudo abrir el selector de escritura", null)
                            }
                        }
                    }
                    "chooseRoot" -> {
                        if (picker != null || writeRequest != null) result.error("busy", "Selector abierto", null)
                        else {
                            picker = result
                            try {
                                startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                                        Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                                        Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
                                }, 810)
                            } catch (e: Exception) {
                                picker = null
                                result.error("picker", "No se pudo abrir el selector", null)
                            }
                        }
                    }
                    "chooseDownloadFolder" -> {
                        if (downloadPicker != null) result.error("busy", "Selector abierto", null)
                        else {
                            downloadPicker = result
                            try { startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
                            }, 813) } catch (e: Exception) { downloadPicker = null; result.error("picker", "No se pudo abrir el selector", null) }
                        }
                    }
                    "writeDownload" -> worker.execute {
                        var created: Uri? = null
                        try {
                            val root = Uri.parse(call.argument<String>("folder")!!)
                            val parent = android.provider.DocumentsContract.buildDocumentUriUsingTree(root, android.provider.DocumentsContract.getTreeDocumentId(root))
                            val name = call.argument<String>("name")!!
                            check(name.length <= 180 && name.none { it == '/' || it.code == 92 || it.code < 32 })
                            val bytes = call.argument<ByteArray>("bytes")!!
                            check(bytes.size <= 64 * 1024 * 1024)
                            created = android.provider.DocumentsContract.createDocument(contentResolver, parent, call.argument<String>("mime")!!, name)
                            check(created != null)
                            contentResolver.openOutputStream(created!!, "w")!!.use { it.write(bytes) }
                            runOnUiThread { result.success(created.toString()) }
                        } catch (e: Exception) {
                            created?.let { try { android.provider.DocumentsContract.deleteDocument(contentResolver, it) } catch (_: Exception) {} }
                            runOnUiThread { result.error("write", "No se pudo guardar la descarga", null) }
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
                    "deleteTrack" -> worker.execute {
                        try {
                            val uri = Uri.parse(call.argument<String>("id")!!)
                            check(android.provider.DocumentsContract.deleteDocument(contentResolver, uri))
                            runOnUiThread { result.success(null) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("delete", "No se pudo eliminar. Vuelve a elegir la carpeta y permite escritura.", null) }
                        }
                    }
                    "artworkUri" -> worker.execute {
                        val retriever = MediaMetadataRetriever()
                        try {
                            retriever.setDataSource(this, Uri.parse(call.argument<String>("id")!!))
                            val bytes = retriever.embeddedPicture
                            val dir = java.io.File(cacheDir, "notification_art").apply { mkdirs() }
                            val file = if (bytes == null) null else java.io.File.createTempFile("cover", ".img", dir).apply { writeBytes(bytes) }
                            dir.listFiles()?.sortedByDescending { it.lastModified() }?.drop(8)?.forEach { it.delete() }
                            runOnUiThread { result.success(file?.toURI()?.toString()) }
                        } catch (e: Exception) {
                            runOnUiThread { result.success(null) }
                        } finally { retriever.release() }
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
        if (requestCode == 813) {
            val pending = downloadPicker ?: return
            downloadPicker = null
            val uri = data?.data
            if (resultCode != Activity.RESULT_OK || uri == null) { pending.success(null); return }
            try {
                contentResolver.takePersistableUriPermission(uri, data!!.flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION))
                pending.success(uri.toString())
            } catch (e: Exception) { pending.error("permission", "No se pudo conservar acceso de descarga", null) }
            return
        }
        if (requestCode == 812) {
            val pending = writeRequest ?: return
            val root = writeRoot
            writeRequest = null; writeRoot = null
            val selected = data?.data
            if (resultCode != Activity.RESULT_OK || selected == null || root == null) { pending.success(false); return }
            try {
                if (selected.authority != root.authority || android.provider.DocumentsContract.getTreeDocumentId(selected) != android.provider.DocumentsContract.getTreeDocumentId(root)) {
                    pending.error("folder", "Selecciona la misma carpeta para autorizar el borrado", null); return
                }
                val flags = data.flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                contentResolver.takePersistableUriPermission(selected, flags)
                pending.success(contentResolver.persistedUriPermissions.any { it.uri == root && it.isWritePermission })
            } catch (e: Exception) { pending.error("permission", "No se pudo conservar escritura", null) }
            return
        }
        if (requestCode != 810) return
        val result = picker ?: return
        picker = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) { result.success(null); return }
        try {
            contentResolver.takePersistableUriPermission(uri, data!!.flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION))
            result.success(uri.toString())
        } catch (e: Exception) { result.error("permission", "No se pudo conservar el acceso", null) }
    }

}
