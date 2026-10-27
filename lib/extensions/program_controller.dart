import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/local_store.dart';
import '../app/app_version.dart';
import 'program_package.dart';
import 'program_runtime.dart';

class ProgramController extends ChangeNotifier {
  ProgramController(this.store, {ProgramRuntime? runtime})
    : runtime = runtime ?? ProgramRuntime();
  final LocalStore store;
  final ProgramRuntime runtime;
  final installed = <String, InstalledProgram>{};
  final owners = <String, String>{};
  final privateData = <String, Map<String, dynamic>>{};
  String? message;
  String? _running;
  bool _disposed = false;
  bool get busy => _running != null;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  InstalledProgram? owner(String slot) {
    final item = installed[owners[slot]];
    return item != null && item.enabled && item.authorized ? item : null;
  }

  bool allowed(String id, String permission) {
    final item = installed[id];
    return item != null &&
        item.enabled &&
        item.authorized &&
        item.grants.contains(permission);
  }

  Future<void> initialize() async {
    final data = await store.load();
    for (final raw in data['installed'] as List? ?? []) {
      try {
        final map = Map<String, dynamic>.from(raw as Map);
        final package = ProgramPackage.parse(
          Map<String, dynamic>.from(map['package'] as Map),
        );
        final grants = (map['grants'] as List)
            .cast<String>()
            .where(package.permissions.contains)
            .toSet();
        final item = InstalledProgram(
          package,
          grants,
          enabled: map['enabled'] == true,
          failures: (map['failures'] as int? ?? 0).clamp(0, 3),
        );
        if (data['running'] == package.id ||
            item.failures >= 3 ||
            !item.authorized) {
          item.enabled = false;
          item.error = 'Desactivada por recuperación o falta de permisos. Puedes revisarla y reactivarla.';
        }
        installed[package.id] = item;
      } catch (_) {
        message = 'Se omitió un paquete guardado incompatible.';
      }
    }
    for (final entry in (data['owners'] as Map? ?? {}).entries) {
      if (programSlots.containsKey(entry.key) &&
          installed[entry.value]?.package.slots.contains(entry.key) == true) {
        owners[entry.key as String] = entry.value as String;
      }
    }
    for (final entry in (data['private'] as Map? ?? {}).entries) {
      if (installed.containsKey(entry.key) && entry.value is Map) {
        privateData[entry.key as String] = Map<String, dynamic>.from(
          entry.value as Map,
        );
      }
    }
    await persist();
    _notify();
  }

  Future<void> persist() => store.save({
    'schema': 2,
    'installed': installed.values.map((item) => item.toJson()).toList(),
    'owners': Map<String, String>.of(owners),
    'private': jsonDecode(jsonEncode(privateData)),
    'running': _running,
  });
  Future<void> install(
    ProgramPackage package,
    Set<String> grants, {
    bool enable = true,
  }) async {
    if (!versionAtLeast(appVersion, package.minAppVersion)) {
      throw FormatException(
        'Requiere RP Music ${package.minAppVersion} o posterior.',
      );
    }
    if (busy) {
      throw const FormatException('Espera a que termine la extensión activa.');
    }
    if (installed.length >= 16 && !installed.containsKey(package.id)) {
      throw const FormatException('Límite de 16 extensiones instaladas.');
    }
    await runtime.compile(package.source);
    final item = InstalledProgram(
      package,
      grants.intersection(package.permissions),
      enabled: enable,
    );
    if (!item.authorized) item.enabled = false;
    installed[package.id] = item;
    if (item.enabled) {
      for (final slot in package.slots.where((slot) => slot != 'lists')) {
        owners.putIfAbsent(slot, () => package.id);
      }
    }
    message =
        'Instalada ${package.name}. Revisa quién controla cada función si hay conflictos.';
    await persist();
    _notify();
  }

