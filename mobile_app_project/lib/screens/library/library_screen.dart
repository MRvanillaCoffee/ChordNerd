import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_text_styles.dart';
import '../../models/song.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

enum LibraryFilter { all, learning, mastered }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryFilter _filter = LibraryFilter.all;

  List<LibraryEntry> _applyFilter(List<LibraryEntry> songs) {
    switch (_filter) {
      case LibraryFilter.all:
        return songs;
      case LibraryFilter.learning:
        return songs.where((s) => !s.isMastered).toList();
      case LibraryFilter.mastered:
        return songs.where((s) => s.isMastered).toList();
    }
  }

  Future<void> _toggleMastered(LibraryEntry entry) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await DatabaseService.setMastered(uid: uid, songId: entry.songId, isMastered: !entry.isMastered);
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

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
                child: StreamBuilder<List<LibraryEntry>>(
                  stream: DatabaseService.watchLibrary(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final songs = _applyFilter(snapshot.data ?? []);

                    return songs.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            itemCount: songs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) => _buildSongCard(songs[i]),
                          );
                  },
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

  Widget _buildSongCard(LibraryEntry song) {
    final statusColor = song.isMastered ? AppColors.accentStreak : AppColors.accentPrimary;
    final statusLabel = song.isMastered ? 'Mastered' : 'Learning';
    final cardGradient = song.isMastered ? AppGradients.cardTintMint : AppGradients.cardTintPink;
    final badgeBg = song.isMastered ? AppColors.badgeBgMint : AppColors.badgeBgPink;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // TODO: navigate to song_detail_screen.dart with song.songId
      },
      onLongPress: () => _toggleMastered(song),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(12),
          border: AppGradients.cardBorder(statusColor),
          boxShadow: AppGradients.cardGlow(statusColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: badgeBg,
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
                color: badgeBg,
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
          Icon(Icons.library_music_outlined, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No songs here yet', style: AppTextStyles.bodyPrimary),
          const SizedBox(height: 4),
          Text('Save songs from Search to see them here', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
