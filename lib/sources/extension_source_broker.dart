import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../domain/track.dart';
import '../extensions/program_controller.dart';
import '../playback/music_handler.dart';
import 'extension_source_service.dart';

class ExtensionSourceBroker {
  ExtensionSourceBroker(
    this.programs,
    this.audio, {
    ExtensionSourceService? service,
  }) : service = service ?? ExtensionSourceService(programs) {
    audio.onlineAllowed = allowed;
    audio.onlineSourceLoader = (track) async {
      if (!allowed(track)) throw const FormatException('Fuente sin permiso.');
      final uri = await this.service.resolve(track);
      if (!allowed(track)) throw const FormatException('Permiso retirado.');
      return (
        source: AudioSource.uri(uri),
        artwork: track.artwork == null ? null : Uri.parse(track.artwork!),
      );
    };
    programs.addListener(changed);
  }
  final ProgramController programs;
  final MusicHandler audio;
  final ExtensionSourceService service;
  bool allowed(Track track) =>
      track.sourceId != null && service.available(track.sourceId!);
  void changed() {
    if (audio.index < 0 || audio.index >= audio.tracks.length) return;
    final track = audio.tracks[audio.index];
    if (track.sourceId != null && !allowed(track)) unawaited(audio.stop());
  }

  void dispose() => programs.removeListener(changed);
}
