enum PlaybackFailureReason {
  permissionDenied,
  sourceMissing,
  sourceDisconnected,
  unsupportedFormat,
  corruptMedia,
  storageUnavailable,
  backendFailure,
  userActivationRequired,
}

class PlaybackFailure {
  final PlaybackFailureReason reason;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const PlaybackFailure({
    required this.reason,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() => 'PlaybackFailure($reason: $message)';
}
