import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/album_detail_view.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/music_app.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';

import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show MemoryStore, FakePlayer;

void main() {
  for (final count in [500, 900]) {
    test(
      'discovery and unchanged metadata cache remain complete for $count tracks',
      () async {
        final directory = await Directory.systemTemp.createTemp('rp0318_scan_');
        addTearDown(() => directory.delete(recursive: true));
        final cached = <Track>[];
        for (var i = 0; i < count; i++) {
          final file = await File(
            '${directory.path}${Platform.pathSeparator}track$i.mp3',
          ).writeAsBytes([0]);
          final stat = await file.stat();
          cached.add(
            Track(
              id: file.path,
              title: 'Cached $i',
              folder: '.',
              size: stat.size,
              modifiedMs: stat.modified.millisecondsSinceEpoch,
              metadataLoaded: true,
              metadataVersion: 2,
            ),
          );
        }
        final events = <ScanProgress>[];
        final result = scanDirectory(
          directory.path,
          cached: cached,
          onProgress: events.add,
        );
        final discovery = events.where((e) => e.discovery).toList();
        expect(discovery.length, greaterThan(1));
        expect(
          discovery.first.total,
          0,
        ); // Published before enumeration is complete.
        expect(discovery.first.append, false);
        expect(discovery.skip(1).every((e) => e.append), true);
        expect(discovery.last.total, count);
        expect(
          discovery.expand((e) => e.batch).map((t) => t.id).toSet().length,
          count,
        );
        expect(result.tracks.length, count);
        expect(result.tracks.every((t) => t.title.startsWith('Cached')), true);
        expect(result.skipped, 0);
        expect(events.where((e) => !e.discovery).length, lessThan(12));
      },
    );
  }

  testWidgets(
    'phone Back closes local album detail and keeps the home screen',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false
        ..root = '/synthetic'
        ..tracks = [
          const Track(
            id: 'rpmusic-source:synthetic:song',
            title: 'Tema local',
            album: 'Álbum local',
            folder: '.',
          ),
        ];
      final audio = MusicHandler(player: FakePlayer());
      await tester.pumpWidget(MusicApp(library: library, audio: audio));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Álbumes').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Álbum local').first);
      await tester.tap(find.text('Álbum local').first);
      await tester.pumpAndSettle();
      expect(find.byType(AlbumDetailView), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AlbumDetailView), findsNothing);
      expect(find.byType(MusicHome), findsOneWidget);
      expect(find.text('Álbum local'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(audio.close);
      library.dispose();
    },
  );
}
