import 'dart:convert';

class LyricLine {
  const LyricLine(this.time, this.text);
  final Duration time;
  final String text;
}

class Lyrics {
  Lyrics(this.lines, this.plain);
  final List<LyricLine> lines;
  final String plain;
  factory Lyrics.parse(String text) {
    if (text.length > 262144 || utf8.encode(text).length > 262144) {
      throw const FormatException('Letra demasiado grande.');
    }
    final lines = <LyricLine>[];
    final stamp = RegExp(r'\[(\d{1,3}):([0-5]\d)(?:[.:](\d{1,3}))?\]');
    final offsetMatch = RegExp(
      r'\[offset:([+-]?\d+)\]',
      caseSensitive: false,
    ).firstMatch(text);
    final offset = int.tryParse(offsetMatch?.group(1) ?? '') ?? 0;
    for (final row in text.split(RegExp(r'\r?\n'))) {
      final matches = stamp.allMatches(row).toList();
      if (matches.isEmpty) continue;
      final words = row.substring(matches.last.end).trim();
      for (final match in matches) {
        final fraction = (match.group(3) ?? '').padRight(3, '0');
        final ms =
            int.parse(match.group(1)!) * 60000 +
            int.parse(match.group(2)!) * 1000 +
            int.parse(fraction) +
            offset;
        lines.add(LyricLine(Duration(milliseconds: ms < 0 ? 0 : ms), words));
      }
    }
    lines.sort((a, b) => a.time.compareTo(b.time));
    return Lyrics(lines, text.trim());
  }
  int activeAt(Duration position) {
    var low = 0;
    var high = lines.length;
    while (low < high) {
      final mid = (low + high) ~/ 2;
      if (lines[mid].time <= position) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low - 1;
  }
}
