import 'package:drift/drift.dart';

DatabaseConnection connectDatabase({required String name, bool inMemory = false}) {
  throw UnsupportedError('No suitable database implementation was found for this platform.');
}
