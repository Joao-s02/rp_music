import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

DatabaseConnection connectDatabase({required String name, bool inMemory = false}) {
  if (inMemory) {
    return DatabaseConnection(NativeDatabase.memory());
  }

  return DatabaseConnection.delayed(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, '$name.sqlite'));
    return DatabaseConnection(NativeDatabase.createInBackground(file));
  }());
}
