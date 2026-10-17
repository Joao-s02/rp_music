sealed class PlayableSource {
  const PlayableSource();
}

/// An authorized native file path on Windows or desktop/mobile.
final class NativeFileSource extends PlayableSource {
  final String path;
  const NativeFileSource(this.path);

  @override
  String toString() => 'NativeFileSource($path)';
}

/// An Android content:// URI from SAF or MediaStore.
final class AndroidContentUriSource extends PlayableSource {
  final Uri uri;
  const AndroidContentUriSource(this.uri);

  @override
  String toString() => 'AndroidContentUriSource($uri)';
}

/// A Web blob: URL created from a user-selected File handle.
final class WebBlobSource extends PlayableSource {
  final Uri blobUri;
  const WebBlobSource(this.blobUri);

  @override
  String toString() => 'WebBlobSource($blobUri)';
}

/// An application-managed audio file (e.g. copied to app storage cache).
final class ManagedAppFileSource extends PlayableSource {
  final String localPath;
  const ManagedAppFileSource(this.localPath);

  @override
  String toString() => 'ManagedAppFileSource($localPath)';
}
