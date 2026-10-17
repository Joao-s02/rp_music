import 'package:rp_music/core/ids/ids.dart';

enum SourceKind {
  folder,
  mediaStore,
  filePicker,
  opfs,
}

enum SourceStatus {
  active,
  disconnected,
  permissionDenied,
}

class LibrarySource {
  final SourceId id;
  final SourceKind kind;
  final String locator;
  final SourceStatus status;
  final DateTime? lastSuccessfulScan;
  final int scanGeneration;

  const LibrarySource({
    required this.id,
    required this.kind,
    required this.locator,
    this.status = SourceStatus.active,
    this.lastSuccessfulScan,
    this.scanGeneration = 0,
  });

  LibrarySource copyWith({
    SourceId? id,
    SourceKind? kind,
    String? locator,
    SourceStatus? status,
    DateTime? lastSuccessfulScan,
    int? scanGeneration,
  }) {
    return LibrarySource(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      locator: locator ?? this.locator,
      status: status ?? this.status,
      lastSuccessfulScan: lastSuccessfulScan ?? this.lastSuccessfulScan,
      scanGeneration: scanGeneration ?? this.scanGeneration,
    );
  }
}
