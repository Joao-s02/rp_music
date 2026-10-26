import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rp_music/sources/youtube_music_api.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/domain/track.dart';

import 'playback_and_ui_test.dart' show FakePlayer;
import 'program_system_test.dart' show Registry;

void main() {
  test('el paquete exige permisos y ejecuta su contrato de búsqueda', () async {
    final raw = jsonDecode(
      await File('examples/extensions/programables/youtube-music.rpmx')
          .readAsString(),
    ) as Map;
    final package = ProgramPackage.parse(Map<String, dynamic>.from(raw));
    final programs = ProgramController(Registry());
    try {
      await programs.install(package, {});
      expect(
        await programs.invoke(package.id, 'source', {'query': 'demo'}),
        isNull,
      );
      await programs.setGrants(package.id, package.permissions);
      await programs.setEnabled(package.id, true);
      final result = await programs.invoke(package.id, 'source', {
        'query': '  demo  ',
      });
      expect(result, {'provider': 'youtube-music', 'query': 'demo'});
      expect(
        () => ProgramPackage.parse({
          ...raw,
          'permissions': ['playback.control'],
        }),
        throwsFormatException,
      );
    } finally {
      programs.dispose();
    }
  });
  test('analiza solo canciones con id válido, sin duplicados, hasta 30', () {
    Map row(String id) => {
      'musicResponsiveListItemRenderer': {
        'playlistItemData': {'videoId': id},
        'flexColumns': [
          {
            'musicResponsiveListItemFlexColumnRenderer': {
              'text': {
                'runs': [
                  {'text': 'Demo'},
                ],
              },
            },
          },
          {
            'musicResponsiveListItemFlexColumnRenderer': {
              'text': {
                'runs': [
                  {'text': 'Artista'},
                ],
              },
            },
          },
        ],
      },
    };
    final rows = [
      row('abcdefghijk'),
      row('abcdefghijk'),
      row('../file'),
      for (var i = 0; i < 40; i++) row(i.toString().padLeft(11, '0')),
    ];
    final found = YoutubeMusicApi.parseSearch({
      'contents': rows,
    }, 'rp.youtube-music');
    expect(found.length, 30);
    expect(found.first.title, 'Demo');
    expect(YoutubeMusicApi.identity(found.first.id), [
      'rpmusic-youtube',
      'rp.youtube-music',
      'abcdefghijk',
    ]);
    expect(YoutubeMusicApi.identity('https://evil.test/audio'), isNull);
  });
  test(
    'audio usa identidad estable, descarta carga tardía y respeta revocación',
    () async {
      final player = FakePlayer();
      final audio = MusicHandler(player: player);
      final errors = <String>[];
      final subscription = audio.errors.stream.listen(errors.add);
      const remote = Track(
        id: 'rpmusic-youtube:rp.youtube-music:abcdefghijk',
        title: 'Remota',
        folder: 'YouTube Music',
      );
      const local = Track(
        id: '/music/local.mp3',
        title: 'Local',
        folder: 'music',
      );
      var permitted = true;
      final gate = Completer<({AudioSource source, Uri? artwork})>();
      audio.onlineAllowed = (_) => permitted;
      audio.onlineSourceLoader = (_) => gate.future;
      try {
        final old = audio.select([remote], 0);
        await Future<void>.delayed(Duration.zero);
        final next = audio.select([local], 0);
        gate.complete((
          source: AudioSource.uri(
            Uri.parse('https://cdn.googlevideo.com/audio'),
          ),
          artwork: null,
        ));
        await Future.wait([old, next]);
        expect(player.loaded, [Uri.file(local.id)]);
        audio.onlineSourceLoader = (_) async => (
          source: AudioSource.uri(
            Uri.parse('https://cdn.googlevideo.com/audio'),
          ),
          artwork: null,
        );
        await audio.select([remote], 0);
        expect(audio.mediaItem.value?.id, remote.id);
        expect(player.loaded.last.scheme, 'https');
        await audio.pause();
        permitted = false;
        final played = player.played.length;
        await audio.play();
        expect(player.played.length, played);
        expect(errors, contains('La fuente está desactivada o sin permiso.'));
      } finally {
        await subscription.cancel();
        await audio.close();
      }
    },
  );
}
