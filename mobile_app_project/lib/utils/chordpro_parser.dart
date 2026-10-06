/// Parses ChordPro-style lines like:
///   "[E5]Back in black, [B5]I hit the sack"
/// into a sequence of segments, each pairing an optional chord with the
/// lyric text that follows it, so a UI can render the chord directly
/// above the syllable it falls on.

class ChordLyricSegment {
  final String? chord; // null when this segment has no chord above it
  final String text;

  const ChordLyricSegment({this.chord, required this.text});
}

class ChordProParser {
  ChordProParser._();

  static final RegExp _chordPattern = RegExp(r'\[([^\]]+)\]');

  /// Parses a single ChordPro line into alternating chord/text segments.
  /// A line with no chord markers returns one segment with chord: null.
  static List<ChordLyricSegment> parseLine(String line) {
    final segments = <ChordLyricSegment>[];
    int cursor = 0;

    for (final match in _chordPattern.allMatches(line)) {
      // Text before this chord marker (if any) belongs to the previous chord.
      if (match.start > cursor) {
        final precedingText = line.substring(cursor, match.start);
        if (segments.isNotEmpty) {
          segments[segments.length - 1] = ChordLyricSegment(
            chord: segments.last.chord,
            text: segments.last.text + precedingText,
          );
        } else if (precedingText.trim().isNotEmpty || precedingText.isNotEmpty) {
          segments.add(ChordLyricSegment(chord: null, text: precedingText));
        }
      }

      final chord = match.group(1)!;
      cursor = match.end;

      // Find where this chord's lyric text ends — either the next marker
      // or the end of the line.
      final nextMatch = _chordPattern.firstMatch(line.substring(cursor));
      final textEnd = nextMatch != null ? cursor + nextMatch.start : line.length;
      final text = line.substring(cursor, textEnd);

      segments.add(ChordLyricSegment(chord: chord, text: text));
      cursor = textEnd;
    }

    // No chord markers at all — plain lyric line.
    if (segments.isEmpty) {
      return [ChordLyricSegment(chord: null, text: line)];
    }

    return segments;
  }

  /// Parses every line in a song, in order.
  static List<List<ChordLyricSegment>> parseLines(List<String> lines) {
    return lines.map(parseLine).toList();
  }
}
