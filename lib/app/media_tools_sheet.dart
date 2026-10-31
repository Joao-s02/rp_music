import 'dart:io';

import 'package:flutter/material.dart';

import '../platform/media_tools.dart';

Future<void> showMediaTools(
  BuildContext context,
  MediaToolRequest request, {
  MediaToolPlatform platform = const NativeMediaTools(),
  Future<void> Function()? beforeOpen,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: FutureBuilder<List<MediaTool>>(
          future: platform.installed(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final tools = snapshot.data ?? [];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear un edit',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (snapshot.hasError)
                  const Text('No se pudieron consultar los complementos.'),
                if (tools.isEmpty) ...[
                  Text(
                    Platform.isWindows
                        ? 'El editor para Windows está pendiente. RP Music conserva la reproducción habitual.'
                        : 'Instala el complemento RP Edits para crear vídeos. Se instala por separado y no modifica tu música.',
                  ),
                  const SizedBox(height: 12),
                  const SelectableText('https://github.com/Joao-s02/rp_edits'),
                ],
                for (final tool in tools)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.movie_creation_outlined),
                    title: Text(tool.name),
                    subtitle: const Text('Editar una copia de esta canción'),
                    onTap: () async {
                      try {
                        request.toJson();
                        await beforeOpen?.call();
                        await platform.open(tool, request);
                        if (context.mounted) Navigator.pop(context);
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                error is FormatException
                                    ? error.message.toString()
                                    : 'No se pudo abrir el editor. Revisa su instalación y vuelve a intentarlo.',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
