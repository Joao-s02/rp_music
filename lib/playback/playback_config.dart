import 'package:audio_service/audio_service.dart';

// Track changes briefly pause the decoder. Keep the already-started service
// foreground so Android need not grant a new background start for every track.
const playbackServiceConfig = AudioServiceConfig(
  androidNotificationChannelId: 'rp_music.playback',
  androidNotificationChannelName: 'Reproducción',
  androidNotificationIcon: 'drawable/ic_stat_music',
  androidStopForegroundOnPause: false,
  androidNotificationOngoing: false,
);
