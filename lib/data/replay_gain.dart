import 'dart:io';
import 'dart:math';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

enum ReplayGainMode { off, track, album }

class ReplayGainTags {
  const ReplayGainTags(
    this.trackGain,
    this.trackPeak,
    this.albumGain,
    this.albumPeak,
  );

  final double? trackGain, trackPeak, albumGain, albumPeak;

  static ReplayGainTags? read(File file) {
    final tags = readAllMetadata(file, getImage: false);
    final fields = switch (tags) {
      VorbisMetadata() => {
        'REPLAYGAIN_TRACK_GAIN': tags.replayGainTrackGain.firstOrNull ?? '',
        'REPLAYGAIN_TRACK_PEAK': tags.replayGainTrackPeak.firstOrNull ?? '',
        'REPLAYGAIN_ALBUM_GAIN': tags.replayGainAlbumGain.firstOrNull ?? '',
        'REPLAYGAIN_ALBUM_PEAK': tags.replayGainAlbumPeak.firstOrNull ?? '',
      },
      Mp3Metadata() => tags.customMetadata,
      ApeMetadata() => tags.unknowns,
      _ => const <String, String>{},
    };
    final values = fields.map(
      (key, value) => MapEntry(key.trim().toUpperCase(), value.trim()),
    );
    double? parse(String key) {
      final value = double.tryParse(
        (values[key] ?? '').replaceFirst(
          RegExp(r'\s*dB$', caseSensitive: false),
          '',
        ),
      );
      return value != null && value.isFinite ? value : null;
    }

    return ReplayGainTags(
      parse('REPLAYGAIN_TRACK_GAIN'),
      parse('REPLAYGAIN_TRACK_PEAK'),
      parse('REPLAYGAIN_ALBUM_GAIN'),
      parse('REPLAYGAIN_ALBUM_PEAK'),
    );
  }

  double multiplier(ReplayGainMode mode) {
    if (mode == ReplayGainMode.off) return 1;
    final gain = mode == ReplayGainMode.album ? albumGain : trackGain;
    if (gain == null) return 1;
    final peak = mode == ReplayGainMode.album ? albumPeak : trackPeak;
    final ceiling = peak != null && peak > 0 && peak.isFinite ? 1 / peak : 1.0;
    return min(pow(10, gain.clamp(-60, 30) / 20).toDouble(), ceiling);
  }
}
