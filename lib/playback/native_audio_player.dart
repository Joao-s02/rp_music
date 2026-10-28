import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

bool _desktopInitialized = false;

AudioPlayer createNativeAudioPlayer() {
  if (Platform.isWindows && !_desktopInitialized) {
    JustAudioMediaKit.ensureInitialized(windows: true, linux: false);
    JustAudioMediaKit.title = 'RP Music';
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
  return AudioPlayer();
}
