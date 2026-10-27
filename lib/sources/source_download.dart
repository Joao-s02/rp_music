import 'package:file_picker/file_picker.dart';

import '../domain/track.dart';
import 'extension_source_service.dart';
import 'source_audio_transfer.dart';

class SourceDownload {
  static Future<bool> save(Track track, ExtensionSourceService service) async {
    final bytes = await SourceAudioTransfer.receive(
      track,
      service,
    );
    final name = track.title
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_')
        .trim();
    final extension = bytes.$2.contains('webm')
        ? 'webm'
        : bytes.$2.contains('mpeg')
        ? 'mp3'
        : 'm4a';
    final path = await FilePicker.saveFile(
      dialogTitle: 'Guardar canción',
      fileName:
          '${name.isEmpty ? 'Canción' : name.substring(0, name.length.clamp(0, 100))}.$extension',
      bytes: bytes.$1,
      mimeType: bytes.$2,
    );
    return path != null;
  }
}
