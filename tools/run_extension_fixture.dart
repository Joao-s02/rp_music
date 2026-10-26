import 'dart:convert';
import 'dart:io';

import 'package:rp_music/extensions/program_runtime.dart';

Future<void> main(List<String> args) async {
  final package = jsonDecode(await File(args[0]).readAsString()) as Map;
  final input = Map<String, dynamic>.from(
    jsonDecode(await File(args[1]).readAsString()) as Map,
  );
  stdout.writeln(
    jsonEncode(
      await ProgramRuntime().execute(package['source'] as String, input),
    ),
  );
}
