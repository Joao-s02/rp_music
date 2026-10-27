class SourceSpec {
  SourceSpec(
    this.name,
    this.domains,
    this.platforms,
    this.navigationLabel,
    this.icon,
    this.color, {
    this.description = 'Canciones · sin cuenta. Reproducción en línea; requiere conexión. Algunas canciones pueden no estar disponibles.',
    this.searchLabel = 'Buscar canciones',
  });
  final String name;
  final String description, searchLabel;
  final List<String> domains, platforms;
  final String? navigationLabel;
  final String icon;
  final int color;
  bool permits(Uri uri) =>
      uri.scheme == 'https' &&
      uri.userInfo.isEmpty &&
      !uri.hasPort &&
      domains.any(
        (domain) => domain.startsWith('*.')
            ? uri.host.endsWith(domain.substring(1))
            : uri.host == domain,
      );
  factory SourceSpec.parse(dynamic raw) {
    if (raw is! Map) {
      throw const FormatException('Configuración de fuente inválida.');
    }
    final name = raw['name'];
    final domains = raw['domains'];
    final platforms = raw['platforms'];
    final nav = raw['navigation'];
    if (name is! String ||
        name.trim().isEmpty ||
        name.length > 60 ||
        domains is! List ||
        domains.isEmpty ||
        domains.length > 8 ||
        platforms is! List ||
        platforms.isEmpty ||
        platforms.any((p) => !['android', 'windows'].contains(p))) {
      throw const FormatException('Fuente incompatible.');
    }
    for (final d in domains) {
      if (d is! String ||
          !RegExp(r'^(\*\.)?[a-z0-9-]+(\.[a-z0-9-]+)+$').hasMatch(d) ||
          d.contains('localhost') ||
          RegExp(r'^[0-9.]+$').hasMatch(d) ||
          d.endsWith('.local')) {
        throw const FormatException('Dominio no permitido.');
      }
    }
    String? label;
    var icon = 'cloud';
    var color = 0xff00bfb3;
    if (nav != null) {
      if (nav is! Map ||
          nav['label'] is! String ||
          (nav['label'] as String).trim().isEmpty ||
          (nav['label'] as String).length > 14) {
        throw const FormatException('Acceso de navegación inválido.');
      }
      label = nav['label'] as String;
      icon = nav['icon'] as String? ?? 'cloud';
      if (![
        'cloud',
        'music',
        'playBadge',
        'playOutline',
        'headphones',
      ].contains(icon)) {
        throw const FormatException('Icono no compatible.');
      }
      final hex = nav['color'];
      if (hex != null) {
        if (hex is! String || !RegExp(r'^#[a-fA-F0-9]{6}$').hasMatch(hex)) {
          throw const FormatException('Color inválido.');
        }
        color = 0xff000000 | int.parse(hex.substring(1), radix: 16);
      }
    }
    final description = raw['description'];
    final searchLabel = raw['searchLabel'];
    if ((description != null &&
            (description is! String || description.length > 400)) ||
        (searchLabel != null &&
            (searchLabel is! String || searchLabel.length > 80))) {
      throw const FormatException('Texto de fuente inválido.');
    }
    return SourceSpec(
      name,
      domains.cast<String>(),
      platforms.cast<String>(),
      label,
      icon,
      color,
      description: description as String? ?? 'Canciones · sin cuenta. Reproducción en línea; requiere conexión. Algunas canciones pueden no estar disponibles.',
      searchLabel: searchLabel as String? ?? 'Buscar canciones',
    );
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'searchLabel': searchLabel,
    'domains': domains,
    'platforms': platforms,
    if (navigationLabel != null)
      'navigation': {
        'label': navigationLabel,
        'icon': icon,
        'color': '#${(color & 0xffffff).toRadixString(16).padLeft(6, '0')}',
      },
  };
}
