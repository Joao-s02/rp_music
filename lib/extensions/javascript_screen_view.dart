import 'package:flutter/material.dart';

import '../app/library_controller.dart';
import '../playback/music_handler.dart';
import 'program_controller.dart';
import 'program_snapshot.dart';

class JavascriptScreenView extends StatefulWidget {
  const JavascriptScreenView({
    super.key,
    required this.programs,
    required this.extensionId,
    required this.library,
    required this.audio,
  });
  final ProgramController programs;
  final String extensionId;
  final LibraryController library;
  final MusicHandler audio;
  @override
  State<JavascriptScreenView> createState() => _JavascriptScreenViewState();
}

class _JavascriptScreenViewState extends State<JavascriptScreenView> {
  Map<String, dynamic>? view;
  final fields = <String, String>{};
  bool busy = false;
  String? error;
  bool get enabled =>
      widget.programs.allowed(widget.extensionId, 'navigation.add');
  @override
  void initState() {
    super.initState();
    widget.programs.addListener(changed);
    run();
  }

  @override
  void didUpdateWidget(covariant JavascriptScreenView old) {
    super.didUpdateWidget(old);
    if (old.extensionId != widget.extensionId) {
      view = null;
      fields.clear();
      run();
    }
  }

  void changed() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.programs.removeListener(changed);
    super.dispose();
  }

  Future<void> run([String? action]) async {
    if (busy || !enabled) return;
    final installed = widget.programs.installed[widget.extensionId];
    final id = widget.extensionId;
    final snapshot = ProgramSnapshot(
      widget.library.tracks.take(500).toList(),
      widget.library.favorites,
    );
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.programs.invoke(id, 'screen', {
        'action': action ?? 'open',
        'fields': Map<String, String>.of(fields),
        if (widget.programs.allowed(id, 'library.read'))
          'tracks': snapshot.rows,
      });
      if (!mounted ||
          id != widget.extensionId ||
          widget.programs.installed[id] != installed ||
          !enabled) {
        return;
      }
      if (result == null) {
        throw const FormatException(
          'No se pudo abrir la pantalla. Revisa el estado de la extensión.',
        );
      }
      final play = result['play'];
      if (play != null) {
        if (action == null ||
            play is! String ||
            !widget.programs.allowed(id, 'playback.control') ||
            !widget.programs.allowed(id, 'library.read') ||
            !snapshot.byId.containsKey(play)) {
          await widget.programs.reject(
            id,
            'Acción de reproducción no autorizada.',
          );
          throw const FormatException('Acción de reproducción no autorizada.');
        }
        final track = snapshot.byId[play]!;
        if (!widget.library.tracks.any((t) => t.id == track.id)) {
          throw const FormatException(
            'La canción ya no está en la biblioteca.',
          );
        }
        await widget.audio.select([track], 0);
      }
      if (mounted && enabled) {
        setState(() => view = Map<String, dynamic>.from(result['view'] as Map));
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is FormatException
              ? e.message.toString()
              : 'No se pudo ejecutar la pantalla.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  Widget node(Map raw, String path) {
    String text(String key) => raw[key] is String ? raw[key] as String : '';
    final children = raw['children'] as List? ?? [];
    List<Widget> buildChildren() => [
      for (var i = 0; i < children.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: node(Map.from(children[i] as Map), '$path.$i'),
        ),
    ];
    switch (raw['type']) {
      case 'column':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: buildChildren(),
        );
      case 'row':
        return Wrap(spacing: 8, runSpacing: 8, children: buildChildren());
      case 'card':
        return Card(
          color: raw['color'] == null
              ? null
              : Color(
                  0xff000000 | int.parse(text('color').substring(1), radix: 16),
                ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buildChildren(),
            ),
          ),
        );
      case 'text':
        return Text(
          text('text'),
          style: raw['style'] == 'title'
              ? Theme.of(context).textTheme.headlineSmall
              : null,
        );
      case 'divider':
        return const Divider();
      case 'input':
        final id = text('id');
        return TextFormField(
          key: ValueKey('$path:$id'),
          initialValue: fields[id] ?? text('value'),
          maxLength: 500,
          decoration: InputDecoration(labelText: text('label')),
          onChanged: (value) => fields[id] = value,
          enabled: enabled && !busy,
        );
      case 'button':
        return FilledButton(
          onPressed: !enabled || busy ? null : () => run(text('action')),
          child: Text(text('label')),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const Center(child: Text('Extensión desactivada o sin permisos.'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (busy) const LinearProgressIndicator(),
          if (error != null) ...[
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            TextButton(
              onPressed: busy ? null : () => run(),
              child: const Text('Reintentar'),
            ),
          ],
          if (view != null) node(view!, 'root'),
        ],
      ),
    );
  }
}
