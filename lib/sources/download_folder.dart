import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class DownloadFolder {
  static const _channel = MethodChannel('rp_music/library');
  static Future<String?>? _selection;
  static Future<void> _writes = Future.value();

  static Future<String?> choose({bool change = false}) async {
    final pending = _selection;
    if (pending != null) return pending;
    final selection = _select(change);
    _selection = selection;
    try {
      return await selection;
    } finally {
      _selection = null;
    }
  }

  static Future<String?> _select(bool change) async {
    if (Platform.isAndroid) {
      if (!change) {
        final saved = await _channel.invokeMethod<String>(
          'savedDownloadFolder',
        );
        if (saved != null) return saved;
      }
      return _channel.invokeMethod<String>('chooseDownloadFolder');
    }

    final support = await getApplicationSupportDirectory();
    final setting = File('${support.path}/download-folder.txt');
    if (!change && await setting.exists()) {
      final saved = await setting.readAsString();
      if (saved.isNotEmpty && await Directory(saved).exists()) return saved;
    }
    final selected = await FilePicker.getDirectoryPath(
      dialogTitle: 'Carpeta de descargas',
    );
    if (selected != null) {
      await support.create(recursive: true);
      await setting.writeAsString(selected, flush: true);
    }
    return selected;
  }

  static Future<bool> write(
    String folder, {
    required String name,
    required String mime,
    required Uint8List bytes,
    File? file,
    required bool Function() cancelled,
  }) {
    final operation = _writes.then((_) async {
      if (cancelled()) return false;
      if (Platform.isAndroid) {
        await _channel.invokeMethod<String>('writeDownload', {
          'folder': folder,
          'name': name,
          'mime': mime,
          if (file != null) 'path': file.path else 'bytes': bytes,
        });
        return true;
      }

      final dot = name.lastIndexOf('.');
      var target = File('$folder/$name');
      var suffix = 1;
      while (await FileSystemEntity.type(target.path) !=
          FileSystemEntityType.notFound) {
        target = File(
          '$folder/${name.substring(0, dot)} (${suffix++})${name.substring(dot)}',
        );
      }
      final temp = await Directory(folder).createTemp('.rp_download_');
      try {
        final staging = File('${temp.path}/audio.part');
        if (file != null) {
          await file.copy(staging.path);
        } else {
          await staging.writeAsBytes(bytes, flush: true);
        }
        if (cancelled()) return false;
        await staging.rename(target.path);
        return true;
      } finally {
        await temp.delete(recursive: true);
      }
    });
    _writes = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }
}
