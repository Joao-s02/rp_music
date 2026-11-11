import '../domain/track.dart';
import 'extension_source_service.dart';
import 'source_audio_transfer.dart';
import 'download_enrichment.dart';
import 'download_context.dart';
import 'download_folder.dart';

class SourceDownload {
  static Future<({bool saved, String? notice})> save(
    Track track,
    ExtensionSourceService service, {
    DownloadContext? albumContext,
  }) async {
    final id = track.sourceId;
    final package = service.programs.installed[id]?.package;
    bool stopped() =>
        id == null ||
        package == null ||
        !service.available(id) ||
        service.programs.installed[id]?.package != package ||
        !service.programs.allowed(id, 'storage.download');
    if (stopped()) {
      throw const FormatException('Fuente desactivada o permiso retirado.');
    }
    final folder = await DownloadFolder.choose();
    if (folder == null) return (saved: false, notice: null);
    if (stopped()) {
      throw const FormatException('Fuente desactivada o permiso retirado.');
    }
    final bytes = await SourceAudioTransfer.receive(track, service);
    final enriched = await DownloadEnrichment.apply(
      track,
      bytes.$1,
      bytes.$2,
      service,
      albumContext: albumContext,
      cancelled: stopped,
    );
    final name = enriched.title
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_')
        .trim();
    final extension = enriched.mime.contains('webm')
        ? 'webm'
        : enriched.mime.contains('mpeg')
        ? 'mp3'
        : 'm4a';
    final written = await DownloadFolder.write(
      folder,
      name:
          '${name.isEmpty ? 'Canción' : name.substring(0, name.length.clamp(0, 100))}.$extension',
      mime: enriched.mime,
      bytes: enriched.bytes,
      cancelled: stopped,
    );
    if (!written) {
      throw const FormatException('Fuente desactivada o permiso retirado.');
    }
    return (saved: true, notice: enriched.notice);
  }
}
