import 'dart:io';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

import 'equalizer_settings.dart';

bool _desktopInitialized = false;
final nativeEqualizers = Expando<AndroidEqualizer>();
const _equalizerChannel = MethodChannel('rp_music/equalizer');

Future<bool> supportsNativeDynamicsControls() async {
  if (Platform.isAndroid) return true;
  if (!Platform.isWindows) return false;
  try {
    return await _equalizerChannel.invokeMethod<bool>('hasDynamicsFilters') ??
        false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}

AudioPlayer createNativeAudioPlayer() {
  if (Platform.isWindows && !_desktopInitialized) {
    JustAudioMediaKit.ensureInitialized(windows: true, linux: false);
    JustAudioMediaKit.title = 'RP Music';
    JustAudioMediaKit.prefetchPlaylist = true;
    // Only the protocols used by local music and the host's HTTP audio bridge.
    JustAudioMediaKit.protocolWhitelist = [
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

Future<List<int>> legacyAndroidEqualizerFrequencies(int sessionId) async =>
    await _equalizerChannel.invokeListMethod<int>(
      'legacyFrequencies',
      sessionId,
    ) ??
    const [];

Future<void> configureNativeEqualizer({
  required bool enabled,
  required List<int> frequencies,
  required List<double> gains,
  required EqualizerEffects effects,
  required bool dynamicsControls,
}) async {
  final bands = <ParametricBand>[
    for (final (index, hz) in frequencies.indexed)
      ParametricBand(
        hz: hz.toDouble(),
        gain: gains.elementAtOrNull(index)?.clamp(-12, 12) ?? 0,
        q: 1.41421356237,
      ),
    ...effects.filters,
  ];
  if (Platform.isAndroid) {
    await _equalizerChannel.invokeMethod<void>('configure', {
      'enabled': enabled,
      'bands': bands.map((band) => band.toJson()).toList(),
      'preamp': effects.preamp,
      'balance': effects.balance,
      'limiter': effects.limiter,
    });
  } else if (Platform.isWindows) {
    await JustAudioMediaKit.setAudioFilters(
      enabled ? desktopEqualizerFilters(bands, effects, dynamicsControls) : '',
    );
  }
}

String desktopEqualizerFilters(
  List<ParametricBand> bands,
  EqualizerEffects effects,
  bool dynamicsControls,
) {
  final filters = [
    if (dynamicsControls && effects.preamp != 0)
      'volume=volume=${effects.preamp}dB',
    for (final band in bands)
      if (band.gain != 0)
        'equalizer=f=${band.hz}:t=q:w=${band.q}:g=${band.gain}',
    if (dynamicsControls && effects.balance != 0)
      'stereotools=balance_out=${effects.balance}:bmode_out=balance',
    if (dynamicsControls && effects.limiter)
      'alimiter=limit=0.95:level=0:latency=1',
  ];
  return filters.isEmpty ? '' : 'lavfi=[${filters.join(',')}]';
}
