import 'package:firebase_database/firebase_database.dart';
import '../models/user_profile.dart';
import '../models/song.dart';
import '../models/chord_voicing.dart';

/// Wraps all Realtime Database reads/writes for Chord Nerd outside of
/// auth/profile bootstrap (which auth_service.dart already handles).
class DatabaseService {
  DatabaseService._();

  static final FirebaseDatabase _db = FirebaseDatabase.instance;

  // ---------------------------------------------------------------------
  // Profile / dashboard stats
  // ---------------------------------------------------------------------

  /// Live stream of the signed-in user's profile — drives Dashboard's
  /// stats, streak, and weekly chart, and Profile's stat cards.
  static Stream<UserProfile?> watchUserProfile(String uid) {
    return _db.ref('users/$uid').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return null;
      return UserProfile.fromMap(uid, data as Map<dynamic, dynamic>);
    });
  }

  /// Call when a practice session ends. Adds minutes to today's weekday
  /// bucket and to the running total, and bumps the streak by 1 (simple
  /// MVP version — doesn't yet check for missed days resetting it).
  static Future<void> logPracticeSession({
    required String uid,
    required int minutes,
  }) async {
    final ref = _db.ref('users/$uid');
    final todayKey = _weekdayKey(DateTime.now().weekday);

    final snapshot = await ref.get();
    final current = snapshot.value as Map<dynamic, dynamic>? ?? {};
    final currentWeekly = (current['weeklyMinutes'] as Map?) ?? {};
    final currentHours = (current['totalPracticeHours'] as num?)?.toDouble() ?? 0;
    final currentStreak = (current['currentStreak'] as num?)?.toInt() ?? 0;

    final updatedMinutesToday = ((currentWeekly[todayKey] as num?)?.toInt() ?? 0) + minutes;

    await ref.update({
      'weeklyMinutes/$todayKey': updatedMinutesToday,
      'totalPracticeHours': currentHours + (minutes / 60),
      'currentStreak': currentStreak + 1,
    });
  }

  static String _weekdayKey(int weekday) {
    const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return keys[weekday - 1]; // DateTime.weekday is 1=Mon..7=Sun
  }

  // ---------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------

  /// One-shot search across songs/{songId} by title (client-side filter —
  /// fine for a small catalog; swap for indexed queries once it grows).
  static Future<List<Song>> searchSongs(String query) async {
    final snapshot = await _db.ref('songs').get();
    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    final all = data.entries
        .map((e) => Song.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>))
        .toList();

    if (query.trim().isEmpty) return all;

    final lower = query.toLowerCase();
    return all
        .where((s) => s.title.toLowerCase().contains(lower) || s.artist.toLowerCase().contains(lower))
        .toList();
  }

  /// Fetches a single song by its id — used when opening Song Detail from
  /// Library, where only the lighter LibraryEntry (title/artist/status) is
  /// on hand, not the full chord/lyric data.
  static Future<Song?> getSongById(String songId) async {
    final snapshot = await _db.ref('songs/$songId').get();
    if (!snapshot.exists) return null;
    return Song.fromMap(songId, snapshot.value as Map<dynamic, dynamic>);
  }

  // ---------------------------------------------------------------------
  // Library
  // ---------------------------------------------------------------------

  /// Live stream of the signed-in user's saved songs — drives Library.
  static Stream<List<LibraryEntry>> watchLibrary(String uid) {
    return _db.ref('users/$uid/library').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <LibraryEntry>[];
      final map = data as Map<dynamic, dynamic>;
      return map.entries
          .map((e) => LibraryEntry.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>))
          .toList();
    });
  }

  /// Saves a song to the signed-in user's library (called from Search or
  /// Song Detail). Also bumps songsLearned count on the profile if this
  /// is a brand-new save.
  static Future<void> saveToLibrary({
    required String uid,
    required Song song,
  }) async {
    await _db.ref('users/$uid/library/${song.id}').set({
      'title': song.title,
      'artist': song.artist,
      'isMastered': false,
    });
  }

  static Future<void> setMastered({
    required String uid,
    required String songId,
    required bool isMastered,
  }) async {
    await _db.ref('users/$uid/library/$songId/isMastered').set(isMastered);
  }

  static Future<void> removeFromLibrary({
    required String uid,
    required String songId,
  }) async {
    await _db.ref('users/$uid/library/$songId').remove();
  }

  // ---------------------------------------------------------------------
  // Chord diagram cache — avoids re-hitting Uberchord for the same chord
  // every time it appears (a chord like "E5" shows up in dozens of songs).
  // ---------------------------------------------------------------------

  /// Realtime Database keys can't contain '.', '#', '$', '[', ']', so a
  /// chord name like "C#m7" needs its symbols swapped out before use as
  /// a path segment.
  static String _chordCacheKey(String chordName) {
    return chordName
        .replaceAll('#', 'sharp')
        .replaceAll('.', 'dot')
        .replaceAll(r'$', 'dollar')
        .replaceAll('[', '(')
        .replaceAll(']', ')')
        .replaceAll('/', '_over_');
  }

  static Future<List<ChordVoicing>?> getCachedChordVoicings(String chordName) async {
    final snapshot = await _db.ref('chordDiagrams/${_chordCacheKey(chordName)}').get();
    if (!snapshot.exists) return null;

    final data = snapshot.value;
    if (data is! List) return null;

    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => ChordVoicing.fromMap(m))
        .toList();
  }

  static Future<void> cacheChordVoicings(String chordName, List<ChordVoicing> voicings) async {
    await _db.ref('chordDiagrams/${_chordCacheKey(chordName)}').set(
          voicings.map((v) => v.toMap()).toList(),
        );
  }
}
