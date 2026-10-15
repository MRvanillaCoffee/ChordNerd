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

  /// Call when a practice session ends with the real elapsed [seconds].
  /// Adds to today's weekday bucket (whole minutes) and the exact time to
  /// the running hours total, and updates the day-based streak.
  static Future<void> logPracticeSession({
    required String uid,
    required int seconds,
  }) async {
    final minutes = (seconds / 60).round(); // for the whole-minute weekly chart
    final ref = _db.ref('users/$uid');
    final now = DateTime.now();
    final todayKey = _weekdayKey(now.weekday);
    final todayDate = UserProfile.dateKey(now);
    final yesterdayDate = UserProfile.dateKey(now.subtract(const Duration(days: 1)));
    final thisWeekStart = UserProfile.dateKey(UserProfile.mondayOf(now));

    final snapshot = await ref.get();
    final current = snapshot.value as Map<dynamic, dynamic>? ?? {};
    final currentHours = (current['totalPracticeHours'] as num?)?.toDouble() ?? 0;
    final currentStreak = (current['currentStreak'] as num?)?.toInt() ?? 0;
    final lastPracticeDate = current['lastPracticeDate'] as String?;
    final storedWeekStart = current['weekStart'] as String?;

    // New week → start the chart from zero instead of carrying over
    // last week's minutes.
    final weekly = <String, int>{};
    if (storedWeekStart == thisWeekStart) {
      ((current['weeklyMinutes'] as Map?) ?? {}).forEach((k, v) {
        weekly[k.toString()] = (v as num).toInt();
      });
    }
    weekly[todayKey] = (weekly[todayKey] ?? 0) + minutes;

    // Streak counts days, not sessions: a second session on the same day
    // keeps it; practicing the day after extends it; any gap restarts at 1.
    int newStreak;
    if (lastPracticeDate == todayDate) {
      newStreak = currentStreak < 1 ? 1 : currentStreak;
    } else if (lastPracticeDate == yesterdayDate) {
      newStreak = currentStreak + 1;
    } else {
      newStreak = 1;
    }

    await ref.update({
      'weeklyMinutes': weekly,
      'weekStart': thisWeekStart,
      'totalPracticeHours': currentHours + (seconds / 3600),
      'currentStreak': newStreak,
      'lastPracticeDate': todayDate,
    });
  }

  static String _weekdayKey(int weekday) {
    const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return keys[weekday - 1]; // DateTime.weekday is 1=Mon..7=Sun
  }

  /// Updates the editable parts of a profile (name, skill level) from the
  /// Edit Profile screen.
  static Future<void> updateProfile({
    required String uid,
    required String name,
    required String skillLevel,
  }) async {
    await _db.ref('users/$uid').update({
      'name': name,
      'skillLevel': skillLevel,
    });
  }

  /// Saves the practice-reminder notification preference from the
  /// Settings screen. [reminderTime] is "HH:mm" 24-hour.
  static Future<void> updateNotificationSettings({
    required String uid,
    required bool reminderEnabled,
    required String reminderTime,
  }) async {
    await _db.ref('users/$uid').update({
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
    });
  }

  /// Stores a new avatar image directly as a base64 string (see
  /// ProfileScreen._changeAvatar, which resizes/compresses the picked
  /// image before calling this) — avoids needing Firebase Storage, which
  /// requires the paid Blaze plan just to enable.
  static Future<void> updateAvatarImage({
    required String uid,
    required String avatarBase64,
  }) async {
    await _db.ref('users/$uid/avatarBase64').set(avatarBase64);
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

  /// Adds a brand-new song to the catalog (from Search's "Submit it" link)
  /// and returns the generated songs/{songId} key.
  static Future<String> submitSong({
    required String title,
    required String artist,
    required String keyOfSong,
    required List<String> chordsUsed,
    required List<String> lines,
    String? submittedBy,
  }) async {
    final ref = _db.ref('songs').push();
    final song = Song(
      id: ref.key!,
      title: title,
      artist: artist,
      keyOfSong: keyOfSong,
      chordsUsed: chordsUsed,
      lines: lines,
      verified: false,
      submittedBy: submittedBy,
    );
    await ref.set(song.toMap());
    return ref.key!;
  }

  /// Fills in or replaces chords/lyrics on an existing catalog song (from
  /// Song Detail's "Submit chords" button, shown when a song has none yet).
  /// Credits [contributedBy] as the submitter only if the song doesn't
  /// already have one, so filling in a second song's chords doesn't steal
  /// credit from whoever added the song itself.
  static Future<void> updateSongContent({
    required String songId,
    required List<String> chordsUsed,
    required List<String> lines,
    String? contributedBy,
  }) async {
    final updates = <String, dynamic>{
      'chordsUsed': chordsUsed,
      'lines': lines,
    };

    if (contributedBy != null) {
      final existing = await _db.ref('songs/$songId/submittedBy').get();
      if (!existing.exists) {
        updates['submittedBy'] = contributedBy;
      }
    }

    await _db.ref('songs/$songId').update(updates);
  }

  /// All songs [uid] has submitted or first added chords for — drives
  /// Profile's "My submissions" screen. One-shot client-side filter, same
  /// approach as searchSongs; fine for a catalog this size.
  static Future<List<Song>> fetchMySubmissions(String uid) async {
    final snapshot = await _db.ref('songs').get();
    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries
        .map((e) => Song.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>))
        .where((s) => s.submittedBy == uid)
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
    final entryRef = _db.ref('users/$uid/library/${song.id}');
    // Already saved → leave it alone (re-saving would reset Mastered).
    if ((await entryRef.get()).exists) return;

    await entryRef.set({
      'title': song.title,
      'artist': song.artist,
      'isMastered': false,
    });
    await _syncSongsLearned(uid);
  }

  /// Keeps the profile's "Songs" stat equal to the real library size.
  /// Counting the library (rather than +1/-1) self-corrects older data.
  static Future<void> _syncSongsLearned(String uid) async {
    final lib = await _db.ref('users/$uid/library').get();
    final count = (lib.exists && lib.value is Map) ? (lib.value as Map).length : 0;
    await _db.ref('users/$uid/songsLearned').set(count);
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
    await _syncSongsLearned(uid);
  }

  // ---------------------------------------------------------------------
  // Chord diagrams — read from chordDiagrams/, imported via the Firebase
  // console from chordDiagrams_import.json. Lets new/corrected chord
  // shapes be added without an app update.
  // ---------------------------------------------------------------------

  /// Realtime Database keys can't contain '.', '#', '$', '[', ']', so a
  /// chord name like "F#m" needs its symbols swapped out before use as a
  /// path segment — must match the sanitizing used when the import JSON
  /// was generated.
  static String _chordCacheKey(String chordName) {
    return chordName
        .replaceAll('#', 'sharp')
        .replaceAll('.', 'dot')
        .replaceAll(r'$', 'dollar')
        .replaceAll('[', '(')
        .replaceAll(']', ')')
        .replaceAll('/', '_over_');
  }

  /// Returns the stored voicings for [chordName], or null if that key
  /// doesn't exist under chordDiagrams/ at all. Handles both shapes
  /// Realtime Database may hand back for a JSON array: a true List, or
  /// (for some single/sparse-index imports) a Map keyed by index.
  static Future<List<ChordVoicing>?> getCachedChordVoicings(String chordName) async {
    final key = _chordCacheKey(chordName);
    try {
      final snapshot = await _db.ref('chordDiagrams/$key').get();
      if (!snapshot.exists) {
        // ignore: avoid_print
        print('[chordDiagrams] no entry at chordDiagrams/$key for "$chordName"');
        return null;
      }

      final data = snapshot.value;
      Iterable<dynamic> entries;
      if (data is List) {
        entries = data;
      } else if (data is Map) {
        entries = data.values;
      } else {
        // ignore: avoid_print
        print('[chordDiagrams] unexpected value type at chordDiagrams/$key: ${data.runtimeType}');
        return null;
      }

      return entries
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => ChordVoicing.fromMap(m))
          .toList();
    } catch (e) {
      // Most commonly a permission-denied error from database rules —
      // surfaced here instead of being swallowed as "not found" so it's
      // visible in the debug console.
      // ignore: avoid_print
      print('[chordDiagrams] read failed for "$chordName" (key "$key"): $e');
      rethrow;
    }
  }

  static Future<void> cacheChordVoicings(String chordName, List<ChordVoicing> voicings) async {
    await _db.ref('chordDiagrams/${_chordCacheKey(chordName)}').set(
          voicings.map((v) => v.toMap()).toList(),
        );
  }
}
