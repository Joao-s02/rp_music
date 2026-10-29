import 'package:flutter/material.dart';

import 'update_controller.dart';
import '../app/app_version.dart';

Future<void> showUpdateDialog(
  BuildContext context,
  UpdateController updates,
  Future<void> Function() beforeInstall,
) => showDialog<void>(
  context: context,
  builder: (context) => ListenableBuilder(
    listenable: updates,
    builder: (context, _) => AlertDialog(
      icon: const Icon(Icons.system_update_outlined),
      title: const Text('Actualización disponible'),
      scrollable: true,
      content: SizedBox(
        width: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Versión actual: $appVersion'),
            Text(
              'Nueva versión: ${updates.available?.tag ?? ''}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (updates.available case final release?) ...[
              Text(
                '${(release.size / (1024 * 1024)).toStringAsFixed(1)} MB · ${updates.android ? 'Android' : 'Windows'}',
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text('Novedades'),
                tilePadding: EdgeInsets.zero,
                children: [SelectableText(release.notes)],
              ),
            ],
            if (updates.downloading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: updates.progress),
              Text('Descargando ${(updates.progress * 100).round()} %'),
              TextButton(
                onPressed: updates.cancelDownload,
                child: const Text('Cancelar descarga'),
              ),
            ],
            if (updates.message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(updates.message!),
              ),
            const SizedBox(height: 12),
            Text(
              updates.manualAndroidUpdates
                  ? 'Descarga desde la página oficial y abre el APK en Archivos. No desinstales la app.'
                  : updates.android
                  ? 'La descarga se realiza aquí. Android te pedirá confirmar la instalación.'
                  : 'El ZIP se descarga aquí. Después deberás extraerlo y cerrar la versión anterior desde la bandeja.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: updates.installing ? null : () => Navigator.pop(context),
          child: const Text('Actualizar después'),
        ),
        if (!updates.downloading)
          FilledButton.icon(
            onPressed: updates.installing
                ? null
                : () async {
                    if (updates.manualAndroidUpdates) {
                      await updates.openRelease();
                    } else if (updates.downloaded == null) {
                      await updates.download();
                    } else if (updates.android) {
                      await beforeInstall();
                      await updates.install();
                    } else {
                      await updates.revealDownload();
                    }
                  },
            icon: Icon(
              updates.manualAndroidUpdates
                  ? Icons.open_in_browser
                  : updates.downloaded == null
                  ? Icons.download
                  : updates.android
                  ? Icons.install_mobile
                  : Icons.folder_open,
            ),
            label: Text(
              updates.manualAndroidUpdates
                  ? 'Descargar desde la web'
                  : updates.downloaded == null
                  ? 'Actualizar · descargar'
                  : updates.android
                  ? 'Instalar actualización'
                  : 'Mostrar ZIP descargado',
            ),
          ),
      ],
    ),
  ),
);

/// Presents one centered offer per successful check; postponing does not skip a version.
class UpdateNotice extends StatefulWidget {
  const UpdateNotice({
    super.key,
    required this.updates,
    required this.beforeInstall,
  });
  final UpdateController updates;
  final Future<void> Function() beforeInstall;
  @override
  State<UpdateNotice> createState() => _UpdateNoticeState();
}

class _UpdateNoticeState extends State<UpdateNotice> {
  int shown = -1;
  bool open = false;
  @override
  void initState() {
    super.initState();
    widget.updates.addListener(offer);
    offer();
  }

  void offer() {
    if (!mounted ||
        open ||
        widget.updates.available == null ||
        shown == widget.updates.noticeSerial) {
      return;
    }
    shown = widget.updates.noticeSerial;
    open = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showUpdateDialog(context, widget.updates, widget.beforeInstall);
      open = false;
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  void dispose() {
    widget.updates.removeListener(offer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
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
            FilledButton.tonalIcon(
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
              OutlinedButton.icon(
                onPressed: () =>
                    showUpdateDialog(context, updates, beforeInstall),
                icon: const Icon(Icons.system_update),
                label: const Text('Ver actualización'),
              ),
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
              ] else if (updates.manualAndroidUpdates)
                FilledButton.icon(
                  onPressed: updates.openRelease,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Descargar desde la web'),
                )
              else if (updates.downloaded != null)
                FilledButton.icon(
                  onPressed: updates.installing
                      ? null
                      : () async {
                          if (updates.android) {
                            await beforeInstall();
                            await updates.install();
                          } else {
                            await updates.revealDownload();
                          }
                        },
                  icon: const Icon(Icons.install_mobile),
                  label: Text(
                    updates.android
                        ? 'Instalar actualización'
                        : 'Mostrar ZIP descargado',
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: updates.download,
                  icon: const Icon(Icons.download),
                  label: Text('Descargar actualización'),
                ),
              if (updates.android && !updates.manualAndroidUpdates)
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
