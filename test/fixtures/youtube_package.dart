const youtubePackageJson = r'''{
  "apiVersion": 2,
  "id": "rp.youtube-music",
  "name": "YouTube Music experimental",
  "version": "0.1.0",
  "description": "Busca canciones y reproduce audio sin cuenta. Primera prueba para Android con RP Music 0.3.1 o superior.",
  "permissions": [
    "network.youtube",
    "playback.control"
  ],
  "capabilities": [
    "source"
  ],
  "source": "import 'dart:convert';\nString run(String request) {\n  final Map<String,dynamic> input = jsonDecode(request) as Map<String,dynamic>;\n  final String query = (input['query'] as String).trim();\n  return jsonEncode(<String,dynamic>{'provider':'youtube-music','query':query});\n}\n"
}
''';
