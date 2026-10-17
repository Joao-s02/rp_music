import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rp_music/features/library/application/incremental_indexer.dart';
import 'package:rp_music/features/library/domain/library_repository.dart';
import 'package:rp_music/features/library/domain/source_resolver.dart';
import 'package:rp_music/features/library/domain/track.dart';
import 'package:rp_music/features/library/infrastructure/drift_library_repository.dart';
import 'package:rp_music/features/metadata/domain/metadata_reader.dart';
import 'package:rp_music/features/metadata/infrastructure/metadata_reader_factory.dart';
import 'package:rp_music/features/playback/application/playback_coordinator.dart';
import 'package:rp_music/features/playback/domain/audio_engine.dart';
import 'package:rp_music/features/playback/domain/playback_snapshot.dart';
import 'package:rp_music/features/playback/infrastructure/just_audio_engine.dart';
import 'package:rp_music/features/queue/domain/playback_queue.dart';
import 'package:rp_music/features/settings/domain/app_settings.dart';
import 'package:rp_music/infrastructure/database/app_database.dart';
import 'package:rp_music/infrastructure/files/source_resolver_factory.dart';
import 'package:rp_music/infrastructure/media_controls/media_controls_bridge_factory.dart';

// Database Provider
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Library Repository Provider
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftLibraryRepository(db);
});

// Metadata Reader Provider
final metadataReaderProvider = Provider<MetadataReader>((ref) {
  return getMetadataReader();
});

// Source Resolver Provider
final sourceResolverProvider = Provider<SourceResolver>((ref) {
  return getSourceResolver();
});

// Audio Engine Provider
final audioEngineProvider = Provider<AudioEngine>((ref) {
  final engine = JustAudioEngine();
  ref.onDispose(() => engine.dispose());
  return engine;
});

// Playback Coordinator Provider (Single owner of engine)
final playbackCoordinatorProvider = Provider<PlaybackCoordinator>((ref) {
  final engine = ref.watch(audioEngineProvider);
  final resolver = ref.watch(sourceResolverProvider);
  final repo = ref.watch(libraryRepositoryProvider);

  final coordinator = PlaybackCoordinator(
    engine: engine,
    sourceResolver: resolver,
    repository: repo,
  );

  // Initialize system media controls bridge
  getMediaControlsBridge(coordinator).then((bridge) {
    coordinator.snapshotStream.listen((snap) {
      bridge.updatePlaybackState(snap);
      if (snap.trackId != null) {
        repo.getTrack(snap.trackId!).then((t) => bridge.updateActiveTrack(t));
      } else {
        bridge.updateActiveTrack(null);
      }
    });
  });

  // Automatically restore session asynchronously without autoplay
  coordinator.restoreSession();

  ref.onDispose(() => coordinator.dispose());
  return coordinator;
});

// Playback Snapshot Stream Provider
final playbackSnapshotProvider = StreamProvider<PlaybackSnapshot>((ref) {
  final coordinator = ref.watch(playbackCoordinatorProvider);
  return coordinator.snapshotStream;
});

// Current Track Provider
final currentTrackProvider = FutureProvider<Track?>((ref) async {
  final snapAsync = ref.watch(playbackSnapshotProvider);
  final trackId = snapAsync.value?.trackId ?? ref.watch(playbackCoordinatorProvider).currentSnapshot.trackId;
  if (trackId == null) return null;
  final repo = ref.watch(libraryRepositoryProvider);
  return repo.getTrack(trackId);
});

// Playback Queue Provider
final playbackQueueProvider = StreamProvider<PlaybackQueue>((ref) {
  final coordinator = ref.watch(playbackCoordinatorProvider);
  return coordinator.queueStream;
});

// Tracks Watch Provider with optional search query
final tracksListProvider = StreamProvider.family<List<Track>, String?>((ref, searchQuery) {
  final repo = ref.watch(libraryRepositoryProvider);
  return repo.watchTracks(searchQuery: searchQuery);
});

// Incremental Indexer Provider
final incrementalIndexerProvider = Provider<IncrementalIndexer>((ref) {
  final repo = ref.watch(libraryRepositoryProvider);
  final reader = ref.watch(metadataReaderProvider);
  return IncrementalIndexer(repository: repo, metadataReader: reader);
});

// Settings Notifier & Provider
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setPrimaryColor(int colorValue) {
    state = state.copyWith(primaryColorValue: colorValue);
  }

  void setDensity(UiDensity density) {
    state = state.copyWith(density: density);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
