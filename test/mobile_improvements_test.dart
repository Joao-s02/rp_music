import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/music_app.dart';
import 'package:rp_music/app/scrolling_title.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer, MemoryStore;

class DeleteFiles extends MusicFiles {
  bool fail = false;
  final deleted = <String>[];
  @override
  Future<void> delete(String id) async {
    if (fail) throw StateError('denied');
    deleted.add(id);
  }
}

const a = Track(id: '/a.mp3', title: 'A', folder: '.');
const b = Track(id: '/b.mp3', title: 'B', folder: '.');
void main() {
  test('borrado fallido conserva catálogo y referencias; éxito limpia solo la pista', () async {
    final files = DeleteFiles()..fail = true;
    final library = LibraryController(MemoryStore(), files)
      ..tracks = [a, b]
      ..favorites = {a.id, b.id}
      ..playlists = {
        'Lista': [a.id, b.id],
      };
    expect(await library.deleteTrack(a), false);
    expect(library.tracks.length, 2);
    expect(library.favorites.contains(a.id), true);
    files.fail = false;
    expect(await library.deleteTrack(a), true);
    expect(library.tracks.single.id, b.id);
    expect(library.favorites, {b.id});
    expect(library.playlists['Lista'], [b.id]);
    expect(files.deleted, [a.id]);
    library.dispose();
  });
  test(
    'carátula tardía no reemplaza la canción actual y conserva duración',
    () async {
      final first = Completer<Uri?>();
      final second = Completer<Uri?>();
      final audio = MusicHandler(
        player: FakePlayer(),
        artworkLoader: (id) => id == a.id ? first.future : second.future,
      );
      await audio.select([a, b], 0, autoplay: false);
      await audio.select([a, b], 1, autoplay: false);
      second.complete(Uri.file('/b.png'));
      await Future<void>.delayed(Duration.zero);
      first.complete(Uri.file('/a.png'));
      await Future<void>.delayed(Duration.zero);
      expect(audio.mediaItem.value!.artUri, Uri.file('/b.png'));
      expect(audio.mediaItem.value!.duration, const Duration(seconds: 30));
      await audio.removeTrack(b.id);
      expect(audio.mediaItem.value, isNull);
      expect(audio.queue.value.single.id, a.id);
      await audio.close();
    },
  );
  testWidgets('menú confirma borrado y cancelar conserva el archivo', (
    tester,
  ) async {
    final files = DeleteFiles();
    final library = LibraryController(MemoryStore(), files)
      ..loading = false
      ..root = '/Music'
      ..tracks = [a, b];
    final audio = MusicHandler(player: FakePlayer());
    await tester.pumpWidget(MusicApp(library: library, audio: audio));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Opciones de canción').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar del dispositivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(files.deleted, isEmpty);
    expect(library.tracks.length, 2);
    await tester.tap(find.byTooltip('Opciones de canción').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar del dispositivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar archivo'));
    await tester.pumpAndSettle();
    expect(files.deleted, [a.id]);
    expect(library.tracks.single.id, b.id);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(audio.close);
    library.dispose();
  });
  testWidgets(
    'título largo se desplaza en una línea y respeta movimiento reducido',
    (tester) async {
      const title =
          'Una canción con un nombre muy largo que supera el ancho disponible';
      Widget view(bool reduced) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: const Scaffold(
            body: SizedBox(width: 180, child: ScrollingTitle(text: title)),
          ),
        ),
      );
      await tester.pumpWidget(view(false));
      await tester.pump(const Duration(seconds: 2));
      expect(tester.widget<Text>(find.text(title)).maxLines, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(view(true));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text(title)).overflow,
        TextOverflow.ellipsis,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
