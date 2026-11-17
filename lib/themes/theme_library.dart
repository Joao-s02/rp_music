import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/local_store.dart';
import '../app/app_version.dart';
import '../updates/update_controller.dart' show ReleaseVersion;

const themeCatalogUrl = String.fromEnvironment(
  'RP_MUSIC_THEME_CATALOG',
  defaultValue: 'https://raw.githubusercontent.com/Joao-s02/rp-music-themes/main/catalog.json',
);
const _maxPackage = 4 * 1024 * 1024;
const _samplePath = 'assets/themes/minimalista.rptheme';

class MusicAppearance extends ThemeExtension<MusicAppearance> {
  MusicAppearance._(
    this.name,
    this.accent,
    this.images,
    this.colors, {
    this.revision = 1,
  });

  final int revision;

  final String name;
  final int accent;
  final Map<String, Uint8List> images;
  final Map<String, Color> colors;

  final _providers = <String, ImageProvider>{};
  final _streams = <ImageStream, ImageStreamListener>{};
  Future<void>? _preparing;
  final _imageWaiters = <Completer<void>>{};

  ImageProvider? image(String slot) {
    final bytes = images[slot];
    if (bytes == null) return null;
    return _providers.putIfAbsent(
      slot,
      () => ResizeImage(
        MemoryImage(bytes),
        width: slot == 'background' ? 1600 : 192,
        policy: ResizeImagePolicy.fit,
      ),
    );
  }

  Future<void> prepareImages() => _preparing ??= _prepareImages();

  Future<void> _prepareImages() async {
    await Future.wait(
      images.keys.map((slot) {
        final ready = Completer<void>();
        _imageWaiters.add(ready);
        final stream = image(slot)!.resolve(ImageConfiguration.empty);
        final listener = ImageStreamListener(
          (image, synchronous) {
            if (!ready.isCompleted) ready.complete();
            _imageWaiters.remove(ready);
            image.dispose();
          },
          onError: (Object error, StackTrace? stack) {
            if (!ready.isCompleted) ready.complete();
          },
        );
        _streams[stream] = listener;
        stream.addListener(listener);
        return ready.future;
      }),
    );
  }

  void releaseImages() {
    for (final entry in _streams.entries) {
      entry.key.removeListener(entry.value);
    }
    _streams.clear();
    for (final ready in _imageWaiters) {
      if (!ready.isCompleted) ready.complete();
    }
    _imageWaiters.clear();
    _preparing = null;
  }

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
    'filter',
    'sortAscending',
    'sortDescending',
    'lyrics',
    'queue',
    'volume',
    'details',
    'favorite',
    'favoriteSelected',
    'playlistAdd',
    'playlistRemove',
    'playlistCover',
    'add',
    'back',
    'search',
    'refresh',
    'folder',
    'artist',
    'album',
    'more',
    'delete',
  };

  factory MusicAppearance.parse(String text) {
    if (text.length > _maxPackage) throw const FormatException();
    final data = jsonDecode(text);
    if (data is! Map || data['version'] != 1) throw const FormatException();
    final minBuild = data['minAppBuild'];
    if (minBuild != null &&
        (minBuild is! int || minBuild > appBuild || minBuild < 1)) {
      throw const FormatException(
        'Este tema requiere una compilación más reciente de RP Music.',
      );
    }
    final minimum = data['minAppVersion'];
    if (minimum != null) {
      if (minimum is! String) throw const FormatException();
      if (ReleaseVersion.parse(minimum)
              .compareTo(ReleaseVersion.parse(appVersion)) >
          0) {
        throw FormatException(
          'Este tema requiere RP Music $minimum o posterior.',
        );
      }
    }
    final revision = data['revision'] ?? 1;
    if (revision is! int || revision < 1) throw const FormatException();
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
      revision: revision,
    );
  }

  @override
  MusicAppearance copyWith() => this;

  @override
  MusicAppearance lerp(MusicAppearance? other, double t) =>
      t < 0.5 ? this : other ?? this;
}

