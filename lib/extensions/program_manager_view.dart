import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'program_catalog.dart';
import 'javascript_screen_view.dart';
import '../sources/extension_source_view.dart';
import '../playback/music_handler.dart';

import '../app/library_controller.dart';
import '../domain/extension_manifest.dart';
import 'program_controller.dart';
import 'program_package.dart';

class ProgramManagerView extends StatefulWidget {
  const ProgramManagerView({super.key, required this.library, this.audio});
  final LibraryController library;
  final MusicHandler? audio;
  @override
  State<ProgramManagerView> createState() => _ProgramManagerViewState();
}

class _ProgramManagerViewState extends State<ProgramManagerView> {
  bool working = false;
  final repositoryInput = TextEditingController(
    text: 'https://github.com/Joao-s02/rp-music-extensions',
  );
  @override
  void dispose() {
    repositoryInput.dispose();
    super.dispose();
  }

  ProgramController? get programs => widget.library.programs;
  void message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<(Set<String>, bool)?> permissions(
    ProgramPackage package, {
    Set<String>? current,
  }) async {
    final grants = Set<String>.of(current ?? {});
    return showDialog<(Set<String>, bool)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: Text(
            '${programs?.installed.containsKey(package.id) == true ? 'Revisar / actualizar' : 'Instalar'} ${package.name}',
          ),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${package.id} · ${package.version} · ${package.advanced ? 'Avanzada' : 'Normal'}',
              ),
              const SizedBox(height: 8),
              Text(package.description),
              if (package.sourceSpec != null)
                Text('Dominios: ${package.sourceSpec!.domains.join(", ")}'),
              if (package.advanced)
                const Text(
                  'Puede sustituir funciones base; no obtiene acceso general al sistema ni a tus archivos.',
                ),
              const SizedBox(height: 12),
              const Text(
                'Código experimental sin firma de autor. Instala archivos de confianza. El acceso se limita a los permisos que aceptes; no obtiene escritura sobre tu música.',
              ),
              for (final permission in package.permissions)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(programPermissions[permission]!),
                  value: grants.contains(permission),
                  onChanged: (value) => setDialog(() {
                    if (value == true) {
                      grants.add(permission);
                    } else {
                      grants.remove(permission);
                    }
                  }),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, (grants, false)),
              child: const Text('Guardar desactivada'),
            ),
            FilledButton(
              onPressed: grants.containsAll(package.permissions)
                  ? () => Navigator.pop(context, (grants, true))
                  : null,
              child: const Text('Aceptar y activar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> import() async {
    if (working || programs?.busy == true) return;
    setState(() {
      working = true;
    });
    try {
      final picked = await FilePicker.pickFile();
      if (picked?.path == null) return;
      final file = File(picked!.path!);
      if (await file.length() > 128 * 1024) {
        throw const FormatException('El paquete supera 128 KB.');
      }
      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, dynamic>) {
        throw const FormatException('Paquete inválido.');
      }
      if (json['apiVersion'] == 1) {
        await widget.library.installDeclarative(ExtensionManifest.parse(json));
      } else {
        if (programs == null) {
          throw const FormatException('El motor no está conectado.');
        }
        final package = ProgramPackage.parse(json);
        if (!mounted) return;
        final decision = await permissions(package);
        if (decision == null) return;
        await programs!.install(package, decision.$1, enable: decision.$2);
      }
      message('Extensión importada. Revisa las funciones activas.');
    } catch (error) {
      message(
        error is FormatException
            ? error.message
            : 'No se pudo importar el paquete.',
      );
    } finally {
      if (mounted) {
        setState(() {
          working = false;
        });
      }
    }
  }

  Future<void> openCatalog() async {
    final input = repositoryInput;
    final link = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Repositorio de extensiones'),
        scrollable: true,
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Consulta un repositorio público de GitHub. Solo se conecta al consultar o descargar; ninguna extensión se activa sin revisar sus permisos.',
              ),
              TextField(
                controller: input,
                decoration: const InputDecoration(
                  labelText: 'Enlace del repositorio',
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text),
            child: const Text('Consultar'),
          ),
        ],
      ),
    );
    if (link == null || !mounted) return;
    setState(() => working = true);
    try {
      final catalog = await ProgramCatalog.load(link);
      if (!mounted) return;
      Widget catalogTile(CatalogEntry item, BuildContext dialogContext) {
        final installed = programs?.installed[item.id];
        final update =
            installed != null && item.offersUpdate(installed.package.version);
        final available = installed == null || update;
        final status = installed == null
            ? 'Descargar'
            : update
            ? 'Actualizar'
            : 'Instalada';
        return Card(
          child: ListTile(
            title: Text(item.name),
            subtitle: Text(
              '${item.version} · ${item.description}\n$status${installed == null ? '' : ' · versión local ${installed.package.version}'}',
            ),
            trailing: Icon(
              available ? Icons.download_outlined : Icons.check_circle_outline,
            ),
            onTap: available ? () => Navigator.pop(dialogContext, item) : null,
          ),
        );
      }

      final entry = await showDialog<CatalogEntry>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Extensiones disponibles'),
          content: SizedBox(
            width: 480,
            height: 340,
            child: catalog.entries.isEmpty
                ? const Text('Este repositorio todavía no tiene extensiones.')
                : ListView(
                    children: [
                      Text(catalog.repository),
                      for (final item in catalog.entries)
                        catalogTile(item, context),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
      if (entry == null) return;
      final package = await catalog.download(entry);
      if (!mounted) return;
      final decision = await permissions(package);
      if (decision == null) return;
      await programs!.install(package, decision.$1, enable: decision.$2);
      message('Extensión instalada desde el repositorio.');
    } catch (error) {
      message(
        error is FormatException
            ? error.message
            : 'No se pudo consultar o instalar la extensión.',
      );
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = widget.library;
    final manager = programs;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Extensiones', style: Theme.of(context).textTheme.headlineMedium),
        const Text(
          'Instala extensiones Dart o JavaScript desde archivo, revisa sus permisos y elige quién controla cada función. Las extensiones JSON anteriores siguen disponibles.',
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: working || manager?.busy == true ? null : import,
          icon: const Icon(Icons.file_open_outlined),
          label: const Text('Importar extensión'),
        ),
        OutlinedButton.icon(
          onPressed: working || manager == null || manager.busy
              ? null
              : openCatalog,
          icon: const Icon(Icons.cloud_download_outlined),
          label: const Text('Explorar repositorio'),
        ),
        if (working) const LinearProgressIndicator(),
        OutlinedButton.icon(
          onPressed: () async {
            await manager?.restoreBase();
            await library.activateExtension(null);
          },
          icon: const Icon(Icons.shield_outlined),
          label: const Text('Volver a la base · modo seguro'),
        ),
        if (manager?.message != null) Text(manager!.message!),
        if (manager != null) ...[
          const SizedBox(height: 16),
          Text(
            'Quién controla cada función',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'Puedes activar varias. Si compiten por la misma función, elige aquí cuál usar.',
          ),
          for (final slot in programSlots.entries.where(
            (slot) => slot.key != 'lists' && slot.key != 'screen',
          ))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: DropdownButtonFormField<String>(
                key: ValueKey(
                  '${slot.key}:${manager.owner(slot.key)?.package.id}:${manager.installed.values.where((item) => item.enabled).length}',
                ),
                initialValue: manager.owner(slot.key)?.package.id ?? '',
                isExpanded: true,
                decoration: InputDecoration(labelText: slot.value),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Aplicación base'),
                  ),
                  for (final item in manager.installed.values.where(
                    (item) =>
                        item.enabled &&
                        item.authorized &&
                        item.package.slots.contains(slot.key),
                  ))
                    DropdownMenuItem(
                      value: item.package.id,
                      child: Text(
                        item.package.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: manager.busy
                    ? null
                    : (id) => manager.choose(slot.key, id == '' ? null : id),
              ),
            ),
          const SizedBox(height: 20),
          for (final item in manager.installed.values)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${item.package.name} · ${item.package.version}',
                      ),
                      subtitle: Text(item.package.description),
                      value: item.enabled,
                      onChanged: manager.busy || !item.authorized
                          ? null
                          : (value) =>
                                manager.setEnabled(item.package.id, value),
                    ),
                    Text(
                      item.authorized
                          ? 'Permisos aceptados · última ejecución ${item.lastMs} ms · fallos ${item.failures}/3'
                          : 'Sin todos los permisos: permanece desactivada',
                    ),
                    if (item.error != null) SelectableText(item.error!),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (item.package.engine == 'javascript' &&
                            widget.audio != null)
                          TextButton.icon(
                            onPressed: !item.enabled || !item.authorized
                                ? null
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => Scaffold(
                                        appBar: AppBar(
                                          title: Text(item.package.name),
                                        ),
                                        body: JavascriptScreenView(
                                          programs: manager,
                                          extensionId: item.package.id,
                                          library: library,
                                          audio: widget.audio!,
                                        ),
                                      ),
                                    ),
                                  ),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Abrir pantalla'),
                          ),
                        if (item.package.slots.contains('source') &&
                            (item.package.sourceSpec?.navigationLabel == null ||
                                manager.owner('source')?.package.id !=
                                    item.package.id))
                          TextButton.icon(
                            icon: const Icon(Icons.travel_explore),
                            label: Text(
                              item.package.sourceSpec?.platforms.contains(
                                        Platform.operatingSystem,
                                      ) !=
                                      true
                                  ? (item.package.sourceSpec == null
                                        ? 'Actualizar extensión de fuente'
                                        : 'Fuente no disponible en esta plataforma')
                                  : manager.owner('source')?.package.id ==
                                        item.package.id
                                  ? 'Abrir ${item.package.sourceSpec?.name ?? 'fuente'}'
                                  : 'Elegir como fuente',
                            ),
                            onPressed:
                                item.package.sourceSpec?.platforms.contains(
                                          Platform.operatingSystem,
                                        ) !=
                                        true ||
                                    !item.enabled ||
                                    !item.authorized ||
                                    widget.audio == null ||
                                    manager.busy
                                ? null
                                : () async {
                                    if (manager.owner('source')?.package.id !=
                                        item.package.id) {
                                      await manager.choose(
                                        'source',
                                        item.package.id,
                                      );
                                      return;
                                    }
                                    if (!mounted) return;
                                    await Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ExtensionSourceView(
                                          programs: manager,
                                          extensionId: item.package.id,
                                          audio: widget.audio!,
                                          library: library,
                                        ),
                                      ),
                                    );
                                  },
                          ),
                        TextButton.icon(
                          onPressed: manager.busy
                              ? null
                              : () async {
                                  final decision = await permissions(
                                    item.package,
                                    current: item.grants,
                                  );
                                  if (decision == null) return;
                                  await manager.setGrants(
                                    item.package.id,
                                    decision.$1,
                                  );
                                  await manager.setEnabled(
                                    item.package.id,
                                    decision.$2,
                                  );
                                },
                          icon: const Icon(Icons.verified_user_outlined),
                          label: const Text('Permisos'),
                        ),
                        TextButton.icon(
                          onPressed: manager.busy
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        '¿Desinstalar extensión?',
                                      ),
                                      content: const Text(
                                        'Se conserva la música, las listas y sus carátulas. Las reglas quedarán inactivas.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Desinstalar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await manager.remove(item.package.id);
                                  }
                                },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Desinstalar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
        const SizedBox(height: 24),
        Text(
          'Personalizaciones anteriores · API 1',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ListTile(
          title: const Text('Interfaz base'),
          leading: const Icon(Icons.music_note_outlined),
          trailing:
              library.activeExtension == null &&
                  manager?.owner('library') == null
              ? const Icon(Icons.check)
              : null,
          onTap: () async {
            await manager?.choose('library', null);
            await library.activateExtension(null);
          },
        ),
        for (final extension in library.extensions)
          Card(
            child: ListTile(
              title: Text(extension.name),
              subtitle: Text(
                '${extension.description}\nManifiesto declarativo sin código',
              ),
              leading: Icon(
                library.activeExtensionId == extension.id &&
                        manager?.owner('library') == null
                    ? Icons.check_circle
                    : Icons.extension_outlined,
              ),
              onTap: () async {
                await manager?.choose('library', null);
                await library.activateExtension(extension.id);
              },
              trailing: IconButton(
                tooltip: 'Desinstalar',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => library.removeExtension(extension.id),
              ),
            ),
          ),
      ],
    );
  }
}
