import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer;

class NativeErrorPlayer extends FakePlayer {
  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    throw PlayerException(
      123,
      'Decoder failed https://audio.example.com/a?secret=hidden',
      0,
    );
  }
}

class StreamErrorPlayer extends FakePlayer {
  final nativeErrors = StreamController<PlayerException>.broadcast();
  bool invalid = true;
  @override
  Stream<PlayerException> get errorStream => nativeErrors.stream;
  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) {
    if (invalid) {
      invalid = false;
      scheduleMicrotask(
        () => nativeErrors.add(PlayerException(456, 'Invalid data', 0)),
      );
      return Completer<Duration?>().future;
    }
    return super.setAudioSource(
      source,
      preload: preload,
      initialIndex: initialIndex,
      initialPosition: initialPosition,
    );
  }
}

void main() {
  test('an asynchronous decoder failure releases a hung load and allows the next track', () async {
    final player = StreamErrorPlayer();
    final audio = MusicHandler(player: player);
    final error = audio.errors.stream.first;
    const track = Track(
      id: 'C:/synthetic.m4a',
      title: 'Synthetic',
      folder: '.',
    );
    await audio.select([track], 0).timeout(const Duration(seconds: 1));
    expect(await error, contains('diagnóstico'));
    expect(audio.lastPlaybackError, contains('456'));
    await audio.select([track], 0);
    await Future<void>.delayed(Duration.zero);
    expect(player.playing, isTrue);
    await audio.close();
    await player.nativeErrors.close();
  });
  test(
    'load failures preserve native code without exposing URL or blaming format',
    () async {
      final audio = MusicHandler(player: NativeErrorPlayer());
      final error = audio.errors.stream.first;
      await audio.select([
        const Track(id: 'C:/synthetic.m4a', title: 'Synthetic', folder: '.'),
      ], 0);
      expect(await error, contains('diagnóstico'));
      expect(audio.lastPlaybackError, contains('123'));
      expect(audio.lastPlaybackError, isNot(contains('secret')));
      expect(audio.lastPlaybackError, isNot(contains('audio.example.com')));
      await audio.close();
    },
  );
}
