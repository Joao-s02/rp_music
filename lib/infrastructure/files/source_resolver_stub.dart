import 'package:rp_music/features/library/domain/source_resolver.dart';
import 'package:rp_music/features/library/domain/track_location.dart';

SourceResolver createSourceResolver() => const _StubSourceResolver();

class _StubSourceResolver implements SourceResolver {
  const _StubSourceResolver();

  @override
  Future<SourceLease> resolve(TrackLocation location) {
    throw UnsupportedError('SourceResolver is not implemented on this platform.');
  }
}
