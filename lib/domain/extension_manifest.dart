/// Version 1 supports data only, never arbitrary executable code.
class ExtensionManifest {
  const ExtensionManifest({
    required this.id,
    required this.name,
    required this.description,
    required this.layout,
    required this.accent,
    required this.randomAction,
  });
  final String id;
  final String name;
  final String description;
  final String layout;
  final int accent;
  final bool randomAction;
  factory ExtensionManifest.parse(Map<String, dynamic> json) {
    if (json['apiVersion'] != 1) {
      throw const FormatException('Versión de extensión no compatible.');
    }
    final id = json['id'];
    final name = json['name'];
    final screen = json['screen'];
    if (id is! String ||
        !RegExp(r'^[a-z0-9]+([.-][a-z0-9]+)*$').hasMatch(id) ||
        id.length > 100 ||
        name is! String ||
        name.trim().isEmpty ||
        name.length > 80 ||
        screen is! Map ||
        !['list', 'cards'].contains(screen['layout'])) {
      throw const FormatException(
        'Identidad o pantalla de extensión inválida.',
      );
    }
    final permissions = json['permissions'];
    if (permissions is! List || permissions.isNotEmpty) {
      throw const FormatException(
        'Esta prueba solo admite extensiones sin permisos.',
      );
    }
    final color = screen['accent'];
    if (color is! String || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(color)) {
      throw const FormatException('El color debe tener formato #RRGGBB.');
    }
    final actions = json['actions'];
    if (actions is! List || actions.any((a) => a != 'playRandom')) {
      throw const FormatException(
        'La extensión solicita acciones no compatibles.',
      );
    }
    final description = json['description'];
    if (description is! String || description.length > 500) {
      throw const FormatException('Descripción inválida.');
    }
    return ExtensionManifest(
      id: id,
      name: name.trim(),
      description: description,
      layout: screen['layout'] as String,
      accent: 0xff000000 | int.parse(color.substring(1), radix: 16),
      randomAction: actions.contains('playRandom'),
    );
  }
  Map<String, dynamic> toJson() => {
    'apiVersion': 1,
    'id': id,
    'name': name,
    'description': description,
    'permissions': <String>[],
    'screen': {
      'layout': layout,
      'accent': '#${(accent & 0xffffff).toRadixString(16).padLeft(6, '0')}',
    },
    'actions': [if (randomAction) 'playRandom'],
  };
}
