// Separate technical probe. Never distribute as the RP Music application.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:rp_music/playback/playback_config.dart';

import 'package:rp_music/sources/youtube_client.dart';

class ProbeHandler extends BaseAudioHandler with SeekHandler {
  final player = AudioPlayer();
  ProbeHandler() {
    player.playbackEventStream.listen((_) {
      playbackState.add(
        PlaybackState(
          controls: [
            player.playing ? MediaControl.pause : MediaControl.play,
            MediaControl.stop,
          ],
          processingState: switch (player.processingState) {
            ProcessingState.idle => AudioProcessingState.idle,
            ProcessingState.loading => AudioProcessingState.loading,
            ProcessingState.buffering => AudioProcessingState.buffering,
            ProcessingState.ready => AudioProcessingState.ready,
            ProcessingState.completed => AudioProcessingState.completed,
          },
          playing: player.playing,
          updatePosition: player.position,
          bufferedPosition: player.bufferedPosition,
        ),
      );
    }, onError: (Object _) {});
  }
  @override
  Future<void> play() async {
    unawaited(player.play());
  }

  @override
  Future<void> pause() => player.pause();
  @override
  Future<void> seek(Duration position) => player.seek(position);
  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final handler = Platform.isAndroid
      ? await AudioService.init(
          builder: ProbeHandler.new,
          config: playbackServiceConfig,
        )
      : ProbeHandler();
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  final text = ValueNotifier<String>(
    'Preparando prueba de audio de demostración…',
  );
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: ValueListenableBuilder<String>(
            valueListenable: text,
            builder: (_, value, _) => Text(value),
          ),
        ),
      ),
    ),
  );
  final report = <String, dynamic>{
    'platform': Platform.operatingSystem,
    'ok': false,
  };
  void record(String key, dynamic value) {
    report[key] = value;
    // No signed media URLs, cookies, tokens or real user history in logs.
    debugPrint('RP_YOUTUBE_PROBE ${jsonEncode(report)}');
    text.value = jsonEncode(report);
    if (Platform.isWindows) {
      File('build/youtube-audio-probe.json')
          .writeAsStringSync(jsonEncode(report));
    }
  }

  final yt = YoutubeExplode();
  try {
    // Blender Foundation public demonstration, not a user's private library.
    const id = 'aqz-KE-bpKQ';
    final metadata = await yt.videos
        .get(id)
        .timeout(const Duration(seconds: 25));
    record('metadata', true);
    final manifest = await yt.videos.streams
        .getManifest(id, ytClients: [youtubeMusicClient])
        .timeout(const Duration(seconds: 40));
    final candidates = manifest.audioOnly
        .where((s) => s.container.name == 'mp4')
        .toList();
    if (candidates.isEmpty) throw StateError('no_audio');
    record('manifest', true);
    handler.mediaItem.add(
      MediaItem(
        id: 'youtube:$id',
        title: metadata.title,
        artist: metadata.author,
        duration: metadata.duration,
      ),
    );
    final selected = candidates.firstWhere(
      (s) => s.tag == 140,
      orElse: () => candidates.first,
    );
    await handler.player
        .setUrl(selected.url.toString())
        .timeout(const Duration(seconds: 35));
    record('loaded', true);
    await handler.player.setVolume(0.15);
    await handler.play();
    final deadline = DateTime.now().add(const Duration(seconds: 25));
    while (handler.player.position < const Duration(seconds: 3) &&
        DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (handler.player.position < const Duration(seconds: 3)) {
      throw StateError('position_not_advancing');
    }
    record('playing', true);
    await handler.pause();
    record('pause', !handler.player.playing);
    await handler.seek(const Duration(seconds: 10));
    await handler.play();
    await Future<void>.delayed(const Duration(seconds: 3));
    record('seek', handler.player.position > const Duration(seconds: 10));
    record('initialChecksPassed', true);
    // Android stays playing for an explicit adb HOME/screen-off observation.
    var previous = handler.player.position.inMilliseconds;
    var continuous = true;
    for (var i = 0; i < 12; i++) {
      await Future<void>.delayed(const Duration(seconds: 5));
      final now = handler.player.position.inMilliseconds;
      if (now < previous || !handler.player.playing) continuous = false;
      previous = now;
      record('positionMs', now);
      record('playingNow', handler.player.playing);
    }
    record('continuous', continuous);
    record('ok', continuous);
  } catch (e) {
    record('errorType', e.runtimeType.toString());
    if (e is PlayerException) {
      record('playerCode', e.code);
      record(
        'playerMessage',
        e.message?.replaceAll(RegExp(r'https?://[^\s]+'), '[media-url]'),
      );
    }
  } finally {
    yt.close();
    await handler.stop();
    await handler.player.dispose();
    if (Platform.isWindows) exit(report['ok'] == true ? 0 : 1);
  }
}
