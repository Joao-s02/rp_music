import 'dart:convert';
String run(String request) {
  final Map<String,dynamic> input = jsonDecode(request) as Map<String,dynamic>;
  final String query = (input['query'] as String).trim();
  return jsonEncode(<String,dynamic>{'provider':'youtube-music','query':query});
}
