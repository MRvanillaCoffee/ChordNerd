import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_text_styles.dart';

// TODO: replace placeholder data with a real stream from Realtime Database
// at users/{uid}/library, populated whenever a song is saved from Search
// or Song Detail.

enum LibraryFilter { all, learning, mastered }

class LibrarySong {
  final String title;
  final String artist;
  final bool isMastered;

  const LibrarySong({required this.title, required this.artist, required this.isMastered});
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryFilter _filter = LibraryFilter.all;

  // TODO: replace with real saved songs
  final List<LibrarySong> _songs = const [
    LibrarySong(title: 'Back in Black', artist: 'AC/DC', isMastered: true),
    LibrarySong(title: 'Wonderwall', artist: 'Oasis', isMastered: false),
    LibrarySong(title: 'Zombie', artist: 'The Cranberries', isMastered: false),
    LibrarySong(title: 'Redemption Song', artist: 'Bob Marley', isMastered: true),
  ];

  List<LibrarySong> get _filteredSongs {
    switch (_filter) {
      case LibraryFilter.all:
        return _songs;
      case LibraryFilter.learning:
        return _songs.where((s) => !s.isMastered).toList();
      case LibraryFilter.mastered:
        return _songs.where((s) => s.isMastered).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final songs = _filteredSongs;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Library', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              _buildFilterTabs(),
              const SizedBox(height: 14),
              Expanded(
                child: songs.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: songs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => _buildSongCard(songs[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: LibraryFilter.values.map((filter) {
          final isSelected = _filter == filter;
          final label = switch (filter) {
            LibraryFilter.all => 'All',
            LibraryFilter.learning => 'Learning',
            LibraryFilter.mastered => 'Mastered',
          };
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surfaceSelected : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSongCard(LibrarySong song) {
    final statusColor = song.isMastered ? AppColors.accentStreak : AppColors.accentPrimary;
    final statusLabel = song.isMastered ? 'Mastered' : 'Learning';
    final cardGradient = song.isMastered ? AppGradients.cardTintMint : AppGradients.cardTintPink;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // TODO: navigate to song_detail_screen.dart
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(gradient: cardGradient, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.music_note_rounded, size: 18, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title, style: AppTextStyles.bodyPrimary.copyWith(fontWeight: FontWeight.w500)),
                  Text(song.artist, style: AppTextStyles.caption),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.library_music_outlined, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No songs here yet', style: AppTextStyles.bodyPrimary),
          const SizedBox(height: 4),
          Text('Save songs from Search to see them here', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
