import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/local_store.dart';

const themeCatalogUrl = String.fromEnvironment(
  'RP_MUSIC_THEME_CATALOG',
  defaultValue: 'https://raw.githubusercontent.com/Joao-s02/rp-music-themes/main/catalog.json',
);
const _maxPackage = 4 * 1024 * 1024;
const _samplePath = 'assets/themes/minimalista.rptheme';

class MusicAppearance extends ThemeExtension<MusicAppearance> {
  MusicAppearance._(this.name, this.accent, this.images, this.colors);

  final String name;
  final int accent;
  final Map<String, Uint8List> images;
  final Map<String, Color> colors;

  static const slots = {
    'play',
    'pause',
    'previous',
    'next',
    'shuffle',
    'repeat',
    'library',
    'favorites',
    'playlists',
    'themes',
    'settings',
    'background',
    'decoration',
  };

  factory MusicAppearance.parse(String text) {
    if (text.length > _maxPackage) throw const FormatException();
    final data = jsonDecode(text);
    if (data is! Map || data['version'] != 1) throw const FormatException();
    final name = data['name'];
    final accent = data['accent'];
    final resources = data['images'] ?? const {};
    if (name is! String ||
        name.trim().isEmpty ||
        name.length > 60 ||
        accent is! String ||
        !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(accent) ||
        resources is! Map ||
        !resources.keys.every(slots.contains)) {
      throw const FormatException();
    }
    final colors = <String, Color>{};
    final palette = data['colors'] ?? const {};
    const colorSlots = {
      'primary',
      'onPrimary',
      'secondary',
      'onSecondary',
      'surface',
      'onSurface',
      'onSurfaceVariant',
      'outline',
      'surfaceContainer',
      'surfaceContainerLow',
      'surfaceContainerLowest',
    };
    if (palette is! Map || !palette.keys.every(colorSlots.contains)) {
      throw const FormatException();
    }
    for (final entry in palette.entries) {
      final value = entry.value;
      if (value is! String || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) {
        throw const FormatException();
      }
      colors[entry.key as String] = Color(
        0xff000000 | int.parse(value.substring(1), radix: 16),
      );
    }
    final images = <String, Uint8List>{};
    for (final entry in resources.entries) {
      final encoded = entry.value;
      if (encoded is! String) throw const FormatException();
      final bytes = base64Decode(encoded);
      const signature = [137, 80, 78, 71, 13, 10, 26, 10];
      if (bytes.length < 33 ||
          !Iterable<int>.generate(8).every((i) => bytes[i] == signature[i]) ||
          ascii.decode(bytes.sublist(12, 16), allowInvalid: true) != 'IHDR') {
        throw const FormatException();
      }
      final header = ByteData.sublistView(bytes);
      final limit = entry.key == 'background' ? 2048 : 512;
      final width = header.getUint32(16);
      final height = header.getUint32(20);
      if (width == 0 || height == 0 || width > limit || height > limit) {
        throw const FormatException();
      }
      images[entry.key as String] = bytes;
    }
    return MusicAppearance._(
      name.trim(),
      0xff000000 | int.parse(accent.substring(1), radix: 16),
      Map.unmodifiable(images),
      Map.unmodifiable(colors),
    );
  }

  @override
  MusicAppearance copyWith() => this;

  @override
  MusicAppearance lerp(MusicAppearance? other, double t) =>
      t < 0.5 ? this : other ?? this;
}

class ThemeIcon extends StatelessWidget {
  const ThemeIcon(this.slot, this.fallback, {super.key, this.size});
  final String slot;
  final IconData fallback;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final data = Theme.of(context).extension<MusicAppearance>()?.images[slot];
    if (data == null) return Icon(fallback, size: size);
    final extent = size ?? IconTheme.of(context).size ?? 24;
    return Image.memory(
      data,
      width: extent,
      height: extent,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => Icon(fallback, size: size),
    );
  }
}

class ThemeLibrary extends ChangeNotifier {
  ThemeLibrary(this.store);
  final LocalStore store;
  MusicAppearance? active;
  String? activeId;
  final installed = <String, MusicAppearance>{};
  final _packages = <String, String>{};
  static const maxInstalled = 8;

  bool initialized = false;

  Future<void> initialize() async {
    try {
      await _restore();
    } finally {
      initialized = true;
      notifyListeners();
    }
  }

  Future<void> _restore() async {
    final data = await store.load();
    final packages = data['packages'];
    if (packages is! Map) return;
    for (final entry in packages.entries.take(maxInstalled)) {
      final text = entry.value;
      final id = entry.key;
      if (text is! String || id is! String) continue;
      try {
        installed[id] = MusicAppearance.parse(text);
        _packages[id] = text;
      } on FormatException {
        continue;
      }
    }
    final selection = data['active'];
    if (selection is String && installed.containsKey(selection)) {
      activeId = selection;
      active = installed[selection];
    }
  }

  Future<void> install(String text) async {
    final theme = MusicAppearance.parse(text);
    final id = sha256.convert(utf8.encode(text)).toString();
    if (installed.containsKey(id)) return apply(id);
    if (installed.length >= maxInstalled) {
      throw const FormatException(
        'Ya tienes ocho temas. Quita uno para continuar.',
      );
    }
    await _save({..._packages, id: text}, id);
    installed[id] = theme;
    _packages[id] = text;
    _select(id);
  }

  Future<void> apply(String? id) async {
    await _save(_packages, id);
    _select(id);
  }

  Future<void> remove(String id) async {
    final next = activeId == id ? null : activeId;
    await _save({..._packages}..remove(id), next);
    installed.remove(id);
    _packages.remove(id);
    _select(next);
  }

