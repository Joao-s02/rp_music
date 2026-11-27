import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/music_app.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer, MemoryStore;

final tracks = [
  for (final title in ['A', 'B', 'C', 'D', 'E'])
    Track(id: '/$title.mp3', title: title, folder: '.'),
];

List<String> pending(MusicHandler audio) =>
    audio.tracks.skip(audio.index + 1).map((track) => track.title).toList();

void main() {
  testWidgets('reinicia una cola terminada conservando sus ediciones', (
    tester,
  ) async {
    final player = FakePlayer(liveStates: true);
    final audio = MusicHandler(player: player);
    await audio.select(tracks.take(4).toList(), 0);
    audio.movePending(audio.queueEntryAt(3), 1);
    audio.removePending(audio.queueEntryAt(2));
    final entries = List.generate(audio.tracks.length, audio.queueEntryAt);
    await audio.skipToNext();
    await audio.skipToNext();
    player.complete();
    await tester.pump();
    expect(audio.queueEnded, isTrue);
    expect(player.playing, isFalse);

    await audio.play();
    expect(audio.queueEnded, isFalse);
    expect(audio.index, 0);
    expect(audio.tracks.map((t) => t.title), ['A', 'D', 'C']);
    expect(List.generate(audio.tracks.length, audio.queueEntryAt), entries);
    await audio.close();
  });

  testWidgets('repetir todo en aleatorio evita repetir la última canción', (
    tester,
  ) async {
    final player = FakePlayer(liveStates: true);
    final audio = MusicHandler(player: player)..shuffle = true;
    await audio.select(tracks.take(3).toList(), 0);
    await audio.setRepeatMode(AudioServiceRepeatMode.all);
    await audio.skipToQueueItem(2);
    final last = audio.tracks[audio.index].id;
    player.complete();
    await tester.pump();
    expect(audio.queueEnded, isFalse);
    expect(audio.index, 0);
    expect(audio.tracks.first.id, isNot(last));
    expect(audio.tracks.map((t) => t.title), unorderedEquals(['A', 'B', 'C']));
    await audio.close();
  });

  testWidgets(
    'el fundido usa el siguiente efectivo y lo promueve sin recargar',
    (tester) async {
      final outgoing = FakePlayer(liveStates: true);
      final incoming = FakePlayer(liveStates: true);
      final audio = MusicHandler(
        player: outgoing,
        crossfadePlayerFactory: () => incoming,
      );
      await audio.select(tracks.take(3).toList(), 0);
      audio.enqueue([tracks[3]], next: true);
      await audio.setCrossfade(enabled: true);
      outgoing.currentPosition = const Duration(seconds: 23);
      await tester.pump(const Duration(milliseconds: 50));
      expect(incoming.loaded.single.path, '/D.mp3');
      outgoing.currentPosition = const Duration(seconds: 25);
      await tester.pump(const Duration(milliseconds: 50));
      expect(incoming.playing, isTrue);
      outgoing.currentPosition = const Duration(milliseconds: 27500);
      incoming.currentPosition = const Duration(milliseconds: 2500);
      await tester.pump(const Duration(milliseconds: 50));
      expect(outgoing.volume, closeTo(.5, .001));
      expect(incoming.volume, closeTo(.5, .001));

      outgoing.complete();
      await tester.pump();
      expect(audio.player, same(incoming));
      expect(audio.mediaItem.value?.title, 'D');
      expect(incoming.loaded, hasLength(1));
      expect(incoming.volume, 1);
      expect(incoming.position, const Duration(milliseconds: 2500));
      await audio.skipToNext();
      expect(audio.mediaItem.value?.title, 'B');
      expect(incoming.position, Duration.zero);
      await audio.close();
    },
  );

  testWidgets('pulsación larga y clic derecho comparten acciones de cola', (
    tester,
  ) async {
    final audio = MusicHandler(player: FakePlayer());
    final library = LibraryController(MemoryStore(), MusicFiles())
      ..loading = false
      ..root = 'música'
      ..tracks = tracks;
    await audio.select(tracks, 0, autoplay: false);
    await tester.pumpWidget(MusicApp(audio: audio, library: library));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('D').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reproducir a continuación'));
    await tester.pumpAndSettle();
    expect(pending(audio).first, 'D');
    expect(audio.mediaItem.value?.title, 'A');

    final click = await tester.startGesture(
      tester.getCenter(find.text('C').hitTestable().first),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await click.up();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Añadir al final de la cola'));
    await tester.pumpAndSettle();
    expect(pending(audio).last, 'C');
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(audio.close);
    library.dispose();
  });

  test(
    'la cola visible dirige el siguiente y protege inserciones prioritarias',
    () async {
      final player = FakePlayer();
      final audio = MusicHandler(player: player);
      addTearDown(audio.close);
      await audio.select(tracks.sublist(0, 3), 0);
      player.currentPosition = const Duration(seconds: 12);

      audio.enqueue([tracks[3]], next: true);
      audio.enqueue([tracks[4]], next: true);
      audio.shuffle = true;
      final visible = pending(audio);
      expect(visible.take(2), ['E', 'D']);
      expect(player.position, const Duration(seconds: 12));
      for (final title in visible) {
        await audio.skipToNext();
        expect(audio.mediaItem.value?.title, title);
      }
      await audio.skipToNext();
      expect(audio.mediaItem.value?.title, visible.last);
    },
  );

  test(
    'al apagar aleatorio se restaura el orden de origen con ediciones',
    () async {
      final audio = MusicHandler(player: FakePlayer());
      addTearDown(audio.close);
      await audio.select(tracks, 0);
      audio.shuffle = true;
      final c = audio.tracks.indexOf(tracks[2]);
      audio.removePending(audio.queueEntryAt(c));
      final d = audio.tracks.indexOf(tracks[3]);
      audio.movePendingNext(audio.queueEntryAt(d));
      audio.shuffle = false;
      expect(pending(audio), ['D', 'B', 'E']);
    },
  );

  test(
    'quita una copia, deshace y restaura la segunda aparición pausada',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rp_editable_queue',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = LocalStore(directory, baseName: 'session');
      final audio = MusicHandler(player: FakePlayer(), sessionStore: store);
      await audio.select(tracks.sublist(0, 2), 0);
      audio.enqueue([tracks[0], tracks[4]], next: true);
      expect(pending(audio), ['A', 'E', 'B']);
      final repeated = audio.queueEntryAt(1);
      final undo = audio.removePending(repeated);
      expect(pending(audio), ['E', 'B']);
      undo!();
      await audio.skipToNext();
      expect(audio.queueEntryAt(audio.index), repeated);
      await audio.close();

      final player = FakePlayer();
      final restored = MusicHandler(player: player, sessionStore: store);
      addTearDown(restored.close);
      await restored.restoreSession(tracks);
      expect(restored.queueEntryAt(restored.index), repeated);
      expect(pending(restored), ['E', 'B']);
      expect(player.played, isEmpty);
      restored.clearPending();
      expect(pending(restored), isEmpty);
      expect(restored.mediaItem.value?.title, 'A');
    },
  );
}
