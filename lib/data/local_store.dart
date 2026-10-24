import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// Separate closures avoid capturing the writer's non-sendable Future chain.
Future<String> _encodeSnapshot(Map<String, dynamic> value) =>
    Isolate.run(() => jsonEncode(value));
Future<Map<String, dynamic>> _decodeSnapshot(String value) =>
    Isolate.run(() => jsonDecode(value) as Map<String, dynamic>);

/// Ordered writes with a recoverable previous snapshot.
class LocalStore {
  LocalStore(this.directory);
  final Directory directory;
  Future<void> _pending = Future.value();
  Future<Map<String, dynamic>> load() async {
    for (final name in ['library.json', 'library.backup.json']) {
      try {
        final file = File('${directory.path}/$name');
        if (!await file.exists()) continue;
        final text = await file.readAsString();
        return await _decodeSnapshot(text);
      } on FormatException {
        continue;
      } on FileSystemException {
        continue;
      }
    }
    return {};
  }

  Future<void> save(Map<String, dynamic> value) {
    final operation = _pending.then((_) async {
      final encoded = await _encodeSnapshot(value);
      await directory.create(recursive: true);
      final target = File('${directory.path}/library.json');
      final backup = File('${directory.path}/library.backup.json');
      final temporary = File('${directory.path}/library.pending.json');
      await temporary.writeAsString(encoded, flush: true);
      if (await target.exists()) {
        if (await backup.exists()) await backup.delete();
        await target.rename(backup.path);
      }
      await temporary.rename(target.path);
    });
    _pending = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }
}
