import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_text_styles.dart';
import '../../models/user_profile.dart';
import '../../services/database_service.dart';

/// Lets the signed-in user edit their display name and skill level.
/// Opened from Profile's "Edit profile" row. Pops with `true` on a
/// successful save so Profile knows to show a confirmation.
class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late String _skillLevel;
  bool _isSaving = false;

  static const _skillLevels = ['beginner', 'intermediate', 'advanced'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _skillLevel = _skillLevels.contains(widget.profile.skillLevel) ? widget.profile.skillLevel : 'beginner';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    await DatabaseService.updateProfile(
      uid: widget.profile.uid,
      name: name,
      skillLevel: _skillLevel,
    );

    if (mounted) {
      Navigator.of(context).pop(true);
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
        title: Text('Edit profile', style: AppTextStyles.h2),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('Name', style: AppTextStyles.label),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                style: AppTextStyles.bodyPrimary,
                decoration: const InputDecoration(hintText: 'Your name'),
              ),
              const SizedBox(height: 20),
              Text('Skill level', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _buildSkillLevelPicker(),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _isSaving ? null : _save,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: _isSaving
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onAccentPrimary),
                              )
                            : Text('Save', style: AppTextStyles.buttonLabel),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillLevelPicker() {
    return Row(
      children: _skillLevels.map((level) {
        final isSelected = _skillLevel == level;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: level != _skillLevels.last ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _skillLevel = level),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surfaceSelected : AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected ? AppGradients.cardBorder(AppColors.accentPrimary) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  level[0].toUpperCase() + level.substring(1),
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: isSelected ? AppColors.accentLight : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
