void validateJavascriptView(dynamic root) {
  var count = 0;
  final ids = <String>{};
  void visit(dynamic node, int depth) {
    if (node is! Map ||
        depth > 12 ||
        ++count > 200 ||
        ![
          'column',
          'row',
          'card',
          'text',
          'button',
          'input',
          'divider',
        ].contains(node['type'])) {
      throw const FormatException('Árbol visual inválido o demasiado grande.');
    }
    for (final field in ['text', 'label', 'value', 'title']) {
      if (node[field] != null &&
          (node[field] is! String || (node[field] as String).length > 2000)) {
        throw const FormatException('Texto visual incompatible.');
      }
    }
    if (node['color'] != null &&
        (node['color'] is! String ||
            !RegExp(r'^#[a-fA-F0-9]{6}$').hasMatch(node['color'] as String))) {
      throw const FormatException('Color visual incompatible.');
    }
    if (node['type'] == 'input') {
      final id = node['id'];
      if (id is! String ||
          !RegExp(r'^[a-zA-Z0-9_.-]{1,80}$').hasMatch(id) ||
          !ids.add(id) ||
          ids.length > 20) {
        throw const FormatException('Identificador de campo inválido.');
      }
    }
    if (node['type'] == 'button' &&
        (node['action'] is! String ||
            (node['action'] as String).isEmpty ||
            (node['action'] as String).length > 160)) {
      throw const FormatException('Acción visual inválida.');
    }
    if (['column', 'row', 'card'].contains(node['type'])) {
      final children = node['children'];
      if (children is! List || children.length > 100) {
        throw const FormatException('Contenedor incompatible.');
      }
      for (final child in children) {
        visit(child, depth + 1);
      }
    }
  }

  visit(root, 0);
}
