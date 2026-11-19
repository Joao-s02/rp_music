import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

bool _desktopInitialized = false;

final nativeEqualizers = Expando<AndroidEqualizer>();

AudioPlayer createNativeAudioPlayer() {
  if (Platform.isWindows && !_desktopInitialized) {
    JustAudioMediaKit.ensureInitialized(windows: true, linux: false);
    JustAudioMediaKit.title = 'RP Music';
    JustAudioMediaKit.prefetchPlaylist = true;
    // Only the protocols used by local music and the host's HTTP audio bridge.
    JustAudioMediaKit.protocolWhitelist = const [
      'file',
      'http',
      'https',
      'tcp',
      'tls',
      'crypto',
      'data',
    ];
    _desktopInitialized = true;
  }
  if (!Platform.isAndroid) return AudioPlayer();
  final equalizer = AndroidEqualizer();
  final player = AudioPlayer(
    audioPipeline: AudioPipeline(androidAudioEffects: [equalizer]),
  );
  nativeEqualizers[player] = equalizer;
  return player;
}

const desktopEqualizerFrequencies = [60, 150, 400, 1000, 2400, 6000, 12000];

Future<void> setDesktopEqualizer(bool enabled, List<double> gains) {
  final filters = <String>[];
  if (enabled) {
    for (final (index, frequency) in desktopEqualizerFrequencies.indexed) {
      final gain = gains.elementAtOrNull(index)?.clamp(-12, 12) ?? 0;
      if (gain != 0) filters.add('equalizer=f=$frequency:t=o:w=1:g=$gain');
    }
  }
  return JustAudioMediaKit.setAudioFilters(
    filters.isEmpty ? '' : 'lavfi=[${filters.join(',')}]',
  );
}
