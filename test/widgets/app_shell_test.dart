import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rp_music/app/app.dart';
import 'package:rp_music/bootstrap/composition_root.dart';
import 'package:rp_music/infrastructure/database/app_database.dart';
import 'package:drift/native.dart';

void main() {
  testWidgets('MusicPlayerApp renders main shell with navigation and playback bar', (tester) async {
    final inMemoryDb = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(inMemoryDb),
        ],
        child: const MusicPlayerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Library'), findsWidgets);
    expect(find.text('No audio tracks in library'), findsOneWidget);
    expect(find.text('No Track Playing'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    await inMemoryDb.close();
  });
}
