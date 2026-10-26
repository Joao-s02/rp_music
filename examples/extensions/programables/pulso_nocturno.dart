import 'dart:convert';

String run(String request) {
  final Map<String, dynamic> input =
      jsonDecode(request) as Map<String, dynamic>;
  if (input['event'] == 'player') {
    return jsonEncode(<String, dynamic>{
      'title': 'Pulso nocturno',
      'layout': 'controlsFirst',
    });
  }
  final List<dynamic> tracks = input['tracks'] as List<dynamic>;
  final String current = input['current'] == null
      ? ''
      : input['current'] as String;
  String artist = '';
  for (int i = 0; i < tracks.length; i = i + 1) {
    final Map<String, dynamic> track = tracks[i] as Map<String, dynamic>;
    if (track['id'] == current) artist = track['artist'] as String;
  }
  final List<String> candidates = <String>[];
  for (int i = 0; i < tracks.length; i = i + 1) {
    final Map<String, dynamic> track = tracks[i] as Map<String, dynamic>;
    if (track['id'] != current && track['artist'] != artist) {
      candidates.add(track['id'] as String);
    }
  }
  if (candidates.isEmpty) {
    for (int i = 0; i < tracks.length; i = i + 1) {
      final Map<String, dynamic> track = tracks[i] as Map<String, dynamic>;
      if (track['id'] != current || tracks.length == 1) {
        candidates.add(track['id'] as String);
      }
    }
  }
  final int seed = input['seed'] == null ? 0 : input['seed'] as int;
  return jsonEncode(<String, dynamic>{
    'next': candidates.isEmpty ? '' : candidates[seed % candidates.length],
  });
}
