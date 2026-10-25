package com.example.rp_music

import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest
import java.util.concurrent.ExecutorService

class AppUpdates(private val activity: MainActivity, private val worker: ExecutorService) {
    @Suppress("DEPRECATION")
    private fun signatures(info: PackageInfo): Set<String> {
        val values = if (Build.VERSION.SDK_INT >= 28) info.signingInfo?.apkContentsSigners else info.signatures
        return values?.map { hash(it.toByteArray()) }?.toSet() ?: emptySet()
    }
    private fun hash(bytes: ByteArray): String = MessageDigest.getInstance("SHA-256").digest(bytes).joinToString("") { "%02x".format(it) }
    @Suppress("DEPRECATION")
    private fun code(info: PackageInfo): Long = if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()

    @Suppress("DEPRECATION")
    fun handle(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "info" -> result.success(mapOf(
                "arm64" to Build.SUPPORTED_ABIS.contains("arm64-v8a"),
                "directory" to File(activity.filesDir, "updates").canonicalPath
            ))
            "openPage" -> {
                val url = call.argument<String>("url") ?: ""
                if (!url.startsWith("https://github.com/Joao-s02/rp_music/releases/tag/")) { result.error("url", "Enlace no permitido", null); return }
                try { activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url))); result.success(null) }
                catch (_: Exception) { result.error("browser", "No se pudo abrir el navegador", null) }
            }
            "install" -> worker.execute {
                try {
                    val file = File(call.argument<String>("path") ?: "").canonicalFile
                    require(file.parentFile == File(activity.filesDir, "updates").canonicalFile && file.name == "rp-music-update.apk")
                    val digest = MessageDigest.getInstance("SHA-256")
                    file.inputStream().use { input -> val buffer = ByteArray(65536); var n = input.read(buffer); while (n >= 0) { if (n > 0) digest.update(buffer, 0, n); n = input.read(buffer) } }
                    val actualHash = digest.digest().joinToString("") { "%02x".format(it) }
                    require(actualHash == call.argument<String>("sha256"))
                    val flags = if (Build.VERSION.SDK_INT >= 28) PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES
                    val installed = activity.packageManager.getPackageInfo(activity.packageName, flags)
                    val archive = activity.packageManager.getPackageArchiveInfo(file.path, flags) ?: error("APK ilegible")
                    require(archive.packageName == activity.packageName && code(archive) > code(installed))
                    require(archive.versionName == call.argument<String>("version"))
                    require(signatures(installed).isNotEmpty() && signatures(installed) == signatures(archive))
                    activity.runOnUiThread {
                        try {
                            if (Build.VERSION.SDK_INT >= 26 && !activity.packageManager.canRequestPackageInstalls()) {
                                activity.startActivity(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:${activity.packageName}")))
                                result.success(false)
                            } else {
                                val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.updates", file)
                                activity.startActivity(Intent(Intent.ACTION_VIEW).setDataAndType(uri, "application/vnd.android.package-archive").addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION))
                                result.success(true)
                            }
                        } catch (_: Exception) { result.error("installer", "No se pudo abrir el instalador", null) }
                    }
                } catch (_: Exception) { activity.runOnUiThread { result.error("invalid_update", "Firma, versión o integridad de actualización no válida", null) } }
            }
            else -> result.notImplemented()
        }
    }
}
