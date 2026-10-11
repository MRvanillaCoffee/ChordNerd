import '../models/chord_voicing.dart';
import 'database_service.dart';

/// Looks up playable voicings for a chord name, e.g. "E5" or "F#m" — now
/// backed by the chordDiagrams/ path in Realtime Database instead of a
/// bundled asset or the (unreliable) Uberchord API. This means new or
/// corrected chord shapes can be added straight from the Firebase
/// console, same as adding a new song, without an app update.
class ChordApiService {
  ChordApiService._();

  /// Returns the known voicings for [chordName]. Tries the name as given
  /// first, then a common enharmonic respelling of its root (e.g. "A#5"
  /// will also try "Bb5") before giving up and returning an empty list.
  static Future<List<ChordVoicing>> fetchVoicings(String chordName) async {
    final name = chordName.trim();

    final direct = await DatabaseService.getCachedChordVoicings(name);
    if (direct != null && direct.isNotEmpty) return direct;

    final alt = _enharmonicAlt(name);
    if (alt != null) {
      final altResult = await DatabaseService.getCachedChordVoicings(alt);
      if (altResult != null && altResult.isNotEmpty) return altResult;
    }

    return [];
  }

  static const Map<String, String> _sharpToFlat = {
    'A#': 'Bb', 'C#': 'Db', 'D#': 'Eb', 'F#': 'Gb', 'G#': 'Ab',
  };
  static const Map<String, String> _flatToSharp = {
    'Bb': 'A#', 'Db': 'C#', 'Eb': 'D#', 'Gb': 'F#', 'Ab': 'G#',
  };

  /// If [name]'s root starts with a sharp or flat, returns the same chord
  /// respelled on the other side (e.g. "Db5" -> "C#5"). Returns null if
  /// the root isn't accidental.
  static String? _enharmonicAlt(String name) {
    final aliasMap = {..._sharpToFlat, ..._flatToSharp};
    for (final entry in aliasMap.entries) {
      if (name.startsWith(entry.key)) {
        return entry.value + name.substring(entry.key.length);
      }
    }
    return null;
  }
}
