import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'library_controller.dart';

Future<void> choosePlaylistCover(
  BuildContext context,
  LibraryController library,
  String name,
) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_outlined),
            title: const Text('Elegir imagen propia'),
            onTap: () => Navigator.pop(context, 'image'),
          ),
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Usar mosaico automático'),
            onTap: () => Navigator.pop(context, 'mosaic'),
          ),
        ],
      ),
    ),
  );
  if (choice == 'mosaic') {
    await library.setPlaylistCover(name, null);
    return;
  }
  if (choice != 'image') return;
  try {
    final picked = await FilePicker.pickFile(type: FileType.image);
    if (picked?.path == null) return;
    final input = File(picked!.path!);
    if (await input.length() > 8 * 1024 * 1024) {
      throw const FormatException('Elige una imagen de hasta 8 MB.');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(
      await input.readAsBytes(),
    );
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      if (descriptor.width > 12000 || descriptor.height > 12000) {
        throw const FormatException('La imagen tiene demasiados píxeles.');
      }
      codec = await descriptor.instantiateCodec(
        targetWidth: 512,
        targetHeight: 512,
      );
      image = (await codec.getNextFrame()).image;
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = Directory(
        '${library.store.directory.path}/playlist_covers',
      );
      await directory.create(recursive: true);
      final file = File(
        '${directory.path}/${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(png!.buffer.asUint8List(), flush: true);
      await library.setPlaylistCover(name, file.path);
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer.dispose();
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is FormatException
                ? error.message
                : 'No se pudo guardar la imagen.',
          ),
        ),
      );
    }
  }
}

class PlaylistCover extends StatefulWidget {
  const PlaylistCover({
    super.key,
    required this.library,
    required this.name,
    this.size = 48,
  });
  final LibraryController library;
  final String name;
  final double size;
  @override
  State<PlaylistCover> createState() => _PlaylistCoverState();
}

class _PlaylistCoverState extends State<PlaylistCover> {
  final images = <String, Future<Uint8List?>>{};
  Widget placeholder() => ColoredBox(
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: Center(
      child: Icon(
        Icons.queue_music,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final path = widget.library.playlistMeta[widget.name]?['cover'];
    final tracks = widget.library.playlistTracks(widget.name).take(4).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: path is String
            ? Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder(),
              )
            : tracks.isEmpty
            ? placeholder()
            : Column(
                children: [
                  for (var row = 0; row < 2; row++)
                    Expanded(
                      child: Row(
                        children: [
                          for (var column = 0; column < 2; column++)
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final track =
                                      tracks[(row * 2 + column) %
                                          tracks.length];
                                  final image = images.putIfAbsent(
                                    track.id,
                                    () =>
                                        widget.library.files.artwork(track.id),
                                  );
                                  return FutureBuilder<Uint8List?>(
                                    future: image,
                                    builder: (context, snapshot) =>
                                        snapshot.data == null
                                        ? placeholder()
                                        : Image.memory(
                                            snapshot.data!,
                                            cacheWidth: widget.size > 100
                                                ? 512
                                                : 128,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                placeholder(),
                                          ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
