import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:rp_music/core/diagnostics/diagnostics_service.dart';
import 'package:rp_music/core/ids/ids.dart';
import 'package:rp_music/features/library/domain/library_repository.dart';
import 'package:rp_music/features/library/domain/library_source.dart';
import 'package:rp_music/features/library/domain/track.dart';
import 'package:rp_music/features/library/domain/track_location.dart';
import 'package:rp_music/features/metadata/domain/metadata_reader.dart';
import 'package:rp_music/infrastructure/files/web_blob_registry.dart';

class IncrementalIndexer {
  final LibraryRepository _repository;
  final MetadataReader _metadataReader;
  final DiagnosticsService _diagnostics = DiagnosticsService();

  IncrementalIndexer({
    required this._repository,
    required this._metadataReader,
  });

  /// Index files selected via file_picker
  Future<List<Track>> indexPickedFiles(List<PlatformFile> pickedFiles) async {
    final importedTracks = <Track>[];
    if (pickedFiles.isEmpty) return importedTracks;

    _diagnostics.info('IncrementalIndexer', 'Indexing ${pickedFiles.length} picked files');

    final sourceId = SourceId('picker_source');
    final existingSource = await _repository.getSource(sourceId);
    if (existingSource == null) {
      await _repository.saveSource(
        LibrarySource(
          id: sourceId,
          kind: SourceKind.filePicker,
          locator: 'user_selected_files',
          status: SourceStatus.active,
          scanGeneration: 1,
        ),
      );
    }

    for (final file in pickedFiles) {
      try {
        final track = await _processPlatformFile(file, sourceId);
        if (track != null) {
          importedTracks.add(track);
        }
      } catch (e, stack) {
        _diagnostics.error('IncrementalIndexer', 'Failed to index file ${file.name}: $e', {'stack': stack.toString()});
      }
    }

    return importedTracks;
  }

  Future<Track?> _processPlatformFile(PlatformFile file, SourceId sourceId) async {
    String locatorKey;
    Uint8List? fileBytes;

    if (kIsWeb) {
      locatorKey = 'blob:${file.name}';
      try {
        fileBytes = await file.xFile.readAsBytes();
        final syntheticBlobUri = Uri.dataFromBytes(fileBytes, mimeType: 'audio/mpeg');
        registerWebBlob(locatorKey, syntheticBlobUri);
      } catch (_) {}
    } else {
      if (file.path == null) return null;
      locatorKey = file.path!;
    }

    // Check if location already exists
    final existingLoc = await _repository.getLocationByLocator(sourceId, locatorKey);
    TrackId trackId;
    if (existingLoc != null) {
      trackId = existingLoc.trackId;
    } else {
      trackId = TrackId.generate();
    }

    // Read metadata
    final metadata = kIsWeb && fileBytes != null
        ? await _metadataReader.readMetadataFromBytes(fileBytes, fileName: file.name)
        : await _metadataReader.readMetadataFromFile(locatorKey);

    final track = Track(
      id: trackId,
      title: metadata.title?.isNotEmpty == true ? metadata.title! : file.name,
      artistName: metadata.artist,
      albumTitle: metadata.album,
      duration: metadata.duration,
      trackNo: metadata.trackNumber,
      discNo: metadata.discNumber,
      year: metadata.year,
    );

    int fileSize = 0;
    try {
      fileSize = await file.xFile.length();
    } catch (_) {}

    final location = TrackLocation(
      id: existingLoc?.id ?? newId(),
      trackId: trackId,
      sourceId: sourceId,
      locatorKey: locatorKey,
      size: fileSize,
      modifiedAt: DateTime.now(),
      lastSeenGeneration: 1,
      availability: LocationAvailability.available,
    );

    await _repository.upsertTrack(track, location);
    return track;
  }
}
