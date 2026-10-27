import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import '../domain/track.dart';
import 'library_scanner.dart';
import 'embedded_lyrics.dart';
export 'library_scanner.dart';

const _channel = MethodChannel('rp_music/library');

void _scanWorker((String, List<Track>, SendPort) request) {
  final (root, cached, port) = request;
  try {
    final result = scanDirectory(
      root,
      cached: cached,
      onProgress: (progress) => port.send(progress),
    );
    port.send(result);
  } catch (_) {
    port.send('No se pudo leer la carpeta.');
  }
}

class MusicFiles {
  /// Reads tags only. Android grants are used to create a bounded private copy;
  /// the original document is never opened for writing.
  Future<String?> embeddedLyrics(String id) async {
    if (id.startsWith('rpmusic-source:')) return null;
    String? temporary;
    try {
      final path = Platform.isAndroid
          ? temporary = await _channel.invokeMethod<String>('lyricsFile', {
              'id': id,
            })
          : id;
      if (path == null) return null;
      return await Isolate.run(() => EmbeddedLyrics.read(File(path)));
    } finally {
      if (temporary != null) {
        try {
          await File(temporary).delete();
        } catch (_) {
          /* Private cache. */
        }
      }
    }
  }

  Future<String?> chooseRoot() => Platform.isAndroid
      ? _channel.invokeMethod<String>('chooseRoot')
      : FilePicker.getDirectoryPath(
          dialogTitle: 'Seleccionar carpeta de música',
        );

  Future<ScanResult> scan(
    String root, {
    List<Track> cached = const [],
    void Function(ScanProgress)? onProgress,
  }) async {
    if (Platform.isAndroid) {
      _channel.setMethodCallHandler((call) async {
        if (call.method != 'scanProgress') return;
        final map = Map<String, dynamic>.from(call.arguments as Map);
        onProgress?.call(
          ScanProgress(
            (map['tracks'] as List)
                .map((t) => Track.fromJson(Map<String, dynamic>.from(t as Map)))
                .toList(),
            map['processed'] as int,
            map['total'] as int,
            discovery: map['discovery'] as bool? ?? false,
          ),
        );
      });
      try {
        final result = await _channel.invokeMapMethod<String, dynamic>('scan', {
          'root': root,
          'cached': cached.map((t) => t.toJson()).toList(),
        });
        return ScanResult(
          (result!['tracks'] as List)
              .map((t) => Track.fromJson(Map<String, dynamic>.from(t as Map)))
              .toList(),
          result['skipped'] as int? ?? 0,
        );
      } finally {
        _channel.setMethodCallHandler(null);
      }
    }
    final port = ReceivePort();
    final done = Completer<ScanResult>();
    final subscription = port.listen((event) {
      if (event is ScanProgress) {
        onProgress?.call(event);
      } else if (event is ScanResult) {
        done.complete(event);
      } else if (!done.isCompleted) {
        done.completeError(
          const FileSystemException('No se pudo leer la carpeta.'),
        );
      }
    });
    Isolate? worker;
    try {
      worker = await Isolate.spawn(_scanWorker, (
        root,
        cached,
        port.sendPort,
      ), onError: port.sendPort);
      return await done.future;
    } finally {
      await subscription.cancel();
      port.close();
      worker?.kill();
    }
  }

  Future<bool> ensureWritable(String root) async =>
      !Platform.isAndroid ||
      (await _channel.invokeMethod<bool>('ensureWritable', {'root': root}) ??
          false);

  Future<void> delete(String id) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod<void>('deleteTrack', {'id': id});
    } else {
      await File(id).delete();
    }
  }

  Future<Uri?> notificationArtwork(String id) async {
    if (!Platform.isAndroid) return null;
    final value = await _channel.invokeMethod<String>('artworkUri', {'id': id});
    return value == null ? null : Uri.parse(value);
  }

  Future<Uint8List?> artwork(String id) async {
    if (Platform.isAndroid) {
      return _channel.invokeMethod<Uint8List>('artwork', {'id': id});
    }
    return Isolate.run(() {
      try {
        return readMetadata(
          File(id),
          getImage: true,
        ).pictures.firstOrNull?.bytes;
      } catch (_) {
        return null;
      }
    });
  }
}
