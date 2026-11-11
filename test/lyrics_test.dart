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
  test('LRC reconoce voces antes o después de las marcas', () {
    final lyrics = Lyrics.parse(
      'v1: [00:01.00]Una voz\n'
      '[00:02.00] v2: <00:02.00>Otra <00:02.50>voz\n'
      '[00:03.00]<00:03.00>V3: Tercera voz\n'
      '[00:04.00]Sonido v2: en mitad de la frase',
    );
    expect(lyrics.lines.map((line) => line.voice), [1, 2, 3, null]);
    expect(lyrics.lines.map((line) => line.rightAligned), [
      false,
      true,
      false,
      false,
    ]);
    expect(lyrics.lines.map((line) => line.text), [
      'Una voz',
      'Otra voz',
      'Tercera voz',
      'Sonido v2: en mitad de la frase',
    ]);
    expect(lyrics.lines[1].words.map((word) => word.time.inMilliseconds), [
      2000,
      2500,
    ]);
    expect(lyrics.lines[2].words.single.text, 'Tercera voz');
  });
  test('texto sin marcas no se presenta sincronizado y limita tamaño', () {
    final lyrics = Lyrics.parse('Uno\nDos');
    expect(lyrics.lines, isEmpty);
    expect(lyrics.plain, 'Uno\nDos');
    expect(() => Lyrics.parse('a' * 262145), throwsFormatException);
    expect(Lyrics.parse('[00:60]Inválido').lines, isEmpty);
  });
}
