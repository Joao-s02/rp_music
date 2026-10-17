import 'package:rp_music/features/library/domain/source_resolver.dart';
import 'package:rp_music/features/library/domain/track_location.dart';
import 'package:rp_music/features/playback/domain/playable_source.dart';
import 'package:rp_music/features/playback/domain/playback_failure.dart';
import 'package:web/web.dart' as web;

SourceResolver createSourceResolver() => SourceResolverWeb();

class SourceResolverWeb implements SourceResolver {
  static final Map<String, Uri> _activeBlobRegistry = {};

  static void registerBlob(String locatorKey, Uri blobUri) {
    _activeBlobRegistry[locatorKey] = blobUri;
  }

  @override
  Future<SourceLease> resolve(TrackLocation location) async {
    final key = location.locatorKey;
    final blobUri = _activeBlobRegistry[key] ?? (key.startsWith('blob:') ? Uri.parse(key) : null);

    if (blobUri == null) {
      throw PlaybackFailure(
        reason: PlaybackFailureReason.sourceDisconnected,
        message: 'Web track requires reconnecting file access: $key',
      );
    }

    return _WebBlobLease(WebBlobSource(blobUri));
  }
}

class _WebBlobLease implements SourceLease {
  @override
  final WebBlobSource source;

  _WebBlobLease(this.source);

  @override
  Future<void> release() async {
    try {
      web.URL.revokeObjectURL(source.blobUri.toString());
    } catch (_) {}
  }
}