class ThemeIcon extends StatelessWidget {
  const ThemeIcon(this.slot, this.fallback, {super.key, this.size, this.color});
  final String slot;
  final IconData fallback;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final appearance = Theme.of(context).extension<MusicAppearance>();
    final alias = switch (slot) {
      'favorite' => 'favorites',
      'queue' || 'playlistAdd' => 'playlists',
      _ => slot,
    };
    final provider = appearance?.image(slot) ?? appearance?.image(alias);
    if (provider == null) return Icon(fallback, size: size, color: color);
    final extent = size ?? IconTheme.of(context).size ?? 24;
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: Image(
        image: provider,
        width: extent,
        height: extent,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => Icon(fallback, size: size, color: color),
      ),
    );
  }
}

class ThemeFavoriteIcon extends StatelessWidget {
  const ThemeFavoriteIcon({super.key, required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) => ThemeIcon(
    selected ? 'favoriteSelected' : 'favorite',
    selected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
  );
}

class ThemeBrand extends StatelessWidget {
  const ThemeBrand({super.key, this.size = 36});
  final double size;

  @override
  Widget build(BuildContext context) {
    final provider = Theme.of(context)
        .extension<MusicAppearance>()
        ?.image('decoration');
    final fallback = Image.asset(
      'assets/branding/rp-music-variant-a.png',
      width: size,
      height: size,
    );
    return provider == null
        ? fallback
        : Image(
            image: provider,
            width: size,
            height: size,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) => fallback,
          );
  }
}

class ThemeBackdrop extends StatelessWidget {
  const ThemeBackdrop({super.key, required this.child, this.opaque = false});
  final bool opaque;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final provider = Theme.of(context)
        .extension<MusicAppearance>()
        ?.image('background');
    if (provider == null) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (opaque) ColoredBox(color: Theme.of(context).colorScheme.surface),
        RepaintBoundary(
          child: Image(
            image: provider,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
        IgnorePointer(
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: .88),
          ),
        ),
        child,
      ],
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
  bool _closed = false;
  int _selection = 0;

  Future<void> initialize() async {
    try {
      await _restore();
    } finally {
      initialized = true;
      if (!_closed) notifyListeners();
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
    final savedSelection = data['active'];
    String? selection = savedSelection is String ? savedSelection : null;
    final preferred = <String, String>{};
    for (final entry in installed.entries) {
      final name = entry.value.name.toLowerCase();
      final previous = preferred[name];
      if (previous == null ||
          entry.value.revision > installed[previous]!.revision ||
          (entry.value.revision == installed[previous]!.revision &&
              entry.key == selection)) {
        preferred[name] = entry.key;
      }
    }
    final keep = preferred.values.toSet();
    if (keep.length != installed.length) {
      if (selection != null && installed.containsKey(selection)) {
        selection = preferred[installed[selection]!.name.toLowerCase()];
      }
      installed.removeWhere((id, _) => !keep.contains(id));
      _packages.removeWhere((id, _) => !keep.contains(id));
      // Normalized in memory even when storage is temporarily read-only.
      try {
        await _save(_packages, selection);
      } catch (_) {}
    }
    if (selection != null && installed.containsKey(selection)) {
      await _select(selection);
    }
  }

  Future<void> install(String text) async {
    final theme = MusicAppearance.parse(text);
    final id = sha256.convert(utf8.encode(text)).toString();
    if (installed.containsKey(id)) return apply(id);
    final previous = installed.entries
        .where(
          (entry) => entry.value.name.toLowerCase() == theme.name.toLowerCase(),
        )
        .firstOrNull;
    if (previous != null && previous.value.revision > theme.revision) {
      throw const FormatException(
        'Ya tienes una versión más reciente de este tema.',
      );
    }
    if (previous == null && installed.length >= maxInstalled) {
      throw const FormatException(
        'Ya tienes ocho temas. Quita uno para continuar.',
      );
    }
    final packages = {..._packages};
    if (previous != null) packages.remove(previous.key);
    packages[id] = text;
    await _save(packages, id);
    if (previous != null) {
      installed.remove(previous.key);
      _packages.remove(previous.key);
      previous.value.releaseImages();
    }
    installed[id] = theme;
    _packages[id] = text;
    await _select(id);
  }

  MusicAppearance? findInstalled(String name) => installed.values
      .where((theme) => theme.name.toLowerCase() == name.toLowerCase())
      .firstOrNull;

  Future<void> apply(String? id) async {
    await _save(_packages, id);
    await _select(id);
  }

  Future<void> remove(String id) async {
    final next = activeId == id ? null : activeId;
    await _save({..._packages}..remove(id), next);
    installed.remove(id);
    _packages.remove(id);
    await _select(next);
  }

  Future<void> _save(Map<String, String> packages, String? id) =>
      store.save({'packages': Map.of(packages), 'active': id});

  Future<void> _select(String? id) async {
    final generation = ++_selection;
    final next = installed[id];
    await next?.prepareImages();
    if (_closed || generation != _selection) {
      if (next != active) next?.releaseImages();
      return;
    }
    final previous = active;
    activeId = id;
    active = next;
    if (previous != next) previous?.releaseImages();
    notifyListeners();
  }

  @override
  void dispose() {
    _closed = true;
    for (final theme in installed.values) {
      theme.releaseImages();
    }
    super.dispose();
  }
}

