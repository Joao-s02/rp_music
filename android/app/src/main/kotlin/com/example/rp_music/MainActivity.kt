package com.example.rp_music

import android.app.Activity
import android.content.Intent
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.provider.DocumentsContract
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : AudioServiceActivity() {
    private var picker: MethodChannel.Result? = null
    private val worker = Executors.newSingleThreadExecutor()
    private val extensions = setOf("mp3", "flac", "m4a", "mp4", "wav", "opus")

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "rp_music/library")
            .setMethodCallHandler { call, result ->
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
                            val value = scan(root)
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

    private fun scan(root: Uri): Map<String, Any> {
        val tracks = mutableListOf<Map<String, Any>>()
        val pending = java.util.ArrayDeque<Pair<String, String>>()
        pending.add(DocumentsContract.getTreeDocumentId(root) to ".")
        var skipped = 0
        val columns = arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME, DocumentsContract.Document.COLUMN_MIME_TYPE)
        while (pending.isNotEmpty()) {
            val (documentId, folder) = pending.removeLast()
            val children = DocumentsContract.buildChildDocumentsUriUsingTree(root, documentId)
            try {
                val cursor = contentResolver.query(children, columns, null, null, null)
                    ?: throw IllegalStateException("No se pudo consultar la carpeta")
                cursor.use {
                    while (it.moveToNext()) {
                        val id = it.getString(0)
                        val name = it.getString(1) ?: "Sin nombre"
                        if (it.getString(2) == DocumentsContract.Document.MIME_TYPE_DIR) {
                            pending.add(id to if (folder == ".") name else "$folder/$name")
                            continue
                        }
                        if (name.substringAfterLast('.', "").lowercase() !in extensions) continue
                        val uri = DocumentsContract.buildDocumentUriUsingTree(root, id)
                        var title = name.substringBeforeLast('.')
                        var artist = "Artista desconocido"
                        var album = "Sin álbum"
                        var duration = 0L
                        val retriever = MediaMetadataRetriever()
                        try {
                            retriever.setDataSource(this, uri)
                            retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)?.takeIf { v -> v.isNotBlank() }?.let { v -> title = v }
                            retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)?.takeIf { v -> v.isNotBlank() }?.let { v -> artist = v }
                            retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM)?.takeIf { v -> v.isNotBlank() }?.let { v -> album = v }
                            duration = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0
                        } catch (e: Exception) { skipped++ }
                        finally { retriever.release() }
                        tracks.add(mapOf("id" to uri.toString(), "title" to title,
                            "artist" to artist, "album" to album, "folder" to folder, "durationMs" to duration))
                    }
                }
            } catch (e: Exception) {
                if (folder == ".") throw e
                skipped++
            }
        }
        return mapOf("tracks" to tracks.sortedBy { (it["title"] as String).lowercase() }, "skipped" to skipped)
    }
}
