import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_text_styles.dart';
import '../../models/song.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../song_detail/song_detail_screen.dart';

/// Lists songs the signed-in user has submitted — either added from
/// scratch or whose chords they were first to fill in. Opened from
/// Profile's "My submissions" row.
class MySubmissionsScreen extends StatefulWidget {
  const MySubmissionsScreen({super.key});

  @override
  State<MySubmissionsScreen> createState() => _MySubmissionsScreenState();
}

class _MySubmissionsScreenState extends State<MySubmissionsScreen> {
  late Future<List<Song>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Song>> _load() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return Future.value([]);
    return DatabaseService.fetchMySubmissions(uid);
  }

  Future<void> _refresh() async {
    final result = _load();
    setState(() => _future = result);
    await result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
        title: Text('My submissions', style: AppTextStyles.h2),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Song>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final songs = snapshot.data ?? [];
            if (songs.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: songs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _buildSongCard(songs[i]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist_rounded, size: 32, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              "You haven't submitted any songs yet",
              style: AppTextStyles.bodyPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Add a new song from Search, or fill in chords for one that\'s missing them',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongCard(Song song) {
    final badgeColor = song.verified ? AppColors.accentStreak : AppColors.accentPrimary;
    final badgeBg = song.verified ? AppColors.badgeBgMint : AppColors.badgeBgPink;
    final badgeLabel = song.verified ? 'Verified' : 'Pending review';
    final badgeIcon = song.verified ? Icons.check_circle_rounded : Icons.hourglass_top_rounded;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SongDetailScreen(song: song)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppGradients.cardTintNeutral,
          borderRadius: BorderRadius.circular(12),
          border: AppGradients.cardBorder(AppColors.accentPrimary),
          boxShadow: AppGradients.cardGlow(AppColors.accentPrimary),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.badgeBgPink, borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Icon(Icons.music_note_rounded, size: 18, color: AppColors.accentPrimary),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badgeIcon, size: 12, color: badgeColor),
                  const SizedBox(width: 4),
                  Text(
                    badgeLabel,
                    style: AppTextStyles.caption.copyWith(color: badgeColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
