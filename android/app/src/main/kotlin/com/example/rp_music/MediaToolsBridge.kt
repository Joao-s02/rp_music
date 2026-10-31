package com.example.rp_music

import android.app.Activity
import android.content.*
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File
import java.util.concurrent.Executor

/** Generic, explicitly invoked media handoff to separately installed companions. */
class MediaToolsBridge(private val activity: Activity, private val worker: Executor) {
    private val action="com.rpmusic.OPEN_MEDIA_PROJECT"
    private val mime="application/vnd.rpmusic.project+json"
    private fun available() = activity.packageManager.queryIntentActivities(Intent(action).setType(mime),PackageManager.GET_META_DATA).filter {
        it.activityInfo.exported && it.activityInfo.metaData?.getInt("com.rpmusic.protocol")==1 &&
            activity.packageManager.checkSignatures(activity.packageName,it.activityInfo.packageName)==PackageManager.SIGNATURE_MATCH
    }
    fun handle(call: MethodCall,result: MethodChannel.Result) {
        when(call.method) {
            "installed" -> result.success(available().map { mapOf("id" to ComponentName(it.activityInfo.packageName,it.activityInfo.name).flattenToString(),"name" to it.loadLabel(activity.packageManager).toString()) })
            "open" -> worker.execute {
                try {
                    val id=call.argument<String>("tool")?:error("Falta complemento")
                    val target=available().firstOrNull { ComponentName(it.activityInfo.packageName,it.activityInfo.name).flattenToString()==id }?:error("Complemento no autorizado")
                    val input=call.argument<Map<String,Any?>>("request")?:error("Falta proyecto")
                    require(input["protocol"]==1 || input["protocol"]==1L)
                    val directory=File(activity.cacheDir,"media_tools").apply { mkdirs() }
                    directory.listFiles()?.filter { System.currentTimeMillis()-it.lastModified()>86400000 }?.forEach { it.delete() }
                    fun shareFile(file: File)=FileProvider.getUriForFile(activity,"${activity.packageName}.media_tools",file)
                    fun asset(value: String,kind: String): Uri {
                        val uri=Uri.parse(value)
                        if(uri.scheme=="content") return uri
                        require(uri.scheme==null || uri.scheme=="file") { "Solo archivos locales" }
                        val file=File(if(uri.scheme=="file") requireNotNull(uri.path) else value)
                        require(file.isFile && file.length()<=2L*1024*1024*1024)
                        val copy=File.createTempFile(kind,".media",directory)
                        try { file.inputStream().use { source -> copy.outputStream().use { source.copyTo(it) } } } catch(t: Throwable) { copy.delete(); throw t }
                        return shareFile(copy)
                    }
                    val audio=asset(input["audioId"] as String,"audio")
                    val lyrics=input["lyrics"] as? String?:""; require(lyrics.toByteArray(Charsets.UTF_8).size<=262144)
                    val payload=JSONObject().put("protocol",1).put("title",(input["title"] as? String?:"Nuevo edit").take(160)).put("artist",(input["artist"] as? String?:"").take(160)).put("lyrics",lyrics).put("audioUri",audio.toString())
                    val uris=mutableListOf(audio)
                    val cover=input["artwork"] as? String
                    if(!cover.isNullOrEmpty() && !cover.startsWith("https:")) {
                        // Artwork is optional: a stale cover must not prevent opening audio.
                        runCatching { asset(cover,"cover") }.getOrNull()?.let { payload.put("coverUri",it.toString()); uris.add(it) }
                    }
                    val json=File.createTempFile("project",".json",directory).apply { writeText(payload.toString(),Charsets.UTF_8) }
                    val requestUri=shareFile(json); uris.add(requestUri)
                    val clip=ClipData.newUri(activity.contentResolver,"Proyecto multimedia",requestUri)
                    uris.filter { it!=requestUri }.forEach { clip.addItem(ClipData.Item(it)) }
                    activity.runOnUiThread {
                        try {
                            check(available().any { it.activityInfo.packageName==target.activityInfo.packageName && it.activityInfo.name==target.activityInfo.name })
                            activity.startActivity(Intent(action).apply { component=ComponentName(target.activityInfo.packageName,target.activityInfo.name); setDataAndType(requestUri,mime); clipData=clip; addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION) })
                            result.success(null)
                        } catch(e: Exception) { result.error("media_tool","No se pudo abrir el complemento",null) }
                    }
                } catch(e: Exception) { activity.runOnUiThread { result.error("media_tool",e.message?:"No se pudo preparar el proyecto",null) } }
            }
            else -> result.notImplemented()
        }
    }
}
