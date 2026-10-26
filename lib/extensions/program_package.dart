import 'dart:convert';

const programPermissions = {
  'library.read': 'Leer metadatos de la biblioteca y favoritos',
  'playback.control': 'Controlar la reproducción',
  'playlists.manage': 'Crear y actualizar listas de la app',
  'storage.private': 'Guardar preferencias propias',
  'behavior.override': 'Sustituir funciones base (nivel avanzado)',
};
const programSlots = {
  'library': 'Biblioteca',
  'player': 'Reproductor ampliado',
  'shuffle': 'Aleatorio',
  'lists': 'Reglas de listas',
};

class ProgramPackage {
  ProgramPackage(
    this.id,
    this.name,
    this.version,
    this.description,
    this.source,
    this.permissions,
    this.slots,
    this.advanced,
  );
  final String id, name, version, description, source;
  final Set<String> permissions, slots;
  final bool advanced;
  factory ProgramPackage.parse(Map<String, dynamic> json) {
    String text(String key, int max) {
      final value = json[key];
      if (value is! String ||
          value.trim().isEmpty ||
          utf8.encode(value).length > max) {
        throw FormatException('Campo $key inválido.');
      }
      return value;
    }

    if (json['apiVersion'] != 2) {
      throw const FormatException(
        'Se requiere API 2 de extensiones programables.',
      );
    }
    final id = text('id', 100);
    if (!RegExp(r'^[a-z0-9]+([.-][a-z0-9]+)*$').hasMatch(id)) {
      throw const FormatException('Identificador inválido.');
    }
    final version = text('version', 40);
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) {
      throw const FormatException('Versión de paquete inválida.');
    }
    Set<String> values(String key, Set<String> allowed) {
      final value = json[key];
      if (value is! List ||
          value.isEmpty ||
          value.any((item) => item is! String || !allowed.contains(item))) {
        throw FormatException('$key no compatible con esta versión.');
      }
      return value.cast<String>().toSet();
    }

    final permissions = values('permissions', programPermissions.keys.toSet());
    final slots = values('capabilities', programSlots.keys.toSet());
    final level = json['level'] ?? 'standard';
    if (!['standard', 'advanced'].contains(level)) {
      throw const FormatException('Nivel no compatible.');
    }
    final advanced = level == 'advanced';
    if ((slots.contains('player') || slots.contains('shuffle')) && !advanced) {
      throw const FormatException(
        'Sustituir reproductor o aleatorio requiere nivel avanzado.',
      );
    }
    if (advanced && !permissions.contains('behavior.override')) {
      throw const FormatException(
        'El nivel avanzado requiere aceptar behavior.override.',
      );
    }
    if ((slots.contains('library') ||
            slots.contains('lists') ||
            slots.contains('shuffle')) &&
        !permissions.contains('library.read')) {
      throw const FormatException('Esta capacidad requiere library.read.');
    }
    if (slots.contains('lists') && !permissions.contains('playlists.manage')) {
      throw const FormatException('Las reglas requieren playlists.manage.');
    }
    if ((slots.contains('player') || slots.contains('shuffle')) &&
        !permissions.contains('playback.control')) {
      throw const FormatException('Esta capacidad requiere playback.control.');
    }
    return ProgramPackage(
      id,
      text('name', 80),
      version,
      text('description', 500),
      text('source', 65536),
      permissions,
      slots,
      advanced,
    );
  }
  Map<String, dynamic> toJson() => {
    'apiVersion': 2,
    'level': advanced ? 'advanced' : 'standard',
    'id': id,
    'name': name,
    'version': version,
    'description': description,
    'source': source,
    'permissions': permissions.toList(),
    'capabilities': slots.toList(),
  };
}

class InstalledProgram {
  InstalledProgram(
    this.package,
    this.grants, {
    this.enabled = false,
    this.failures = 0,
    this.lastMs = 0,
  });
  final ProgramPackage package;
  Set<String> grants;
  bool enabled;
  int failures, lastMs;
  String? error;
  bool get authorized => grants.containsAll(package.permissions);
  Map<String, dynamic> toJson() => {
    'package': package.toJson(),
    'grants': grants.toList(),
    'enabled': enabled,
    'failures': failures,
  };
}
