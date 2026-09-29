import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

// TODO: wire real search — hit the local `songs` collection in Realtime
// Database first, fall back to Uberchord for standalone chord lookups,
// and show a "submit this song" prompt when nothing matches.

enum SearchFilter { all, chords, songs, artists }

class SearchResult {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isChord;

  const SearchResult({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isChord = false,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  SearchFilter _filter = SearchFilter.all;

  // TODO: replace with real query results
  final List<SearchResult> _results = const [
    SearchResult(title: 'Back in Black', subtitle: 'AC/DC · Key of E', icon: Icons.music_note_rounded),
    SearchResult(title: 'Highway to Hell', subtitle: 'AC/DC · Key of A', icon: Icons.music_note_rounded),
    SearchResult(title: 'E5 chord', subtitle: 'Chord diagram', icon: Icons.piano_rounded, isChord: true),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              Text('${_results.length} results', style: AppTextStyles.caption),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _buildResultCard(_results[i]),
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
      decoration: const InputDecoration(
        hintText: 'Search songs, artists, or chords',
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
      ),
      onChanged: (_) {
        // TODO: debounce and trigger real search
      },
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
                color: isSelected ? AppColors.surfaceSelected : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.accentLight : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultCard(SearchResult result) {
    final iconBg = result.isChord
        ? AppColors.accentStreak.withValues(alpha: 0.15)
        : AppColors.accentPrimary.withValues(alpha: 0.15);
    final iconColor = result.isChord ? AppColors.accentStreak : AppColors.accentPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // TODO: navigate to song_detail_screen.dart or chord diagram view
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Icon(result.icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.title, style: AppTextStyles.bodyPrimary.copyWith(fontWeight: FontWeight.w500)),
                  Text(result.subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
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
                  style: TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
