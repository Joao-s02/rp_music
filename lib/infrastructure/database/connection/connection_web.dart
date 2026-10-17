import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

DatabaseConnection connectDatabase({required String name, bool inMemory = false}) {
  return DatabaseConnection.delayed(() async {
    final result = await WasmDatabase.open(
      databaseName: name,
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
      initializeDatabase: () async => null,
    );
    return DatabaseConnection(result.resolvedExecutor);
  }());
}
