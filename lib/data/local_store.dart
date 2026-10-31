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
  LocalStore(this.directory, {this.baseName = 'library'});
  final Directory directory;
  final String baseName;
  Future<void> _pending = Future.value();
  void Function(Map<String, dynamic>)? _validate;
  final Set<String> _rejected = {};
  bool _recoveryRequired = false;

  /// Opt-in validation keeps generic stores schema-free and honors load overrides.
  Future<Map<String, dynamic>> loadValidated(
    void Function(Map<String, dynamic>) validate,
  ) async {
    _rejected.clear();
    _validate = validate;
    try {
      final value = await load();
      if (value.isNotEmpty) validate(value);
      _recoveryRequired = false;
      return value;
    } catch (_) {
      _recoveryRequired = true;
      rethrow;
    } finally {
      _validate = null;
    }
  }

  Future<Map<String, dynamic>> load() async {
    for (final name in ['$baseName.json', '$baseName.backup.json']) {
      try {
        final file = File('${directory.path}/$name');
        if (!await file.exists()) continue;
        final text = await file.readAsString();
        final value = await _decodeSnapshot(text);
        _validate?.call(value);
        return value;
      } catch (error) {
        if (_validate != null) {
          _rejected.add(name);
          continue;
        }
        if (error is FormatException || error is FileSystemException) continue;
        rethrow;
      }
    }
    if (_validate != null && _rejected.isNotEmpty) {
      throw const FormatException('No valid snapshot.');
    }
    return {};
  }

  Future<void> save(Map<String, dynamic> value) {
    final operation = _pending.then((_) async {
      if (_recoveryRequired) {
        throw StateError('Recovery required before saving.');
      }
      final encoded = await _encodeSnapshot(value);
      await directory.create(recursive: true);
      final target = File('${directory.path}/$baseName.json');
      final backup = File('${directory.path}/$baseName.backup.json');
      final temporary = File('${directory.path}/$baseName.pending.json');
      await temporary.writeAsString(encoded, flush: true);
      // Never rotate a rejected main over the valid fallback. Keep rejected bytes
      // separately, including across subsequent saves and process restarts.
      for (final name in _rejected.toList()) {
        final file = File('${directory.path}/$name');
        if (await file.exists()) {
          var suffix = 0;
          var preserved = '${file.path}.rejected';
          while (await File(preserved).exists()) {
            preserved = '${file.path}.rejected.${++suffix}';
          }
          await file.rename(preserved);
        }
        _rejected.remove(name);
      }
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
