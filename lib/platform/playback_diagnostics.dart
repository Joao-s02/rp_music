import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_version.dart';
import '../playback/music_handler.dart';
import 'android_notifications.dart';

Future<void> showDiagnostics(
  BuildContext context,
  MusicHandler audio,
  AndroidNotifications? notifications,
) => showDialog<void>(
  context: context,
  builder: (_) => DiagnosticsDialog(audio: audio, notifications: notifications),
);

class DiagnosticsDialog extends StatefulWidget {
  const DiagnosticsDialog({super.key, required this.audio, this.notifications});
  final MusicHandler audio;
  final AndroidNotifications? notifications;
  @override
  State<DiagnosticsDialog> createState() => _DiagnosticsDialogState();
}

class _DiagnosticsDialogState extends State<DiagnosticsDialog> {
  String text = 'Consultando…';
  String? status;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    final native = <String, dynamic>{};
    try {
      native.addAll(await widget.notifications?.diagnostics() ?? {});
    } catch (_) {
      native['consulta'] = 'No disponible';
    }
    if (!mounted) return;
    final state = widget.audio.playbackState.value;
    setState(() {
      text = [
        'RP Music $appVersion+$appBuild · diagnóstico multimedia',
        'UTC: ${DateTime.now().toUtc().toIso8601String()}',
        'Reproducción: ${state.playing ? 'activa' : 'pausada'}',
        'Audio: ${state.processingState.name}; posición: ${state.position.inSeconds}s; cola: ${widget.audio.tracks.length}; índice: ${widget.audio.index}',
        for (final entry in native.entries) '${entry.key}: ${entry.value}',
        'Último error del servicio: ${widget.audio.lastSystemError ?? 'ninguno registrado'}',
        'Último error de audio: ${widget.audio.lastPlaybackError ?? 'ninguno registrado'}',
        'Eventos recientes (sesión actual):',
        ...widget.audio.diagnosticEvents,
      ].join('\n');
      status = null;
    });
  }

  Future<void> perform(Future<String?> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final value = await action();
      if (mounted) setState(() => status = value);
    } catch (_) {
      if (mounted) {
        setState(() => status = 'No se pudo completar la operación.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Diagnóstico multimedia'),
    content: SizedBox(
      width: 560,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(text),
            if (status != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(status!),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: busy
            ? null
            : () => perform(() async {
                await Clipboard.setData(ClipboardData(text: text));
                return 'Texto copiado.';
              }),
        child: const Text('Copiar texto'),
      ),
      TextButton(
        onPressed: busy
            ? null
            : () => perform(() async {
                final saved = await FilePicker.saveFile(
                  fileName: 'RP-Music-diagnostico.txt',
                  bytes: Uint8List.fromList(utf8.encode(text)),
                  mimeType: 'text/plain',
                );
                return saved == null
                    ? 'Exportación cancelada.'
                    : 'Log exportado.';
              }),
        child: const Text('Exportar log'),
      ),
      TextButton(
        onPressed: busy
            ? null
            : () => perform(() async {
                final selected = await FilePicker.pickFile(
                  type: FileType.custom,
                  allowedExtensions: ['txt', 'log'],
                );
                if (selected?.path == null) return 'Importación cancelada.';
                final file = File(selected!.path!);
                if (await file.length() > 256 * 1024) {
                  return 'El log supera 256 KB.';
                }
                final value = utf8.decode(
                  await file.readAsBytes(),
                  allowMalformed: true,
                );
                if (mounted) setState(() => text = value);
                return 'Log importado para lectura. No se ejecuta ni se envía a ningún servidor.';
              }),
        child: const Text('Importar log'),
      ),
      TextButton(
        onPressed: busy ? null : refresh,
        child: const Text('Actualizar'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cerrar'),
      ),
    ],
  );
}
