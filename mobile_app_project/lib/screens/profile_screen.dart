import 'package:flutter/material.dart';
import 'package:chord_nerd/app/Theme/app_colors.dart';
import 'package:chord_nerd/app/Theme/app_text_styles.dart';
import '../../services/auth_service.dart';

// TODO: pull real stats (totalPracticeHours, currentStreak, songs learned,
// skillLevel) from Realtime Database at users/{uid} instead of the
// placeholder values below — e.g. via a ProfileProvider/riverpod stream.

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final displayName = user?.displayName ?? 'Guitarist';
    final email = user?.email ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Chord Nerd',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.accentPrimary,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 18),
              _buildHeader(initial: initial, name: displayName, email: email),
              const SizedBox(height: 22),
              _buildStatsRow(),
              const SizedBox(height: 20),
              _buildMenuList(context),
              const SizedBox(height: 20),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      {required String initial, required String name, required String email}) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
              color: AppColors.surfaceSelected, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: AppTextStyles.h1
                .copyWith(color: AppColors.accentLight, fontSize: 26),
          ),
        ),
        const SizedBox(height: 12),
        Text(name, style: AppTextStyles.h2),
        const SizedBox(height: 2),
        if (email.isNotEmpty) Text(email, style: AppTextStyles.bodySecondary),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.music_note_rounded,
                  size: 13, color: AppColors.accentPrimary),
              const SizedBox(width: 6),
              Text(
                'Intermediate', // TODO: pull from users/{uid}/skillLevel
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard(value: '42.5', label: 'Hours')),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard(
                value: '12',
                label: 'Streak',
                icon: Icons.local_fire_department_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _statCard(value: '8', label: 'Songs')),
      ],
    );
  }

  Widget _statCard(
      {required String value, required String label, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: AppColors.accentStreak),
                const SizedBox(width: 3),
              ],
              Text(value, style: AppTextStyles.h2.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _menuRow(
            icon: Icons.edit_outlined,
            label: 'Edit profile',
            onTap: () {}, // TODO: navigate to edit_profile_screen.dart
          ),
          _divider(),
          _menuRow(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () {}, // TODO: navigate to notification settings
          ),
          _divider(),
          _menuRow(
            icon: Icons.checklist_rounded,
            label: 'My submissions',
            trailing:
                '3 pending', // TODO: pull real count from submissions collection
            onTap: () {}, // TODO: navigate to submissions list
          ),
          _divider(),
          _menuRow(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {}, // TODO: navigate to app settings
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
      height: 1,
      color: AppColors.border,
      thickness: 0.5,
      indent: 16,
      endIndent: 16);

  Widget _menuRow({
    required IconData icon,
    required String label,
    String? trailing,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.accentLight),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyPrimary)),
            if (trailing != null) ...[
              Text(trailing, style: AppTextStyles.bodySecondary),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        await AuthService.signOut();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged out', style: AppTextStyles.bodyPrimary),
              backgroundColor: AppColors.surfaceCard,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        // TODO: once auth-state routing exists in main.dart, signing out
        // will automatically return to LoginScreen — no manual nav needed.
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border, width: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout_rounded,
              size: 16, color: AppColors.accentStreak),
          const SizedBox(width: 8),
          Text(
            'Log out',
            style: AppTextStyles.bodyPrimary.copyWith(
              color: AppColors.accentStreak,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
