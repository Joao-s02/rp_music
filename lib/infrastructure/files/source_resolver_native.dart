import 'dart:io';
import 'package:rp_music/features/library/domain/source_resolver.dart';
import 'package:rp_music/features/library/domain/track_location.dart';
import 'package:rp_music/features/playback/domain/playable_source.dart';
import 'package:rp_music/features/playback/domain/playback_failure.dart';

SourceResolver createSourceResolver() => const SourceResolverNative();

class SourceResolverNative implements SourceResolver {
  const SourceResolverNative();

  @override
  Future<SourceLease> resolve(TrackLocation location) async {
    final key = location.locatorKey;

    if (key.startsWith('content://')) {
      return _AndroidContentLease(AndroidContentUriSource(Uri.parse(key)));
    }

    final file = File(key);
    final exists = await file.exists();
    if (!exists) {
      throw PlaybackFailure(
        reason: PlaybackFailureReason.sourceMissing,
        message: 'File does not exist: $key',
      );
    }

    return _NativeFileLease(NativeFileSource(file.path));
  }
}

class _NativeFileLease implements SourceLease {
  @override
  final NativeFileSource source;

  _NativeFileLease(this.source);

  @override
  Future<void> release() async {
    // No-op for direct permanent local files
  }
}

class _AndroidContentLease implements SourceLease {
  @override
  final AndroidContentUriSource source;

  _AndroidContentLease(this.source);

  @override
  Future<void> release() async {
    // Content URI does not require local temp deletion
  }
}
