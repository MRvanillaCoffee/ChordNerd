import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_text_styles.dart';
import '../../models/song.dart';
import '../../models/chord_voicing.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/chord_api_service.dart';
import '../../utils/chordpro_parser.dart';
import '../../widgets/chord_diagram.dart';

/// Shows a song's chords laid out above its lyrics, parsed from the
/// ChordPro-style lines stored on the Song model. Reached from a tap on
/// a Search result or a Library entry.
class SongDetailScreen extends StatefulWidget {
  final Song song;

  const SongDetailScreen({super.key, required this.song});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    final parsedLines = ChordProParser.parseLines(song.lines);
    final hasLyrics = song.lines.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
              color: _isSaved ? AppColors.accentStreak : AppColors.textPrimary,
            ),
            onPressed: _isSaving ? null : _toggleSave,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(song),
              const SizedBox(height: 16),
              if (song.chordsUsed.isNotEmpty) ...[
                _buildChordsUsedRow(song),
                const SizedBox(height: 20),
              ],
              if (hasLyrics)
                _buildLyricsSheet(parsedLines)
              else
                _buildNoLyricsState(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Song song) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(song.title, style: AppTextStyles.h1),
        const SizedBox(height: 4),
        Text(
          song.keyOfSong.isNotEmpty ? '${song.artist} · Key of ${song.keyOfSong}' : song.artist,
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }

  Widget _buildChordsUsedRow(Song song) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: song.chordsUsed.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final chordName = song.chordsUsed[i];
          return GestureDetector(
            onTap: () => _showChordDiagram(chordName),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.badgeBgPink,
                borderRadius: BorderRadius.circular(20),
                border: AppGradients.cardBorder(AppColors.accentPrimary),
              ),
              alignment: Alignment.center,
              child: Text(
                chordName,
                style: AppTextStyles.label.copyWith(color: AppColors.accentPrimary, fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showChordDiagram(String chordName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ChordDiagramSheet(chordName: chordName),
    );
  }

  Widget _buildLyricsSheet(List<List<ChordLyricSegment>> parsedLines) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.cardTintNeutral,
        borderRadius: BorderRadius.circular(14),
        border: AppGradients.cardBorder(AppColors.accentPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in parsedLines) ...[
            _buildLyricLine(line),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }

  Widget _buildLyricLine(List<ChordLyricSegment> segments) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: segments.map((segment) {
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 16,
                child: segment.chord != null
                    ? Text(
                        segment.chord!,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accentPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              Text(segment.text, style: AppTextStyles.bodyPrimary),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoLyricsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.cardTintNeutral,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.lyrics_outlined, size: 32, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
            'No chord sheet for this song yet',
            style: AppTextStyles.bodyPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to submit one',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              // TODO: navigate to song submission editor, pre-filled with
              // this song's title/artist
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.border, width: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Submit chords', style: AppTextStyles.bodyPrimary.copyWith(color: AppColors.accentPrimary)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleSave() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    if (_isSaved) {
      await DatabaseService.removeFromLibrary(uid: uid, songId: widget.song.id);
    } else {
      await DatabaseService.saveToLibrary(uid: uid, song: widget.song);
    }

    if (mounted) {
      setState(() {
        _isSaved = !_isSaved;
        _isSaving = false;
      });
    }
  }
}

/// Bottom sheet content for a tapped chord pill — fetches voicings
/// (cache-first, then Uberchord) and shows one diagram per voicing in a
/// horizontal swipe, or a loading/empty/error state.
class _ChordDiagramSheet extends StatefulWidget {
  final String chordName;

  const _ChordDiagramSheet({required this.chordName});

  @override
  State<_ChordDiagramSheet> createState() => _ChordDiagramSheetState();
}

class _ChordDiagramSheetState extends State<_ChordDiagramSheet> {
  late Future<List<ChordVoicing>> _future;

  @override
  void initState() {
    super.initState();
    _future = ChordApiService.fetchVoicings(widget.chordName);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(widget.chordName, style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text('Chord diagram', style: AppTextStyles.bodySecondary),
            const SizedBox(height: 16),
            FutureBuilder<List<ChordVoicing>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return SizedBox(
                    height: 190,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accentPrimary),
                    ),
                  );
                }

                final voicings = snapshot.data ?? [];
                if (voicings.isEmpty) {
                  return SizedBox(
                    height: 120,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.music_off_rounded, color: AppColors.textMuted, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            "Couldn't find a diagram for this chord",
                            style: AppTextStyles.bodySecondary,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: voicings.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) => ChordDiagram(voicing: voicings[i]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
