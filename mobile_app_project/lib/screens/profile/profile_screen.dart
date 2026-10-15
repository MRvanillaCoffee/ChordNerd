import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_text_styles.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../edit_profile/edit_profile_screen.dart';
import '../my_submissions/my_submissions_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploadingAvatar = false;

  Future<void> _changeAvatar(String uid) async {
    final picker = ImagePicker();
    // Kept small on purpose — this gets base64-encoded and stored inline
    // in Realtime Database (no Firebase Storage, which requires the paid
    // Blaze plan), so a smaller/more-compressed image keeps the database
    // entry light and the avatar quick to load.
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 70,
    );
    if (picked == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final bytes = await picked.readAsBytes();
      final base64Image = base64Encode(bytes);
      await DatabaseService.updateAvatarImage(uid: uid, avatarBase64: base64Image);
    } catch (e) {
      debugPrint('[avatar upload] failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't save photo — $e", style: AppTextStyles.bodyPrimary),
            backgroundColor: AppColors.surfaceCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _openEditProfile(UserProfile profile) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: profile)),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated', style: AppTextStyles.bodyPrimary),
          backgroundColor: AppColors.surfaceCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<UserProfile?>(
          stream: DatabaseService.watchUserProfile(user.uid),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final profile = snapshot.data ??
                UserProfile(uid: user.uid, name: user.displayName ?? 'Guitarist', email: user.email ?? '', skillLevel: 'beginner');

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Chord Nerd', style: AppTextStyles.label.copyWith(
                    color: AppColors.accentPrimary,
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 18),
                  _buildHeader(profile, user.uid),
                  const SizedBox(height: 22),
                  _buildStatsRow(isLoading ? null : profile),
                  const SizedBox(height: 20),
                  _buildMenuList(context, profile),
                  const SizedBox(height: 20),
                  _buildLogoutButton(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(UserProfile profile, String uid) {
    final initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?';

    return Column(
      children: [
        GestureDetector(
          onTap: _isUploadingAvatar ? null : () => _changeAvatar(uid),
          child: Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: profile.avatarBase64 == null ? AppGradients.avatar : null,
                  shape: BoxShape.circle,
                  image: profile.avatarBase64 != null
                      ? DecorationImage(image: MemoryImage(base64Decode(profile.avatarBase64!)), fit: BoxFit.cover)
                      : null,
                ),
                alignment: Alignment.center,
                child: profile.avatarBase64 == null
                    ? Text(initial, style: AppTextStyles.h1.copyWith(color: AppColors.onAccentPrimary, fontSize: 26))
                    : null,
              ),
              if (_isUploadingAvatar)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onAccentPrimary),
                    ),
                  ),
                )
              else
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.camera_alt_rounded, size: 12, color: AppColors.onAccentPrimary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(profile.name, style: AppTextStyles.h2),
        const SizedBox(height: 2),
        if (profile.email.isNotEmpty) Text(profile.email, style: AppTextStyles.bodySecondary),
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
              Icon(Icons.music_note_rounded, size: 13, color: AppColors.accentPrimary),
              const SizedBox(width: 6),
              Text(
                profile.skillLevel.isNotEmpty
                    ? profile.skillLevel[0].toUpperCase() + profile.skillLevel.substring(1)
                    : 'Beginner',
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

  Widget _buildStatsRow(UserProfile? profile) {
    return Row(
      children: [
        Expanded(child: _statCard(
          value: (profile?.totalPracticeHours ?? 0).toStringAsFixed(1),
          label: 'Hours',
          gradient: AppGradients.statCardPink,
          glowColor: AppColors.accentPrimary,
        )),
        const SizedBox(width: 10),
        Expanded(child: _statCard(
          value: '${profile?.effectiveStreak ?? 0}',
          label: 'Streak',
          icon: Icons.local_fire_department_rounded,
          gradient: AppGradients.streakCard,
          glowColor: AppColors.accentStreak,
        )),
        const SizedBox(width: 10),
        Expanded(child: _statCard(
          value: '${profile?.songsLearned ?? 0}',
          label: 'Songs',
          gradient: AppGradients.statCardMint,
          glowColor: AppColors.accentStreak,
        )),
      ],
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required LinearGradient gradient,
    required Color glowColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        border: AppGradients.cardBorder(glowColor),
        boxShadow: AppGradients.cardGlow(glowColor),
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

  Widget _buildMenuList(BuildContext context, UserProfile profile) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.cardTintNeutral,
        borderRadius: BorderRadius.circular(12),
        border: AppGradients.cardBorder(AppColors.accentPrimary),
        boxShadow: AppGradients.cardGlow(AppColors.accentPrimary),
      ),
      child: Column(
        children: [
          _menuRow(
            icon: Icons.edit_outlined,
            label: 'Edit profile',
            onTap: () => _openEditProfile(profile),
          ),
          _divider(),
          _menuRow(
            icon: Icons.checklist_rounded,
            label: 'My submissions',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MySubmissionsScreen()),
            ),
          ),
          _divider(),
          _menuRow(
            icon: Icons.settings_outlined,
            label: 'Settings',
            // Notifications doesn't get its own Profile row — it's just
            // a reminder toggle, so it lives as a section inside Settings
            // instead (see settings_screen.dart).
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SettingsScreen(profile: profile)),
            ),
          ),
          _divider(),
          _buildDarkModeRow(),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: AppColors.border, thickness: 0.5, indent: 16, endIndent: 16);

  Widget _buildDarkModeRow() {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.mode,
      builder: (context, isDark, _) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  size: 18,
                  color: AppColors.accentLight,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Dark mode', style: AppTextStyles.bodyPrimary)),
                Switch(
                  value: isDark,
                  onChanged: (_) => AppColors.toggle(),
                  activeColor: AppColors.accentPrimary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
          ? const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))
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
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.border, width: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, size: 16, color: AppColors.accentStreak),
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
