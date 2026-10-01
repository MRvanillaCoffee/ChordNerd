/// Maps to a document at songs/{songId} in Realtime Database.
class Song {
  final String id;
  final String title;
  final String artist;
  final String keyOfSong;
  final List<String> chordsUsed;
  final List<String> lines; // ChordPro-style lines, e.g. "[E5]Back in black..."
  final bool verified;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.keyOfSong,
    this.chordsUsed = const [],
    this.lines = const [],
    this.verified = false,
  });

  factory Song.fromMap(String id, Map<dynamic, dynamic> map) {
    return Song(
      id: id,
      title: map['title'] as String? ?? 'Untitled',
      artist: map['artist'] as String? ?? 'Unknown artist',
      keyOfSong: map['key'] as String? ?? '',
      chordsUsed: (map['chordsUsed'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      lines: (map['lines'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      verified: map['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'key': keyOfSong,
      'chordsUsed': chordsUsed,
      'lines': lines,
      'verified': verified,
    };
  }
}

/// Maps to a document at users/{uid}/library/{songId} — a lightweight
/// pointer to a saved song plus its learning status, kept separate from
/// the full Song so the library list stays cheap to load.
class LibraryEntry {
  final String songId;
  final String title;
  final String artist;
  final bool isMastered;

  const LibraryEntry({
    required this.songId,
    required this.title,
    required this.artist,
    this.isMastered = false,
  });

  factory LibraryEntry.fromMap(String songId, Map<dynamic, dynamic> map) {
    return LibraryEntry(
      songId: songId,
      title: map['title'] as String? ?? 'Untitled',
      artist: map['artist'] as String? ?? 'Unknown artist',
      isMastered: map['isMastered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'isMastered': isMastered,
    };
  }
}