class ThemeCatalogEntry {
  const ThemeCatalogEntry(
    this.name, {
    this.url,
    this.hash,
    this.preview,
    this.revision = 1,
  });
  final int revision;
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

Future<List<ThemeCatalogEntry>> _catalog() async {
  if (themeCatalogUrl.isEmpty) {
    return const [ThemeCatalogEntry('Minimalista')];
  }
  final endpoint = Uri.parse(themeCatalogUrl);
  final bytes = await _download(endpoint, 128 * 1024);
  return parseThemeCatalog(utf8.decode(bytes), endpoint);
}

List<ThemeCatalogEntry> parseThemeCatalog(String text, Uri endpoint) {
  final data = jsonDecode(text);
  if (data is! Map || data['version'] != 1 || data['themes'] is! List) {
    throw const FormatException();
  }
  final entries = data['themes'] as List;
  if (entries.length > 100) throw const FormatException();
  return entries.map((raw) {
    if (raw is! Map) throw const FormatException();
    var entry = Map<String, dynamic>.from(raw);
    final updates = entry['updates'] ?? const [];
    if (updates is! List || updates.length > 20) throw const FormatException();
    var selected = entry['revision'] ?? 1;
    if (selected is! int || selected < 1) throw const FormatException();
    for (final update in updates) {
      if (update is! Map || update['revision'] is! int) {
        throw const FormatException();
      }
      final revision = update['revision'] as int;
      final minimum = update['minAppVersion'];
      final build = update['minAppBuild'] ?? 1;
      if (revision < 1 ||
          (minimum != null && minimum is! String) ||
          build is! int ||
          build < 1) {
        throw const FormatException();
      }
      if (minimum != null &&
          ReleaseVersion.parse(minimum)
                  .compareTo(ReleaseVersion.parse(appVersion)) >
              0) {
        continue;
      }
      if (build > appBuild || revision <= selected) continue;
      entry = {
        ...entry,
        ...Map<String, dynamic>.from(update),
        'name': raw['name'],
      };
      selected = revision;
    }
    final url = endpoint.resolve(entry['url'] as String);
    final previewPath = entry['preview'] as String?;
    final preview = previewPath == null ? null : endpoint.resolve(previewPath);
    final hash = entry['sha256'] as String;
    final name = entry['name'] as String;
    final revision = entry['revision'] ?? 1;
    if (revision is! int || revision < 1) throw const FormatException();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) ||
        name.trim().isEmpty ||
        name.length > 60) {
      throw const FormatException();
    }
    return ThemeCatalogEntry(
      name,
      url: url,
      hash: hash,
      preview: preview?.scheme == 'https' ? preview : null,
      revision: revision,
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
  late Future<List<ThemeCatalogEntry>> catalog = _catalog();
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

  Future<void> download(ThemeCatalogEntry item) async {
    final url = item.url;
    if (url == null) {
      await widget.themes.install(await rootBundle.loadString(_samplePath));
      return;
    }
    final bytes = await _download(url, _maxPackage);
    if (sha256.convert(bytes).toString() != item.hash) {
      throw const FormatException('La descarga no coincide con el catálogo.');
    }
    final text = utf8.decode(bytes);
    final theme = MusicAppearance.parse(text);
    if (theme.name != item.name || theme.revision != item.revision) {
      throw const FormatException(
        'El tema no coincide con la revisión del catálogo.',
      );
    }
    await widget.themes.install(text);
  }

  Widget catalogRow(ThemeCatalogEntry entry) {
    final installed = widget.themes.findInstalled(entry.name);
    final update = installed != null && entry.revision > installed.revision;
    return ListTile(
      leading: entry.preview == null
          ? const Icon(Icons.palette_outlined)
          : Image.network(
              entry.preview.toString(),
              width: 56,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.palette_outlined),
            ),
      title: Text(entry.name),
      subtitle: installed == null
          ? null
          : Text(update ? 'Actualización disponible' : 'Instalado'),
      trailing: TextButton(
        onPressed: busy || (installed != null && !update)
            ? null
            : () => run(() => download(entry)),
        child: Text(
          update
              ? 'Actualizar tema'
              : installed != null
              ? 'Instalado'
              : 'Descargar',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.themes,
    builder: (context, _) => !widget.themes.initialized
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (busy) const LinearProgressIndicator(),
              Card(
                child: ExpansionTile(
                  key: const PageStorageKey('downloaded-themes'),
                  leading: const Icon(Icons.download_done),
                  title: const Text('Descargados'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.file_open_outlined),
                      title: const Text('Importar tema'),
                      onTap: busy ? null : () => run(import),
                    ),
                    ListTile(
                      title: const Text('RP Music'),
                      subtitle: const Text('Tema predeterminado'),
                      trailing: widget.themes.activeId == null
                          ? const Icon(Icons.check)
                          : null,
                      onTap: busy
                          ? null
                          : () => run(() => widget.themes.apply(null)),
                    ),
                    for (final entry in widget.themes.installed.entries)
                      ListTile(
                        leading: widget.themes.activeId == entry.key
                            ? const Icon(Icons.check)
                            : const Icon(Icons.palette_outlined),
                        title: Text(entry.value.name),
                        onTap: busy
                            ? null
                            : () => run(() => widget.themes.apply(entry.key)),
                        trailing: IconButton(
                          tooltip: 'Quitar tema',
                          onPressed: busy
                              ? null
                              : () =>
                                    run(() => widget.themes.remove(entry.key)),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ExpansionTile(
                  key: const PageStorageKey('theme-catalog'),
                  leading: const Icon(Icons.storefront_outlined),
                  title: const Text('Catálogo'),
                  children: [
                    ListTile(
                      title: const Text('Temas disponibles'),
                      trailing: IconButton(
                        tooltip: 'Actualizar catálogo',
                        onPressed: busy
                            ? null
                            : () => setState(() => catalog = _catalog()),
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                    FutureBuilder(
                      future: catalog,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return ListTile(
                            title: const Text('No se pudo abrir el catálogo'),
                            trailing: TextButton(
                              onPressed: () =>
                                  setState(() => catalog = _catalog()),
                              child: const Text('Reintentar'),
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const LinearProgressIndicator();
                        }
                        return Column(
                          children: [
                            for (final entry in snapshot.data!)
                              catalogRow(entry),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
  );
}
