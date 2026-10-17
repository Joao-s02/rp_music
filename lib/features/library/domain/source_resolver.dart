import 'package:rp_music/features/library/domain/track_location.dart';
import 'package:rp_music/features/playback/domain/playable_source.dart';

abstract interface class SourceLease {
  PlayableSource get source;
  Future<void> release();
}

abstract interface class SourceResolver {
  Future<SourceLease> resolve(TrackLocation location);
}
