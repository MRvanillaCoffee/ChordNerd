import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_text_styles.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const List<String> _weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final displayName = user?.displayName ?? 'Guitarist';
    final firstName = displayName.split(' ').first;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<UserProfile?>(
          stream: DatabaseService.watchUserProfile(user.uid),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Chord Nerd',
                      style: AppTextStyles.label2.copyWith(
                        color: AppColors.accentPrimary,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 6),
                  _buildGreeting(firstName, initial),
                  const SizedBox(height: 20),
                  _buildStreakCard(
                      isLoading ? 0 : (profile?.currentStreak ?? 0)),
                  const SizedBox(height: 14),
                  _buildStatsRow(
                    hours: isLoading ? 0 : (profile?.totalPracticeHours ?? 0),
                    songs: isLoading ? 0 : (profile?.songsLearned ?? 0),
                  ),
                  const SizedBox(height: 16),
                  _buildWeekChart(isLoading
                      ? List.filled(7, 0)
                      : (profile?.weekMinutesList ?? List.filled(7, 0))),
                  const SizedBox(height: 20),
                  _buildStartPracticeButton(context, user.uid),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGreeting(String firstName, String initial) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good evening', style: AppTextStyles.bodySecondary),
            Text(firstName, style: AppTextStyles.h2),
          ],
        ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: AppColors.accentPrimary, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: AppTextStyles.label.copyWith(
                color: AppColors.onAccentPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: AppGradients.cardBorder(AppColors.accentStreak),
        boxShadow: AppGradients.cardGlow(AppColors.accentStreak),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.badgeBgMint,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.local_fire_department_rounded,
                color: AppColors.accentStreak, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak > 0 ? '$streak-day streak' : 'No streak yet',
                  style: AppTextStyles.bodyPrimary
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Text('Practice today to keep it going',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow({required double hours, required int songs}) {
    return Row(
      children: [
        Expanded(
            child: _statCard(
          icon: Icons.access_time_rounded,
          value: hours.toStringAsFixed(1),
          label: 'Hours',
          tint: AppColors.accentPrimary,
          bg: AppColors.badgeBgPink,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard(
          icon: Icons.music_note_rounded,
          value: '$songs',
          label: 'Songs',
          tint: AppColors.accentStreak,
          bg: AppColors.badgeBgMint,
        )),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color tint,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: AppGradients.cardBorder(tint),
        boxShadow: AppGradients.cardGlow(tint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: tint),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.h2.copyWith(fontSize: 20)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildWeekChart(List<int> weekMinutes) {
    final maxMinutes =
        weekMinutes.isEmpty ? 1 : weekMinutes.reduce((a, b) => a > b ? a : b);
    final safeMax = maxMinutes == 0 ? 1 : maxMinutes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: AppGradients.cardBorder(AppColors.accentPrimary),
        boxShadow: AppGradients.cardGlow(AppColors.accentPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This week',
              style: AppTextStyles.bodyPrimary
                  .copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 14),
          SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final isToday =
                    i == DateTime.now().weekday - 1; // weekday is 1=Mon..7=Sun
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor:
                                  (weekMinutes[i] / safeMax).clamp(0.05, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? AppColors.accentPrimary
                                      : AppColors.chartInactive,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _weekLabels[i],
                          style: AppTextStyles.caption.copyWith(
                            color: isToday
                                ? AppColors.accentPrimary
                                : AppColors.textMuted,
                            fontWeight:
                                isToday ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartPracticeButton(BuildContext context, String uid) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentPrimary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            // TODO: replace with a real practice session flow / timer —
            // this logs a placeholder 15-minute session for now so the
            // dashboard has something real to react to.
            await DatabaseService.logPracticeSession(uid: uid, minutes: 15);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Practice session logged',
                      style: AppTextStyles.bodyPrimary),
                  backgroundColor: AppColors.surfaceCard,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded,
                    size: 18, color: AppColors.onAccentPrimary),
                const SizedBox(width: 8),
                Text('Start practice session',
                    style: AppTextStyles.buttonLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
