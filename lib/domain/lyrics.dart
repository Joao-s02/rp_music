import 'dart:convert';

class LyricLine {
  const LyricLine(
    this.time,
    this.text, {
    this.words = const [],
    this.leadingText = '',
  });
  final Duration time;
  final String text;
  final List<LyricWord> words;
  final String leadingText;
}

class LyricWord {
  const LyricWord(this.time, this.text);
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
      final content = row.substring(matches.last.end).trim();
      final wordStamp = RegExp(r'<(\d{1,3}):([0-5]\d)(?:[.:](\d{1,3}))?>');
      final wordMatches = wordStamp.allMatches(content).toList();
      final words = content.replaceAll(wordStamp, '').trim();
      final timedWords = <LyricWord>[];
      if (matches.length == 1) {
        for (var i = 0; i < wordMatches.length; i++) {
          final mark = wordMatches[i];
          final text = content.substring(
            mark.end,
            i + 1 < wordMatches.length
                ? wordMatches[i + 1].start
                : content.length,
          );
          final ms =
              int.parse(mark.group(1)!) * 60000 +
              int.parse(mark.group(2)!) * 1000 +
              int.parse((mark.group(3) ?? '').padRight(3, '0')) +
              offset;
          if (text.trim().isNotEmpty) {
            timedWords.add(
              LyricWord(Duration(milliseconds: ms < 0 ? 0 : ms), text),
            );
          }
        }
      }
      for (final match in matches) {
        final fraction = (match.group(3) ?? '').padRight(3, '0');
        final ms =
            int.parse(match.group(1)!) * 60000 +
            int.parse(match.group(2)!) * 1000 +
            int.parse(fraction) +
            offset;
        lines.add(
          LyricLine(
            Duration(milliseconds: ms < 0 ? 0 : ms),
            words,
            words: timedWords,
            leadingText: timedWords.isNotEmpty
                ? content.substring(0, wordMatches.first.start)
                : '',
          ),
        );
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
