import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chord_nerd/app/Theme/app_colors.dart';
import 'package:chord_nerd/app/Theme/app_text_styles.dart';
import '../../services/auth_service.dart';

enum SkillLevel { beginner, intermediate, advanced }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  SkillLevel _skillLevel = SkillLevel.beginner;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorText = null);

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorText = "Passwords don't match");
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _errorText = 'Password must be at least 6 characters');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      debugPrint('[register] creating account...');
      await AuthService.registerWithEmail(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        skillLevel: _skillLevel.name,
      );
      debugPrint('[register] success');
      _showMessage('Account created successfully', isError: false);
    } on FirebaseAuthException catch (e) {
      debugPrint('[register] FirebaseAuthException: ${e.code} — ${e.message}');
      _showMessage(_friendlyAuthError(e), isError: true);
    } catch (e) {
      debugPrint('[register] unexpected error: $e');
      _showMessage('Something went wrong. Please try again.', isError: true);
    } finally {
      // Guarantees the spinner always stops, even if something above
      // throws a type we didn't anticipate.
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.bodyPrimary),
        backgroundColor:
            isError ? AppColors.surfaceCard : AppColors.surfaceSelected,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with that email already exists.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      default:
        return e.message ?? 'Registration failed. Please try again.';
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create your account', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text(
                'Start tracking your practice tonight',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 28),
              _buildField(
                label: 'Name',
                controller: _nameController,
                hint: 'Your name',
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Email',
                controller: _emailController,
                hint: 'name@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'Password',
                controller: _passwordController,
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'Confirm password',
                controller: _confirmPasswordController,
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 20),
              Text('Skill level', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _buildSkillLevelSelector(),
              if (_errorText != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorText!,
                  style: AppTextStyles.bodySecondary
                      .copyWith(color: AppColors.accentStreak),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleRegister,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onAccentPrimary,
                        ),
                      )
                    : const Text('Create account'),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.bodySecondary,
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Log in',
                        style: TextStyle(
                            color: AppColors.accentPrimary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyPrimary,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppTextStyles.bodyPrimary,
          decoration: InputDecoration(
            hintText: '••••••••••',
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
                size: 18,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillLevelSelector() {
    return Row(
      children: SkillLevel.values.map((level) {
        final isSelected = _skillLevel == level;
        final label = switch (level) {
          SkillLevel.beginner => 'Beginner',
          SkillLevel.intermediate => 'Intermediate',
          SkillLevel.advanced => 'Advanced',
        };
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _skillLevel = level),
            child: Container(
              margin:
                  EdgeInsets.only(right: level != SkillLevel.advanced ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.surfaceSelected
                    : AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      isSelected ? AppColors.accentPrimary : AppColors.border,
                  width: isSelected ? 1 : 0.5,
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary.copyWith(
                  color:
                      isSelected ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
