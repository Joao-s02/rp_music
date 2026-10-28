package com.example.rp_music

import android.content.Context
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.os.Build
import java.util.concurrent.Executors

/** Discovery first, bounded metadata workers, and fingerprint cache reuse. */
class LibraryScanner(private val context: Context,
    private val progress: (Map<String, Any>) -> Unit) {
    private val extensions = setOf("mp3", "flac", "m4a", "mp4", "wav", "opus")
    fun scan(root: Uri, cached: List<Map<String, Any>>): Map<String, Any> {
        val tracks = mutableListOf<Map<String, Any>>()
        val known = cached.associateBy { it["id"] as String }
        val pending = java.util.ArrayDeque<Pair<String, String>>()
        val seen = mutableSetOf<String>()
        pending.add(DocumentsContract.getTreeDocumentId(root) to ".")
        var skipped = 0
        val columns = arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME, DocumentsContract.Document.COLUMN_MIME_TYPE,
            DocumentsContract.Document.COLUMN_SIZE, DocumentsContract.Document.COLUMN_LAST_MODIFIED)
        while (pending.isNotEmpty()) {
            val (documentId, folder) = pending.removeLast()
            if (!seen.add(documentId)) continue
            try {
                val children = DocumentsContract.buildChildDocumentsUriUsingTree(root, documentId)
                val cursor = context.contentResolver.query(children, columns, null, null, null)
                    ?: throw IllegalStateException("Carpeta no disponible")
                cursor.use {
                    while (it.moveToNext()) {
                        val id = it.getString(0)
                        val name = it.getString(1) ?: "Sin nombre"
                        if (it.getString(2) == DocumentsContract.Document.MIME_TYPE_DIR) {
                            pending.add(id to if (folder == ".") name else "$folder/$name"); continue
                        }
                        if (name.substringAfterLast('.', "").lowercase() !in extensions) continue
                        val uri = DocumentsContract.buildDocumentUriUsingTree(root, id)
                        tracks.add(mapOf("id" to uri.toString(), "title" to name.substringBeforeLast('.'),
                            "artist" to "Artista desconocido", "album" to "Sin álbum", "folder" to folder,
                            "durationMs" to 0L, "size" to if (it.isNull(3)) 0L else it.getLong(3),
                            "modifiedMs" to if (it.isNull(4)) 0L else it.getLong(4)))
                    }
                }
            } catch (e: Exception) { if (folder == ".") throw e; skipped++ }
        }
        progress(mapOf("tracks" to tracks.toList(), "processed" to 0, "total" to tracks.size, "discovery" to true))
        val workers = Executors.newFixedThreadPool(2)
        try {
            val futures = tracks.map { file -> workers.submit<Pair<Map<String, Any>, Boolean>> {
                val old = known[file["id"]]
                val modified = (file["modifiedMs"] as Number).toLong()
                if (old != null && old["metadataLoaded"] == true && (old["metadataVersion"] as? Number)?.toInt() == 2 && modified > 0 && (old["modifiedMs"] as? Number)?.toLong() == modified &&
                    (old["size"] as? Number)?.toLong() == (file["size"] as Number).toLong()) {
                    old to false
                } else readTags(file)
            } }
            var batch = mutableListOf<Map<String, Any>>()
            var last = System.nanoTime()
            for (i in futures.indices) {
                val (track, failed) = futures[i].get()
                if (failed) skipped++
                tracks[i] = track; batch.add(track)
                if (batch.size >= 32 || System.nanoTime() - last >= 160_000_000L || i == futures.lastIndex) {
                    progress(mapOf("tracks" to batch.toList(), "processed" to i + 1, "total" to tracks.size, "discovery" to false))
                    batch = mutableListOf(); last = System.nanoTime()
                }
            }
        } finally { workers.shutdownNow() }
        return mapOf("tracks" to tracks.sortedBy { (it["title"] as String).lowercase() }, "skipped" to skipped)
    }

    private fun readTags(file: Map<String, Any>): Pair<Map<String, Any>, Boolean> {
        // Reuse Android's media index when the granted document can be mapped.
        // No broad media permission is requested; unsupported providers fall back.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                val mediaUri = MediaStore.getMediaUri(context, Uri.parse(file["id"] as String))
                if (mediaUri != null) {
                    val columns = arrayOf(MediaStore.Audio.Media.TITLE, MediaStore.Audio.Media.ARTIST,
                        MediaStore.Audio.Media.ALBUM, MediaStore.Audio.Media.DURATION, "album_artist", MediaStore.Audio.Media.TRACK)
                    context.contentResolver.query(mediaUri, columns, null, null, null)?.use { cursor ->
                        if (cursor.moveToFirst() && !cursor.isNull(3) && cursor.getLong(3) > 0) {
                            val data = file.toMutableMap()
                            for ((index, field) in listOf("title", "artist", "album").withIndex()) {
                                cursor.getString(index)?.takeIf { it.isNotBlank() && it != "<unknown>" }?.let { data[field] = it }
                            }
                            cursor.getString(4)?.takeIf { it.isNotBlank() && it != "<unknown>" }?.let { data["albumArtist"] = it }
                            val track = cursor.getInt(5)
                            data["trackNumber"] = track % 1000
                            data["discNumber"] = track / 1000
                            data["durationMs"] = cursor.getLong(3)
                            data["metadataLoaded"] = true
                            data["metadataVersion"] = 2
                            return data to false
                        }
                    }
                }
            } catch (e: Exception) { /* Fall back to the granted document itself. */ }
        }
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(context, Uri.parse(file["id"] as String))
            val data = file.toMutableMap()
            for ((field, key) in listOf("title" to MediaMetadataRetriever.METADATA_KEY_TITLE,
                "artist" to MediaMetadataRetriever.METADATA_KEY_ARTIST, "album" to MediaMetadataRetriever.METADATA_KEY_ALBUM, "albumArtist" to MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST)) {
                retriever.extractMetadata(key)?.takeIf { it.isNotBlank() }?.let { data[field] = it }
            }
            data["trackNumber"] = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER)?.substringBefore("/")?.toIntOrNull() ?: 0
            data["discNumber"] = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DISC_NUMBER)?.substringBefore("/")?.toIntOrNull() ?: 0
            data["durationMs"] = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0L
            data["metadataLoaded"] = true
            data["metadataVersion"] = 2
            return data to false
        } catch (e: Exception) { return file to true }
        finally { retriever.release() }
    }
}
