import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_text_styles.dart';
import '../../services/auth_service.dart';

// TODO: pull real stats (totalPracticeHours, currentStreak, songs learned,
// weekly practice minutes) from Realtime Database at users/{uid} instead
// of the placeholder values below.

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const List<double> _weekFractions = [0.55, 0.7, 0.4, 0.8, 0.6, 0.35, 1.0];
  static const List<String> _weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final displayName = AuthService.currentUser?.displayName ?? 'Guitarist';
    final firstName = displayName.split(' ').first;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Chord Nerd', style: AppTextStyles.label.copyWith(
                color: AppColors.accentPrimary,
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 6),
              _buildGreeting(firstName, initial),
              const SizedBox(height: 20),
              _buildStreakCard(),
              const SizedBox(height: 14),
              _buildStatsRow(),
              const SizedBox(height: 16),
              _buildWeekChart(),
              const SizedBox(height: 20),
              _buildStartPracticeButton(context),
            ],
          ),
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
          decoration: const BoxDecoration(gradient: AppGradients.avatar, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: AppTextStyles.label.copyWith(color: AppColors.onAccentPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppGradients.streakCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentStreak.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_fire_department_rounded, color: AppColors.accentStreak, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('12-day streak', style: AppTextStyles.bodyPrimary.copyWith(fontWeight: FontWeight.w500)),
                Text('Practice today to keep it going', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard(icon: Icons.access_time_rounded, value: '42.5', label: 'Hours', gradient: AppGradients.statCardPink, iconColor: AppColors.accentPrimary)),
        const SizedBox(width: 10),
        Expanded(child: _statCard(icon: Icons.music_note_rounded, value: '8', label: 'Songs', gradient: AppGradients.statCardMint, iconColor: AppColors.accentStreak)),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required LinearGradient gradient,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.h2.copyWith(fontSize: 20)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildWeekChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: AppGradients.cardTintNeutral, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This week', style: AppTextStyles.bodyPrimary.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 14),
          SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final isToday = i == 6;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: _weekFractions[i],
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? AppColors.accentPrimary
                                      : AppColors.accentStreak.withValues(alpha: 0.35 + _weekFractions[i] * 0.35),
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
                            color: isToday ? AppColors.accentPrimary : AppColors.textMuted,
                            fontWeight: isToday ? FontWeight.w500 : FontWeight.w400,
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

  Widget _buildStartPracticeButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primaryButton,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: navigate to a practice session flow / timer
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, size: 18, color: AppColors.onAccentPrimary),
                const SizedBox(width: 8),
                Text('Start practice session', style: AppTextStyles.buttonLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
