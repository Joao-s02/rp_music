import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

import '../domain/track.dart';
import '../extensions/program_controller.dart';
import '../playback/music_handler.dart';
import 'youtube_music_api.dart';

class YoutubeSourceBroker {
  YoutubeSourceBroker(this.programs, this.audio, {YoutubeMusicApi? api})
    : api = api ?? YoutubeMusicApi() {
    audio.onlineAllowed = allowed;
    audio.onlineSourceLoader = (track) async {
      if (!allowed(track)) throw const FormatException('Fuente sin permiso.');
      final identity = YoutubeMusicApi.identity(track.id)!;
      final uri = await this.api.resolve(identity[2]);
      if (!allowed(track)) throw const FormatException('Permiso retirado.');
      return (
        source: AudioSource.uri(uri),
        artwork: YoutubeMusicApi.artwork(identity[2]),
      );
    };
    programs.addListener(_changed);
  }
  final ProgramController programs;
  final MusicHandler audio;
  final YoutubeMusicApi api;
  bool allowed(Track track) {
    final identity = YoutubeMusicApi.identity(track.id);
    return Platform.isAndroid &&
        identity != null &&
        programs.owner('source')?.package.id == identity[1] &&
        programs.allowed(identity[1], 'network.youtube') &&
        programs.allowed(identity[1], 'playback.control');
  }

  void _changed() {
    final index = audio.index;
    if (index < 0 || index >= audio.tracks.length) return;
    final track = audio.tracks[index];
    if (YoutubeMusicApi.identity(track.id) != null && !allowed(track)) {
      unawaited(audio.stop());
    }
  }

  void dispose() {
    programs.removeListener(_changed);
  }
}
