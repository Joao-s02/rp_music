import 'dart:io';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/track.dart';
import 'download_context.dart';
import 'download_enrichment.dart';
import 'extension_source_service.dart';
import 'source_audio_transfer.dart';

String downloadName(String value) => value
    .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_')
    .trim()
    .replaceAll(RegExp(r'[. ]+$'), '');

class AlbumDownload extends ChangeNotifier {
  AlbumDownload(
    this.tracks,
    this.album,
    this.service, {
    this.chooseFolder,
    this.receive,
  }) {
    if (tracks.isEmpty ||
        tracks.any(
          (t) => t.sourceId == null || t.sourceId != tracks.first.sourceId,
        )) {
      throw const FormatException(
        'El álbum requiere canciones de una misma fuente.',
      );
    }
  }
  final Future<String?> Function()? chooseFolder;
  final Future<(Uint8List, String)> Function(Track, ExtensionSourceService)?
  receive;
  final List<Track> tracks;
  final DownloadContext album;
  final ExtensionSourceService service;
  bool cancelled = false, running = false, finished = false;
  int saved = 0, failed = 0, processed = 0;
  String current = '', message = '';
  final List<String> failures = [];
  final Set<int> failedIndices = {};
  final Set<int> savedIndices = {};
  String? destination;
  int receivedBytes = 0;
  int? totalBytes;
  DateTime? progressNotified;
  Future<void> retryFailed() async {
    if (running || failedIndices.isEmpty) return;
    finished = false;
    cancelled = false;
    failures.clear();
    failed = 0;
    processed = savedIndices.length;
    await run(retrying: true);
  }

  void cancel() {
    cancelled = true;
    notifyListeners();
  }

  Future<void> run({bool retrying = false}) async {
    if (running || finished) return;
    running = true;
    notifyListeners();
    try {
      const channel = MethodChannel('rp_music/library');
      final folder =
          destination ??
          (chooseFolder != null
              ? await chooseFolder!()
              : Platform.isAndroid
              ? await channel.invokeMethod<String>('chooseDownloadFolder')
              : await FilePicker.getDirectoryPath(
                  dialogTitle: 'Carpeta para el álbum',
                ));
      if (folder == null || cancelled) {
        cancelled = true;
        return;
      }
      destination = folder;
      final retryIndices = Set<int>.of(failedIndices);
      failedIndices.clear();
      final sourceId = tracks.first.sourceId!;
      final package = service.programs.installed[sourceId]?.package;
      bool stopped() =>
          cancelled ||
          !service.available(sourceId) ||
          service.programs.installed[sourceId]?.package != package ||
          !service.programs.allowed(sourceId, 'storage.download');
      // Audio payloads stream to disk; only bounded MP4 metadata enters memory.
      final coverCache = <String, (Uint8List, String)>{};
      for (var i = 0; i < tracks.length; i++) {
        if (retrying && !retryIndices.contains(i)) continue;
        if (stopped()) {
          cancelled = true;
          break;
        }
        final track = tracks[i];
        current = track.title;
        receivedBytes = 0;
        totalBytes = null;
        notifyListeners();
        Directory? temporary;
        try {
          late EnrichedDownload enriched;
          if (receive != null) {
            final audio = await receive!(track, service);
            if (stopped()) {
              cancelled = true;
              break;
            }
            enriched = await DownloadEnrichment.apply(
              track,
              audio.$1,
              audio.$2,
              service,
              albumContext: album.at(i + 1, tracks.length),
              cancelled: stopped,
              coverCache: coverCache,
            );
          } else {
            final root = Platform.isAndroid
                ? await getTemporaryDirectory()
                : Directory.systemTemp;
            temporary = await root.createTemp('rp_album_');
            final audio = await SourceAudioTransfer.receiveFile(
              track,
              service,
              temporary,
              cancelled: stopped,
              onProgress: (received, total) {
                receivedBytes = received;
                totalBytes = total;
                final now = DateTime.now();
                if (progressNotified == null ||
                    now.difference(progressNotified!).inMilliseconds >= 150) {
                  progressNotified = now;
                  notifyListeners();
                }
              },
            );
            enriched = await DownloadEnrichment.applyFile(
              track,
              audio.$1,
              audio.$2,
              service,
              albumContext: album.at(i + 1, tracks.length),
              cancelled: stopped,
              coverCache: coverCache,
            );
          }
          if (stopped()) {
            cancelled = true;
            break;
          }
          final extension = enriched.mime.contains('webm')
              ? 'webm'
              : enriched.mime.contains('mpeg')
              ? 'mp3'
              : 'm4a';
          final safe = downloadName('${album.album} - ${enriched.title}');
          final name =
              '${(i + 1).toString().padLeft(2, '0')} - ${safe.substring(0, safe.length.clamp(0, 140))}.$extension';
          if (Platform.isAndroid) {
            await channel.invokeMethod<String>('writeDownload', {
              'folder': folder,
              'name': name,
              if (enriched.file != null)
                'path': enriched.file!.path
              else
                'bytes': enriched.bytes,
              'mime': enriched.mime,
            });
          } else {
            var target = File('$folder/$name');
            var suffix = 1;
            while (await target.exists()) {
              target = File(
                '$folder/${name.substring(0, name.lastIndexOf('.'))} (${suffix++}).$extension',
              );
            }
            final temporary = File(
              '${target.path}.${DateTime.now().microsecondsSinceEpoch}.part',
            );
            try {
              if (enriched.file != null) {
                final sink = temporary.openWrite();
                try {
                  await sink.addStream(enriched.file!.openRead());
                  await sink.flush();
                } finally {
                  await sink.close();
                }
              } else {
                await temporary.writeAsBytes(enriched.bytes, flush: true);
              }
              if (stopped()) {
                cancelled = true;
                break;
              }
              await temporary.rename(target.path);
            } finally {
              if (await temporary.exists()) await temporary.delete();
            }
          }
          savedIndices.add(i);
          saved++;
          if (enriched.notice != null) message = enriched.notice!;
        } catch (error) {
          if (stopped()) {
            cancelled = true;
            break;
          }
          failedIndices.add(i);
          failed++;
          final reason = error is FormatException
              ? error.message
                    .toString()
                    .replaceAll(RegExp(r'https?://\S+'), '[enlace]')
                    .substring(
                      0,
                      error.message
                          .toString()
                          .replaceAll(RegExp(r'https?://\S+'), '[enlace]')
                          .length
                          .clamp(0, 200),
                    )
              : error is SocketException || error is TimeoutException
              ? 'No se pudo conectar con la fuente.'
              : error is FileSystemException
              ? 'No se pudo escribir en la carpeta elegida.'
              : 'No se pudo completar la descarga.';
          failures.add('${i + 1}. ${track.title}: $reason');
        } finally {
          if (temporary != null && await temporary.exists()) {
            await temporary.delete(recursive: true);
          }
        }
        processed++;
        notifyListeners();
      }
    } catch (_) {
      message = 'No se pudo abrir o escribir en la carpeta. Conserva los archivos ya guardados y reintenta.';
    } finally {
      running = false;
      finished = true;
      notifyListeners();
    }
  }
}

