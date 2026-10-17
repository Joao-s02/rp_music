import 'dart:js_interop';
import 'package:rp_music/features/library/domain/track.dart';
import 'package:rp_music/features/playback/application/playback_coordinator.dart';
import 'package:rp_music/features/playback/domain/playback_snapshot.dart';
import 'package:rp_music/infrastructure/media_controls/media_controls_bridge.dart';
import 'package:web/web.dart' as web;

class WebMediaSessionBridge implements MediaControlsBridge {
  final PlaybackCoordinator _coordinator;

  WebMediaSessionBridge(this._coordinator);

  @override
  Future<void> init() async {
    try {
      final session = web.window.navigator.mediaSession;

      session.setActionHandler('play', ((JSObject? _) {
        _coordinator.play();
      }).toJS);

      session.setActionHandler('pause', ((JSObject? _) {
        _coordinator.pause();
      }).toJS);

      session.setActionHandler('previoustrack', ((JSObject? _) {
        _coordinator.skipPrevious();
      }).toJS);

      session.setActionHandler('nexttrack', ((JSObject? _) {
        _coordinator.skipNext();
      }).toJS);

      session.setActionHandler('seekto', ((JSObject? details) {
        if (details != null) {
          final seekTime = (details as dynamic).seekTime;
          if (seekTime != null) {
            _coordinator.seek(Duration(milliseconds: ((seekTime as num) * 1000).round()));
          }
        }
      }).toJS);
    } catch (_) {
      // MediaSession not supported or restricted in current context
    }
  }

  @override
  void updatePlaybackState(PlaybackSnapshot snapshot) {
    try {
      final session = web.window.navigator.mediaSession;
      session.playbackState = snapshot.isPlaying ? 'playing' : 'paused';
      if (snapshot.duration != null && snapshot.duration!.inMilliseconds > 0) {
        session.setPositionState(
          web.MediaPositionState(
            duration: snapshot.duration!.inMilliseconds / 1000.0,
            playbackRate: 1.0,
            position: snapshot.position.inMilliseconds / 1000.0,
          ),
        );
      }
    } catch (_) {}
  }

  @override
  void updateActiveTrack(Track? track) {
    try {
      final session = web.window.navigator.mediaSession;
      if (track == null) {
        session.metadata = null;
        return;
      }
      session.metadata = web.MediaMetadata(
        web.MediaMetadataInit(
          title: track.title,
          artist: track.artistName ?? 'Unknown Artist',
          album: track.albumTitle ?? 'Unknown Album',
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {}
}
