import 'package:rp_music/core/ids/ids.dart';

enum LocationAvailability {
  available,
  disconnected,
  missing,
  permissionDenied,
}

class TrackLocation {
  final String id;
  final TrackId trackId;
  final SourceId sourceId;
  final String locatorKey;
  final int size;
  final DateTime? modifiedAt;
  final String? providerVersion;
  final String? fingerprint;
  final LocationAvailability availability;
  final int lastSeenGeneration;

  const TrackLocation({
    required this.id,
    required this.trackId,
    required this.sourceId,
    required this.locatorKey,
    required this.size,
    this.modifiedAt,
    this.providerVersion,
    this.fingerprint,
    this.availability = LocationAvailability.available,
    required this.lastSeenGeneration,
  });

  TrackLocation copyWith({
    String? id,
    TrackId? trackId,
    SourceId? sourceId,
    String? locatorKey,
    int? size,
    DateTime? modifiedAt,
    String? providerVersion,
    String? fingerprint,
    LocationAvailability? availability,
    int? lastSeenGeneration,
  }) {
    return TrackLocation(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      sourceId: sourceId ?? this.sourceId,
      locatorKey: locatorKey ?? this.locatorKey,
      size: size ?? this.size,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      providerVersion: providerVersion ?? this.providerVersion,
      fingerprint: fingerprint ?? this.fingerprint,
      availability: availability ?? this.availability,
      lastSeenGeneration: lastSeenGeneration ?? this.lastSeenGeneration,
    );
  }
}