  Future<void> setEnabled(String id, bool value) async {
    if (busy) return;
    final item = installed[id];
    if (item == null || (value && !item.authorized)) return;
    item.enabled = value;
    item.failures = 0;
    item.error = null;
    if (value) {
      for (final slot in item.package.slots.where((slot) => slot != 'lists')) {
        owners.putIfAbsent(slot, () => id);
      }
    }
    await persist();
    _notify();
  }

  Future<void> setGrants(String id, Set<String> grants) async {
    if (busy) return;
    final item = installed[id];
    if (item == null) return;
    item.grants = grants.intersection(item.package.permissions);
    if (!item.authorized) item.enabled = false;
    await persist();
    _notify();
  }

  Future<void> choose(String slot, String? id) async {
    if (busy) return;
    if (id == null) {
      owners.remove(slot);
    } else {
      final item = installed[id];
      if (item == null ||
          !item.enabled ||
          !item.authorized ||
          !item.package.slots.contains(slot)) {
        return;
      }
      owners[slot] = id;
    }
    await persist();
    _notify();
  }

  Future<void> restoreBase() async {
    owners.clear();
    for (final item in installed.values) {
      item.enabled = false;
    }
    await persist();
    _notify();
  }

  Future<void> remove(String id) async {
    if (busy) return;
    installed.remove(id);
    owners.removeWhere((slot, value) => value == id);
    // Keep data and list definitions for explicit reinstall/recovery.
    await persist();
    _notify();
  }

  Future<void> savePrivate(String id, Map<String, dynamic> data) async {
    if (!allowed(id, 'storage.private')) {
      throw const FormatException('Sin permiso para guardar datos propios.');
    }
    if (utf8.encode(jsonEncode(data)).length > 65536) {
      throw const FormatException('Datos propios mayores de 64 KB.');
    }
    privateData[id] = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(data)) as Map,
    );
    await persist();
  }

  Future<void> reject(String id, String error) async {
    final item = installed[id];
    if (item == null) return;
    item.failures++;
    item.error = error;
    if (item.failures >= 3) item.enabled = false;
    message = 'Salida inválida de ${item.package.name}. Se conserva la base.';
    await persist();
    _notify();
  }

  Future<Map<String, dynamic>?> invoke(
    String id,
    String event,
    Map<String, dynamic> input,
  ) async {
    final item = installed[id];
    if (item == null || !item.enabled || !item.authorized || busy) return null;
    final snapshot = Map<String, dynamic>.from(input);
    if (!allowed(id, 'library.read')) {
      snapshot.remove('tracks');
      snapshot.remove('favorites');
      snapshot.remove('queue');
    }
    snapshot['event'] = event;
    if (allowed(id, 'storage.private')) {
      snapshot['state'] = privateData[id] ?? {};
    }
    _running = id;
    final watch = Stopwatch()..start();
    try {
      await persist();
      final result = await runtime.execute(item.package.source, snapshot);
      if (_disposed ||
          installed[id] != item ||
          !item.enabled ||
          !item.authorized) {
        return null;
      }
      if (result.containsKey('state')) {
        if (!allowed(id, 'storage.private') || result['state'] is! Map) {
          throw const FormatException(
            'Sin permiso o formato válido para guardar estado.',
          );
        }
        final encoded = jsonEncode(result['state']);
        if (utf8.encode(encoded).length > 65536) {
          throw const FormatException('Estado privado mayor de 64 KB.');
        }
        privateData[id] = Map<String, dynamic>.from(jsonDecode(encoded) as Map);
      }
      item.error = null;
      return result;
    } catch (error) {
      item.failures++;
      item.error = event == 'source' || event == 'lyrics'
          ? 'La fuente no pudo procesar la respuesta. Revisa su compatibilidad.'
          : error.toString().substring(
              0,
              error.toString().length.clamp(0, 700),
            );
      message = 'Falló ${item.package.name}. Se conserva la base.';
      if (item.failures >= 3) item.enabled = false;
      return null;
    } finally {
      item.lastMs = watch.elapsedMilliseconds;
      _running = null;
      if (!_disposed) {
        try {
          await persist();
        } catch (_) {
          message = 'No se pudo guardar el estado de recuperación.';
        }
        _notify();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