  Future<void> _save(Map<String, String> packages, String? id) =>
      store.save({'packages': Map.of(packages), 'active': id});

  void _select(String? id) {
    activeId = id;
    active = installed[id];
    notifyListeners();
  }
}

class _CatalogTheme {
  const _CatalogTheme(this.name, {this.url, this.hash, this.preview});
  final String name;
  final Uri? url;
  final String? hash;
  final Uri? preview;
}

Future<Uint8List> _download(Uri url, int limit) async {
  if (url.scheme != 'https' || url.host.isEmpty || url.userInfo.isNotEmpty) {
    throw const FormatException();
  }
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
  try {
    return await (() async {
      final request = await client.getUrl(url);
      request.followRedirects = false;
      final response = await request.close();
      if (response.statusCode != 200 || response.contentLength > limit) {
        throw const FormatException();
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in response) {
        if (bytes.length + chunk.length > limit) throw const FormatException();
        bytes.add(chunk);
      }
      return bytes.takeBytes();
    })().timeout(const Duration(seconds: 15));
  } finally {
    client.close(force: true);
  }
}

Future<List<_CatalogTheme>> _catalog() async {
  if (themeCatalogUrl.isEmpty) {
    return const [_CatalogTheme('Minimalista')];
  }
  final endpoint = Uri.parse(themeCatalogUrl);
  final bytes = await _download(endpoint, 128 * 1024);
  final data = jsonDecode(utf8.decode(bytes));
  if (data is! Map || data['version'] != 1 || data['themes'] is! List) {
    throw const FormatException();
  }
  final entries = data['themes'] as List;
  if (entries.length > 100) throw const FormatException();
  return entries.map((entry) {
    final url = endpoint.resolve(entry['url'] as String);
    final previewPath = entry['preview'] as String?;
    final preview = previewPath == null ? null : endpoint.resolve(previewPath);
    final hash = entry['sha256'] as String;
    final name = entry['name'] as String;
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) ||
        name.trim().isEmpty ||
        name.length > 60) {
      throw const FormatException();
    }
    return _CatalogTheme(
      name,
      url: url,
      hash: hash,
      preview: preview?.scheme == 'https' ? preview : null,
    );
  }).toList();
}

class ThemeLibraryView extends StatefulWidget {
  const ThemeLibraryView({super.key, required this.themes});
  final ThemeLibrary themes;

  @override
  State<ThemeLibraryView> createState() => _ThemeLibraryViewState();
}

class _ThemeLibraryViewState extends State<ThemeLibraryView> {
  late Future<List<_CatalogTheme>> catalog = _catalog();
  bool busy = false;

  Future<void> run(Future<void> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        final message = error is FormatException && error.message.isNotEmpty
            ? error.message
            : 'No se pudo leer, descargar o guardar el tema.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> import() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['rptheme'],
    );
    if (file == null) return;
    final length = await file.length();
    if (length == null || length > _maxPackage) throw const FormatException();
    final bytes = await file.readAsBytes();
    if (bytes.length > _maxPackage) throw const FormatException();
    await widget.themes.install(utf8.decode(bytes));
  }

  Future<void> download(_CatalogTheme item) async {
    final url = item.url;
    if (url == null) {
      await widget.themes.install(await rootBundle.loadString(_samplePath));
      return;
    }
    final bytes = await _download(url, _maxPackage);
    if (sha256.convert(bytes).toString() != item.hash) {
      throw const FormatException('La descarga no coincide con el catálogo.');
    }
    await widget.themes.install(utf8.decode(bytes));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.themes,
    builder: (context, _) => !widget.themes.initialized
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.file_open_outlined),
                title: const Text('Importar tema'),
                onTap: busy ? null : () => run(import),
              ),
              if (busy) const LinearProgressIndicator(),
              ListTile(
                title: const Text('RP Music'),
                subtitle: const Text('Tema predeterminado'),
                trailing: widget.themes.activeId == null
                    ? const Icon(Icons.check)
                    : null,
                onTap: busy ? null : () => run(() => widget.themes.apply(null)),
              ),
              for (final entry in widget.themes.installed.entries)
                ListTile(
                  leading: widget.themes.activeId == entry.key
                      ? const Icon(Icons.check)
                      : null,
                  title: Text(entry.value.name),
                  onTap: busy
                      ? null
                      : () => run(() => widget.themes.apply(entry.key)),
                  trailing: IconButton(
                    tooltip: 'Quitar tema',
                    onPressed: busy
                        ? null
                        : () => run(() => widget.themes.remove(entry.key)),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              const Divider(),
              Text('Catálogo', style: Theme.of(context).textTheme.titleLarge),
              FutureBuilder(
                future: catalog,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return ListTile(
                      title: const Text('No se pudo abrir el catálogo'),
                      trailing: TextButton(
                        onPressed: () => setState(() => catalog = _catalog()),
                        child: const Text('Reintentar'),
                      ),
                    );
                  }
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  return Column(
                    children: [
                      for (final entry in snapshot.data!)
                        ListTile(
                          leading: entry.preview == null
                              ? const Icon(Icons.palette_outlined)
                              : Image.network(
                                  entry.preview.toString(),
                                  width: 64,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const Icon(Icons.palette_outlined),
                                ),
                          title: Text(entry.name),
                          trailing: TextButton(
                            onPressed: busy
                                ? null
                                : () => run(() => download(entry)),
                            child: Text(
                              entry.url == null ? 'Instalar' : 'Descargar',
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
  );
}
