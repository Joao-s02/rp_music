import 'dart:async';
import 'dart:convert';

import '../app/library_controller.dart';
import '../playback/music_handler.dart';
import 'program_controller.dart';
import 'program_snapshot.dart';

class ProgramCoordinator {
  ProgramCoordinator(this.library, this.programs, this.audio) {
    library.addListener(schedule);
    programs.addListener(schedule);
    library.refreshPrograms = () {
      _signature = '';
      schedule();
    };
    audio.chooseNext = (tracks, index) async {
      final item = programs.owner('shuffle');
      if (item == null) return null;
      final snapshot = ProgramSnapshot(tracks, library.favorites);
      final result = await programs.invoke(item.package.id, 'shuffle', {
        'tracks': snapshot.rows,
        'current': index >= 0 && index < tracks.length
            ? snapshot.idFor(tracks[index].id)
            : null,
        'seed': DateTime.now().microsecondsSinceEpoch,
      });
      if (result == null ||
          !programs.allowed(item.package.id, 'playback.control')) {
        return null;
      }
      final next = snapshot.byId[result['next']];
      if (next == null) {
        await programs.reject(
          item.package.id,
          'La política devolvió una canción fuera de la cola.',
        );
        return null;
      }
      return tracks.indexWhere((track) => track.id == next.id);
    };
    schedule();
  }
  final LibraryController library;
  final ProgramController programs;
  final MusicHandler audio;
  Timer? _timer;
  String _signature = '';
  bool _working = false, _closed = false;
  void schedule() {
    if (_closed || library.loading || library.scanning) return;
    final signature = jsonEncode([
      library.tracks.map((track) => track.toJson()).toList(),
      library.favorites.toList()..sort(),
      library.playlistMeta.map(
        (name, meta) => MapEntry(name, [meta['owner'], meta['rule']]),
      ),
      programs.installed.values
          .map(
            (item) => [
              item.package.id,
              item.package.version,
              item.enabled,
              item.grants.toList()..sort(),
            ],
          )
          .toList(),
    ]);
    if (signature == _signature) return;
    _signature = signature;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 250), refresh);
  }

  Future<void> refresh() async {
    if (_closed) return;
    if (_working || programs.busy) {
      _timer = Timer(const Duration(milliseconds: 250), refresh);
      return;
    }
    _working = true;
    try {
      for (final entry in library.playlistMeta.entries.toList()) {
        final owner = entry.value['owner'];
        if (owner is! String ||
            entry.value['rule'] is! Map ||
            !programs.allowed(owner, 'playlists.manage') ||
            programs.installed[owner]?.package.slots.contains('lists') !=
                true) {
          continue;
        }
        final snapshot = ProgramSnapshot(library.tracks, library.favorites);
        final result = await programs.invoke(owner, 'lists', {
          'tracks': snapshot.rows,
          'filters': entry.value['rule'],
        });
        if (_closed ||
            result == null ||
            !programs.allowed(owner, 'playlists.manage') ||
            programs.installed[owner]?.package.slots.contains('lists') !=
                true) {
          continue;
        }
        try {
          await library.updateSmartPlaylist(
            entry.key,
            owner,
            snapshot.resolve(result['ids']).map((track) => track.id).toList(),
          );
        } on FormatException catch (error) {
          await programs.reject(owner, error.message);
        }
      }
    } finally {
      _working = false;
    }
  }

  void dispose() {
    _closed = true;
    _timer?.cancel();
    library.removeListener(schedule);
    programs.removeListener(schedule);
    library.refreshPrograms = null;
    audio.chooseNext = null;
  }
}
