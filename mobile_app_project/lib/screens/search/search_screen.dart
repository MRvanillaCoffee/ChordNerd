import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chord_nerd/app/theme/app_colors.dart';
import 'package:chord_nerd/app/theme/app_gradients.dart';
import 'package:chord_nerd/app/theme/app_text_styles.dart';
import 'package:chord_nerd/models/song.dart';
import 'package:chord_nerd/services/auth_service.dart';
import 'package:chord_nerd/services/database_service.dart';
import 'package:chord_nerd/screens/song_detail/song_detail_screen.dart';

// TODO: once a standalone chord lookup API (Uberchord) is wired in,
// fall back to it when no song matches, so a bare chord name like "E5"
// still returns a result.

enum SearchFilter { all, chords, songs, artists }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  SearchFilter _filter = SearchFilter.all;

  List<Song> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Timer? _debounce;

  Set<String> _savedSongIds = {};
  StreamSubscription? _librarySub;

  @override
  void initState() {
    super.initState();
    // Load all songs immediately so the screen isn't empty on first open —
    // an empty query returns everything (see DatabaseService.searchSongs).
    _runSearch('');

    // Track which songs are already saved, so their card can switch to
    // green/mint instead of the default pink.
    final uid = AuthService.currentUser?.uid;
    if (uid != null) {
      _librarySub = DatabaseService.watchLibrary(uid).listen((entries) {
        if (mounted) {
          setState(() => _savedSongIds = entries.map((e) => e.songId).toSet());
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _librarySub?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 400), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final results = await DatabaseService.searchSongs(query);

    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSong(Song song) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;

    await DatabaseService.saveToLibrary(uid: uid, song: song);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved "${song.title}" to Library',
              style: AppTextStyles.bodyPrimary),
          backgroundColor: AppColors.surfaceCard,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Search', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              _buildSearchField(),
              const SizedBox(height: 16),
              _buildFilterChips(),
              const SizedBox(height: 12),
              if (_hasSearched)
                Text('${_results.length} results',
                    style: AppTextStyles.caption),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : !_hasSearched
                        ? Center(
                            child: Text('Search for a song to get started',
                                style: AppTextStyles.bodySecondary),
                          )
                        : _results.isEmpty
                            ? Center(
                                child: Text(
                                    'No results — try submitting it below',
                                    style: AppTextStyles.bodySecondary),
                              )
                            : ListView.separated(
                                itemCount: _results.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, i) =>
                                    _buildResultCard(_results[i]),
                              ),
              ),
              _buildSubmitLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: AppTextStyles.bodyPrimary,
      decoration: InputDecoration(
        hintText: 'Search songs, artists, or chords',
        prefixIcon:
            Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
      ),
      onChanged: _onQueryChanged,
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: SearchFilter.values.map((filter) {
        final isSelected = _filter == filter;
        final label = switch (filter) {
          SearchFilter.all => 'All',
          SearchFilter.chords => 'Chords',
          SearchFilter.songs => 'Songs',
          SearchFilter.artists => 'Artists',
        };
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _filter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.surfaceSelected
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected
                      ? AppColors.accentLight
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultCard(Song song) {
    final subtitle = song.keyOfSong.isNotEmpty
        ? '${song.artist} · Key of ${song.keyOfSong}'
        : song.artist;
    final isSaved = _savedSongIds.contains(song.id);

    final cardGradient =
        isSaved ? AppGradients.cardTintMint : AppGradients.cardTintPink;
    final accentColor =
        isSaved ? AppColors.accentStreak : AppColors.accentPrimary;
    final badgeBg = isSaved ? AppColors.badgeBgMint : AppColors.badgeBgPink;

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
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(12),
          border: AppGradients.cardBorder(accentColor),
          boxShadow: AppGradients.cardGlow(accentColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: badgeBg, borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child:
                  Icon(Icons.music_note_rounded, size: 18, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title,
                      style: AppTextStyles.bodyPrimary
                          .copyWith(fontWeight: FontWeight.w500)),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                size: 20,
                color: isSaved ? AppColors.accentStreak : AppColors.textMuted,
              ),
              onPressed: isSaved ? null : () => _saveSong(song),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: GestureDetector(
          onTap: () {
            // TODO: navigate to song submission editor
          },
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodySecondary,
              children: [
                const TextSpan(text: "Can't find a song? "),
                TextSpan(
                  text: 'Submit it',
                  style: TextStyle(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
