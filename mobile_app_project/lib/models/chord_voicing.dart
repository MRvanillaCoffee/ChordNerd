/// One playable voicing of a chord, as returned by the Uberchord API
/// (or read back from the local Realtime Database cache of it).
class ChordVoicing {
  final String chordName;
  final String strings; // e.g. "X 2 4 4 4 2" — fret per string, low to high, X = muted
  final String fingering; // e.g. "X 1 2 3 4 1" — which finger plays each string
  final String tones; // e.g. "B,D#,F#" — notes that make up the chord

  const ChordVoicing({
    required this.chordName,
    required this.strings,
    required this.fingering,
    required this.tones,
  });

  factory ChordVoicing.fromMap(Map<dynamic, dynamic> map) {
    return ChordVoicing(
      chordName: map['chordName'] as String? ?? '',
      strings: map['strings'] as String? ?? '',
      fingering: map['fingering'] as String? ?? '',
      tones: map['tones'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chordName': chordName,
      'strings': strings,
      'fingering': fingering,
      'tones': tones,
    };
  }

  /// Per-string fret numbers, low (6th/E) to high (1st/e). null = muted (X),
  /// -1 means "couldn't parse".
  List<int?> get fretsPerString {
    return strings.trim().split(RegExp(r'\s+')).map((s) {
      if (s.toUpperCase() == 'X') return null;
      return int.tryParse(s) ?? -1;
    }).toList();
  }
}