Future<void> showAlbumDownload(BuildContext context, AlbumDownload job) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ListenableBuilder(
      listenable: job,
      builder: (context, _) => PopScope(
        canPop: !job.running,
        child: AlertDialog(
          title: Text(job.album.album),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${job.tracks.length} canciones · misma edición, portada y numeración',
                ),
                const SizedBox(height: 12),
                if (!job.finished && !job.running)
                  const Text(
                    'Elige una carpeta una sola vez. Las canciones se guardarán por orden. No se sobrescriben archivos existentes.',
                  ),
                if (job.running)
                  LinearProgressIndicator(
                    value: job.processed / job.tracks.length,
                  ),
                if (job.current.isNotEmpty) Text(job.current),
                if (job.running && job.receivedBytes > 0) ...[
                  LinearProgressIndicator(
                    value: job.totalBytes == null
                        ? null
                        : job.receivedBytes / job.totalBytes!,
                  ),
                  Text(
                    '${(job.receivedBytes / 1048576).toStringAsFixed(1)} MiB${job.totalBytes == null ? '' : ' / ${(job.totalBytes! / 1048576).toStringAsFixed(1)} MiB'}',
                  ),
                ],
                Text('${job.saved} guardadas · ${job.failed} fallidas'),
                if (job.cancelled)
                  const Text(
                    'Cancelada: se conservan las canciones terminadas. La petición en curso terminará sin guardar otra canción.',
                  ),
                if (job.message.isNotEmpty) Text(job.message),
                if (job.failures.isNotEmpty)
                  Text('No guardadas:\n${job.failures.join('\n')}'),
              ],
            ),
          ),
          actions: [
            if (!job.running)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(job.finished ? 'Cerrar' : 'Volver'),
              ),
            if (!job.finished && !job.running)
              FilledButton(
                onPressed: job.run,
                child: const Text('Elegir carpeta y descargar'),
              ),
            if (job.finished && !job.running && job.failedIndices.isNotEmpty)
              FilledButton(
                onPressed: job.retryFailed,
                child: const Text('Reintentar fallidas'),
              ),
            if (job.running)
              TextButton(
                onPressed: job.cancelled ? null : job.cancel,
                child: Text(job.cancelled ? 'Cancelando…' : 'Cancelar'),
              ),
          ],
        ),
      ),
    ),
  );
  job.dispose();
}
