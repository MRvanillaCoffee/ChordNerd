import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_text_styles.dart';
import '../../models/song.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

/// Lets a user add a brand-new song to the catalog, or fill in chords/
/// lyrics for an existing one that doesn't have them yet.
///
/// - Opened with no [existingSong]: from Search's "Can't find a song?
///   Submit it" link — creates a new songs/{songId} entry.
/// - Opened with [existingSong]: from Song Detail's "Submit chords"
///   button (shown when a song has no lyrics yet) — title/artist/key
///   are locked to the existing catalog entry, and submitting merges
///   the chords/lyrics into that same song rather than creating a
///   duplicate.
///
/// Pops with the resulting [Song] on success, so the caller can refresh
/// what it's showing (Song Detail swaps in the updated song; Search just
/// re-runs its query).
class SongSubmitScreen extends StatefulWidget {
  final Song? existingSong;

  const SongSubmitScreen({super.key, this.existingSong});

  @override
  State<SongSubmitScreen> createState() => _SongSubmitScreenState();
}

class _SongSubmitScreenState extends State<SongSubmitScreen> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _keyController = TextEditingController();
  final _chordInputController = TextEditingController();
  final _lyricsController = TextEditingController();

  final List<String> _chords = [];
  bool _isSubmitting = false;
  String? _errorText;

  bool get _isAddingToExisting => widget.existingSong != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSong;
    if (existing != null) {
      _titleController.text = existing.title;
      _artistController.text = existing.artist;
      _keyController.text = existing.keyOfSong;
      _chords.addAll(existing.chordsUsed);
      _lyricsController.text = existing.lines.join('\n');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _keyController.dispose();
    _chordInputController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  void _addChord() {
    final value = _chordInputController.text.trim();
    if (value.isEmpty || _chords.contains(value)) {
      _chordInputController.clear();
      return;
    }
    setState(() {
      _chords.add(value);
      _chordInputController.clear();
    });
  }

  void _removeChord(String chord) {
    setState(() => _chords.remove(chord));
  }

  Future<void> _handleSubmit() async {
    setState(() => _errorText = null);

    final title = _titleController.text.trim();
    final artist = _artistController.text.trim();
    if (title.isEmpty || artist.isEmpty) {
      setState(() => _errorText = 'Title and artist are required');
      return;
    }

    setState(() => _isSubmitting = true);

    final lines = _lyricsController.text
        .split('\n')
        .map((l) => l.trimRight())
        .where((l) => l.isNotEmpty)
        .toList();

    try {
      final uid = AuthService.currentUser?.uid;
      final existing = widget.existingSong;
      Song result;

      if (existing != null) {
        await DatabaseService.updateSongContent(
          songId: existing.id,
          chordsUsed: _chords,
          lines: lines,
          contributedBy: uid,
        );
        result = Song(
          id: existing.id,
          title: existing.title,
          artist: existing.artist,
          keyOfSong: existing.keyOfSong,
          chordsUsed: _chords,
          lines: lines,
          verified: existing.verified,
          submittedBy: existing.submittedBy ?? uid,
        );
      } else {
        final newId = await DatabaseService.submitSong(
          title: title,
          artist: artist,
          keyOfSong: _keyController.text.trim(),
          chordsUsed: _chords,
          lines: lines,
          submittedBy: uid,
        );
        result = Song(
          id: newId,
          title: title,
          artist: artist,
          keyOfSong: _keyController.text.trim(),
          chordsUsed: _chords,
          lines: lines,
          verified: false,
          submittedBy: uid,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isAddingToExisting ? 'Chords submitted — thanks!' : '"${result.title}" added to the catalog',
              style: AppTextStyles.bodyPrimary,
            ),
            backgroundColor: AppColors.surfaceSelected,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      setState(() => _errorText = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isAddingToExisting ? 'Submit chords' : 'Add a song',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 4),
              Text(
                _isAddingToExisting
                    ? 'Fill in the chords and lyrics — other players will see this once it\'s reviewed'
                    : 'Can\'t find it in the catalog? Add it yourself',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 24),
              _buildField(
                label: 'Title',
                controller: _titleController,
                hint: 'Song title',
                enabled: !_isAddingToExisting,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Artist',
                controller: _artistController,
                hint: 'Artist name',
                enabled: !_isAddingToExisting,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Key (optional)',
                controller: _keyController,
                hint: 'e.g. E, G, A minor',
                enabled: !_isAddingToExisting,
              ),
              const SizedBox(height: 20),
              Text('Chords used', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _buildChordInput(),
              if (_chords.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildChordChips(),
              ],
              const SizedBox(height: 20),
              Text('Lyrics (optional)', style: AppTextStyles.label),
              const SizedBox(height: 6),
              Text(
                'One line per line, chords in brackets before the word: [E5]Back in black',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _lyricsController,
                style: AppTextStyles.bodyPrimary,
                maxLines: 8,
                minLines: 4,
                decoration: const InputDecoration(
                  hintText: '[E5]Back in black, [B5]I hit the sack',
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorText!,
                  style: AppTextStyles.bodySecondary.copyWith(color: AppColors.accentStreak),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _isSubmitting ? null : _handleSubmit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: _isSubmitting
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onAccentPrimary,
                                ),
                              )
                            : Text(
                                _isAddingToExisting ? 'Submit chords' : 'Add song',
                                style: AppTextStyles.buttonLabel,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          style: AppTextStyles.bodyPrimary.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textMuted,
          ),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildChordInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _chordInputController,
            style: AppTextStyles.bodyPrimary,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'e.g. Em7, D/F#'),
            onSubmitted: (_) => _addChord(),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: AppColors.surfaceSelected,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _addChord,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                'Add',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChordChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _chords.map((chord) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.badgeBgPink,
            borderRadius: BorderRadius.circular(20),
            border: AppGradients.cardBorder(AppColors.accentPrimary),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chord,
                style: AppTextStyles.label.copyWith(color: AppColors.accentPrimary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _removeChord(chord),
                child: Icon(Icons.close_rounded, size: 14, color: AppColors.accentPrimary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
