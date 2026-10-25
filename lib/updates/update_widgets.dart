import 'package:flutter/material.dart';

import 'update_controller.dart';

class UpdateNotice extends StatelessWidget {
  const UpdateNotice({super.key, required this.updates, required this.onOpen});
  final UpdateController updates;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: updates,
    builder: (context, _) => updates.available == null
        ? const SizedBox.shrink()
        : MaterialBanner(
            content: Text('Nueva versión: ${updates.available!.tag}'),
            actions: [
              TextButton(
                onPressed: onOpen,
                child: const Text('Ver actualización'),
              ),
              TextButton(
                onPressed: updates.downloading ? null : updates.skip,
                child: const Text('Omitir'),
              ),
            ],
          ),
  );
}

class UpdateSettings extends StatelessWidget {
  const UpdateSettings({
    super.key,
    required this.updates,
    required this.beforeInstall,
  });
  final UpdateController updates;
  final Future<void> Function() beforeInstall;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: updates,
    builder: (context, _) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actualizaciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text(
              'La música funciona sin internet. Las consultas de versión son opcionales.',
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Buscar automáticamente'),
              subtitle: const Text(
                'Como máximo una vez al día, sin retrasar el inicio.',
              ),
              value: updates.automatic,
              onChanged: updates.setAutomatic,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Incluir versiones de prueba'),
              value: updates.previews,
              onChanged: updates.downloading ? null : updates.setPreviews,
            ),
            TextButton.icon(
              onPressed: updates.checking || updates.downloading
                  ? null
                  : () => updates.check(manual: true),
              icon: const Icon(Icons.system_update),
              label: Text(
                updates.checking ? 'Consultando…' : 'Buscar actualizaciones',
              ),
            ),
            if (updates.message != null) Text(updates.message!),
            if (updates.available case final release?) ...[
              const Divider(),
              Text(release.tag, style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${(release.size / (1024 * 1024)).toStringAsFixed(1)} MB · ${updates.android ? 'Android' : 'Windows'}',
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Novedades'),
                children: [SelectableText(release.notes)],
              ),
              if (updates.downloading) ...[
                LinearProgressIndicator(value: updates.progress),
                TextButton(
                  onPressed: updates.cancelDownload,
                  child: const Text('Cancelar descarga'),
                ),
              ] else if (updates.downloaded != null)
                FilledButton.icon(
                  onPressed: updates.installing
                      ? null
                      : () async {
                          await beforeInstall();
                          await updates.install();
                        },
                  icon: const Icon(Icons.install_mobile),
                  label: const Text('Instalar actualización'),
                )
              else
                FilledButton.icon(
                  onPressed: updates.android
                      ? updates.download
                      : updates.openRelease,
                  icon: const Icon(Icons.download),
                  label: Text(
                    updates.android
                        ? 'Descargar actualización'
                        : 'Abrir descarga de Windows',
                  ),
                ),
              if (updates.android)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Android puede pedir autorización para instalar desde RP Music. La instalación reinicia la app.',
                  ),
                ),
            ],
          ],
        ),
      ),
    ),
  );
}
