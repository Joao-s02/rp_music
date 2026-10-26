// Explicit concatenation keeps this sample within the tested dart_eval subset.
// ignore_for_file: prefer_interpolation_to_compose_strings
import 'dart:convert';

String field(Map<String, dynamic> object, String key) {
  if (object[key] == null) {
    return '';
  }
  final String value = object[key] as String;
  return value;
}

// This function is compiled by RP Music after importing the package.
// It is ordinary Dart logic, not a predefined host filter action.
String run(String request) {
  final Map<String, dynamic> input =
      jsonDecode(request) as Map<String, dynamic>;
  final List<dynamic> tracks = input['tracks'] as List<dynamic>;
  final Map<String, dynamic> filters = input['filters'] == null
      ? <String, dynamic>{}
      : input['filters'] as Map<String, dynamic>;
  final List<String> ids = <String>[];
  final String query = field(filters, 'query').toLowerCase();
  final int maxSeconds = filters['maxSeconds'] == null
      ? 0
      : filters['maxSeconds'] as int;
  for (int i = 0; i < tracks.length; i = i + 1) {
    final Map<String, dynamic> track = tracks[i] as Map<String, dynamic>;
    bool keep = true;
    if (field(filters, 'artist') != '' &&
        field(filters, 'artist') != field(track, 'artist')) {
      keep = false;
    }
    if (field(filters, 'album') != '' &&
        field(filters, 'album') != field(track, 'album')) {
      keep = false;
    }
    if (field(filters, 'folder') != '' &&
        field(filters, 'folder') != field(track, 'folder')) {
      keep = false;
    }
    if (filters['favorites'] == true && track['favorite'] != true) keep = false;
    final int duration = track['durationMs'] as int;
    if (maxSeconds > 0 && (duration <= 0 || duration > maxSeconds * 1000)) {
      keep = false;
    }
    final String text =
        (field(track, 'title') +
                ' ' +
                field(track, 'artist') +
                ' ' +
                field(track, 'album') +
                ' ' +
                field(track, 'folder'))
            .toLowerCase();
    if (query != '' && !text.contains(query)) keep = false;
    if (keep) ids.add(track['id'] as String);
  }
  final Map<String, dynamic> response = <String, dynamic>{
    'title': 'Biblioteca viva',
    'description': 'Filtros ejecutados por esta extensión Dart. Guarda una lista automática para mantener tus resultados al actualizar el catálogo.',
    'layout': 'cards',
    'ids': ids,
  };
  if (input['event'] == 'library') {
    response['state'] = <String, dynamic>{'filters': filters};
  }
  return jsonEncode(response);
}
