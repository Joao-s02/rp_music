import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/domain/lyrics.dart';

void main() {
  test('LRC fracciones, múltiples marcas, orden y offset', () {
    final lyrics = Lyrics.parse(
      '[offset:-100]\n[00:03.12]B\n[00:01.2][00:02.003]A',
    );
    expect(lyrics.lines.map((e) => e.time.inMilliseconds), [1100, 1903, 3020]);
    expect(lyrics.lines.map((e) => e.text), ['A', 'A', 'B']);
    expect(lyrics.activeAt(const Duration(milliseconds: 1099)), -1);
    expect(lyrics.activeAt(const Duration(milliseconds: 1100)), 0);
    expect(lyrics.activeAt(const Duration(seconds: 4)), 2);
    expect(lyrics.activeAt(const Duration(seconds: 2)), 1);
    expect(lyrics.activeAt(Duration.zero), -1);
  });
  test('texto sin marcas no se presenta sincronizado y limita tamaño', () {
    final lyrics = Lyrics.parse('Uno\nDos');
    expect(lyrics.lines, isEmpty);
    expect(lyrics.plain, 'Uno\nDos');
    expect(() => Lyrics.parse('a' * 262145), throwsFormatException);
    expect(Lyrics.parse('[00:60]Inválido').lines, isEmpty);
  });
}
