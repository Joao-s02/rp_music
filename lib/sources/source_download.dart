import 'package:file_picker/file_picker.dart';

import '../domain/track.dart';
import 'extension_source_service.dart';
import 'source_audio_transfer.dart';
import 'download_enrichment.dart';
import 'download_context.dart';

class SourceDownload {
  static Future<({bool saved, String? notice})> save(
    Track track,
    ExtensionSourceService service, {
    DownloadContext? albumContext,
  }) async {
    final id = track.sourceId;
    final package = service.programs.installed[id]?.package;
    final bytes = await SourceAudioTransfer.receive(track, service);
    final enriched = await DownloadEnrichment.apply(
      track,
      bytes.$1,
      bytes.$2,
      service,
      albumContext: albumContext,
    );
    if (id == null ||
        package == null ||
        !service.available(id) ||
        service.programs.installed[id]?.package != package ||
        !service.programs.allowed(id, 'storage.download')) {
      throw const FormatException('Fuente desactivada o permiso retirado.');
    }
    final name = enriched.title
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_')
        .trim();
    final extension = enriched.mime.contains('webm')
        ? 'webm'
        : enriched.mime.contains('mpeg')
        ? 'mp3'
        : 'm4a';
    final path = await FilePicker.saveFile(
      dialogTitle: 'Guardar canción',
      fileName:
          '${name.isEmpty ? 'Canción' : name.substring(0, name.length.clamp(0, 100))}.$extension',
      bytes: enriched.bytes,
      mimeType: enriched.mime,
    );
    return (saved: path != null, notice: enriched.notice);
  }
}
