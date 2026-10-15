import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_text_styles.dart';
import '../../models/user_profile.dart';
import '../../services/database_service.dart';

/// App settings, opened from Profile's "Settings" row. Notifications
/// doesn't get its own top-level Profile menu entry — there's only ever
/// a reminder toggle and a time to configure, so it lives here as a
/// section instead of a whole separate screen.
class SettingsScreen extends StatefulWidget {
  final UserProfile profile;

  const SettingsScreen({super.key, required this.profile});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _reminderEnabled;
  late TimeOfDay _reminderTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _reminderEnabled = widget.profile.reminderEnabled;
    _reminderTime = _parseTime(widget.profile.reminderTime);
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 18 : 18;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime24(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _save({bool? reminderEnabled, TimeOfDay? reminderTime}) async {
    setState(() {
      if (reminderEnabled != null) _reminderEnabled = reminderEnabled;
      if (reminderTime != null) _reminderTime = reminderTime;
      _isSaving = true;
    });
    try {
      await DatabaseService.updateNotificationSettings(
        uid: widget.profile.uid,
        reminderEnabled: _reminderEnabled,
        reminderTime: _formatTime24(_reminderTime),
      );
    } catch (e) {
      debugPrint('[settings] failed to save notification settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't save — $e", style: AppTextStyles.bodyPrimary),
            backgroundColor: AppColors.surfaceCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(context: context, initialTime: _reminderTime);
    if (picked != null) {
      await _save(reminderTime: picked);
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
        title: Text('Settings', style: AppTextStyles.h2),
        actions: [
          if (_isSaving)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPrimary),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text('Notifications', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _buildNotificationsSection(),
            const SizedBox(height: 24),
            Text('About', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.cardTintNeutral,
        borderRadius: BorderRadius.circular(12),
        border: AppGradients.cardBorder(AppColors.accentPrimary),
        boxShadow: AppGradients.cardGlow(AppColors.accentPrimary),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.notifications_outlined, size: 18, color: AppColors.accentLight),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Practice reminder', style: AppTextStyles.bodyPrimary),
                      const SizedBox(height: 2),
                      Text('A nudge if you haven\'t practiced yet', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                Switch(
                  value: _reminderEnabled,
                  onChanged: _isSaving ? null : (v) => _save(reminderEnabled: v),
                  activeColor: AppColors.accentPrimary,
                ),
              ],
            ),
          ),
          if (_reminderEnabled) ...[
            Divider(height: 1, color: AppColors.border, thickness: 0.5, indent: 16, endIndent: 16),
            InkWell(
              onTap: _isSaving ? null : _pickReminderTime,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 18, color: AppColors.accentLight),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Reminder time', style: AppTextStyles.bodyPrimary)),
                    Text(_reminderTime.format(context), style: AppTextStyles.bodySecondary),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.cardTintNeutral,
        borderRadius: BorderRadius.circular(12),
        border: AppGradients.cardBorder(AppColors.accentPrimary),
        boxShadow: AppGradients.cardGlow(AppColors.accentPrimary),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 18, color: AppColors.accentLight),
            const SizedBox(width: 12),
            Expanded(child: Text('Version', style: AppTextStyles.bodyPrimary)),
            Text('1.0.0', style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }
}
