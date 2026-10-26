// Separate AOT verification entry. Never distribute as the app.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_catalog.dart';
import 'package:rp_music/extensions/program_runtime.dart';
import 'package:rp_music/extensions/program_snapshot.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: Text('Comprobación de extensiones'))),
    ),
  );
  final report = <String, dynamic>{'ok': false};
  Directory? directory;
  ProgramController? programs;
  try {
    directory = await Directory.systemTemp.createTemp('rp_program_probe_');
    programs = ProgramController(LocalStore(directory, baseName: 'extensions'));
    // Esta sonda consulta el repositorio; los paquetes ya no vienen en el APK.
    final catalog = await ProgramCatalog.load(
      'https://github.com/Joao-s02/rp-music-extensions',
    );
    for (final entry in catalog.entries) {
      final package = await catalog.download(entry);
      await programs.install(package, package.permissions);
    }
    final snapshot = ProgramSnapshot(
      [
        const Track(
          id: 'synthetic-a',
          title: 'A',
          artist: 'Uno',
          album: 'Álbum',
          folder: 'Rock',
          durationMs: 120000,
        ),
        const Track(
          id: 'synthetic-b',
          title: 'B',
          artist: 'Dos',
          album: 'Otro',
          folder: 'Pop',
          durationMs: 240000,
        ),
      ],
      {'synthetic-a'},
    );
    final result = await programs.invoke('rp.biblioteca-viva', 'library', {
      'tracks': snapshot.rows,
      'filters': {'favorites': true},
    });
    if (result == null ||
        snapshot.resolve(result['ids']).single.id != 'synthetic-a') {
      throw StateError(
        programs.installed['rp.biblioteca-viva']?.error ?? 'Filtro incorrecto',
      );
    }
    final shuffle = await programs.invoke('rp.pulso-nocturno', 'shuffle', {
      'tracks': snapshot.rows,
      'current': snapshot.idFor('synthetic-a'),
      'seed': 3,
    });
    if (snapshot.byId[shuffle?['next']]?.id != 'synthetic-b') {
      throw StateError('Aleatorio incorrecto');
    }
    final player = await programs.invoke('rp.pulso-nocturno', 'player', {
      'title': 'A',
    });
    if (player?['layout'] != 'controlsFirst') {
      throw StateError('Diseño incorrecto');
    }
    var killed = false;
    try {
      await ProgramRuntime().execute(
        'String run(String input) { while(true) {} return input; }',
        {},
        timeout: const Duration(milliseconds: 150),
      );
    } on FormatException {
      killed = true;
    }
    if (!killed) throw StateError('No terminó el bucle');
    report.addAll({
      'ok': true,
      'library': true,
      'shuffle': true,
      'player': true,
      'timeout': true,
      'installed': programs.installed.length,
    });
  } catch (error, stack) {
    report['error'] = error.toString();
    report['stack'] = stack.toString();
  } finally {
    programs?.dispose();
    if (directory != null) await directory.delete(recursive: true);
  }
  final encoded = jsonEncode(report);
  // ignore: avoid_print
  print('RP_PROGRAM_PROBE $encoded');
  if (Platform.isWindows) {
    await File('build/program-release-probe.json')
        .writeAsString(encoded, flush: true);
    exit(report['ok'] == true ? 0 : 1);
  } else {
    await Future<void>.delayed(const Duration(seconds: 1));
    await SystemNavigator.pop();
  }
}
