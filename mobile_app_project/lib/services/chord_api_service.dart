import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chord_voicing.dart';
import 'database_service.dart';

/// Wraps lookups against the Uberchord API (https://api.uberchord.com/v1) —
/// a free, no-auth-required chord-diagram lookup service. Given a chord
/// name like "E5" or "Bmaj7", it returns one or more playable voicings
/// (fret positions + fingering).
///
/// NOTE: Uberchord's chord-name grammar is root,quality,tension,bass
/// (e.g. E7#5#9 as a chord with no explicit bass note is written
/// "E,,7#5#9"). The converter below is a best-effort mapping from plain
/// chord names (the kind stored in Song.chordsUsed) to that grammar —
/// common cases (E, Em, E5, E7, Emaj7, E/G#) are covered, but obscure
/// chord spellings may need adjustment once tested against real results.
class ChordApiService {
  ChordApiService._();

  static const _baseUrl = 'https://api.uberchord.com/v1/chords';

  /// Fetches voicings for a chord, using the Realtime Database cache
  /// first so the same chord isn't re-fetched from Uberchord on every
  /// song that uses it.
  static Future<List<ChordVoicing>> fetchVoicings(String chordName) async {
    final cached = await DatabaseService.getCachedChordVoicings(chordName);
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final uberchordName = _toUberchordFormat(chordName);
      final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(uberchordName)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];

      final voicings = decoded
          .whereType<Map<String, dynamic>>()
          .map((m) => ChordVoicing.fromMap(m))
          .toList();

      if (voicings.isNotEmpty) {
        // Fire-and-forget cache write — don't block the UI on it.
        unawaited(DatabaseService.cacheChordVoicings(chordName, voicings));
      }

      return voicings;
    } catch (_) {
      // Network error, timeout, or malformed response — caller shows a
      // "couldn't load diagram" state rather than crashing.
      return [];
    }
  }

  /// Converts a plain chord name (e.g. "Em7", "C#m", "A/C#") into
  /// Uberchord's root,quality,tension,bass comma format.
  static String _toUberchordFormat(String chordName) {
    String name = chordName.trim();

    // Split off a slash bass note, if present (e.g. "A/C#" -> bass "C#").
    String bass = '';
    final slashIndex = name.indexOf('/');
    if (slashIndex != -1) {
      bass = name.substring(slashIndex + 1);
      name = name.substring(0, slashIndex);
    }

    // Root is the first letter plus an optional '#' or lowercase 'b'.
    if (name.isEmpty) return chordName;
    String root = name.substring(0, 1).toUpperCase();
    String rest = name.substring(1);
    if (rest.startsWith('#') || rest.startsWith('b')) {
      root += rest.substring(0, 1);
      rest = rest.substring(1);
    }

    // Quality: "m" (minor) only when it's not the start of "maj".
    String quality = '';
    if (rest.startsWith('m') && !rest.startsWith('maj')) {
      quality = 'm';
      rest = rest.substring(1);
    }

    final tension = rest;

    return '$root,$quality,$tension,$bass';
  }
}
