import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

// TODO: import '../../services/auth_service.dart' once built, and call
// AuthService.signInWithEmail / signUpWithEmail / signInWithGoogle from
// the button handlers below instead of the placeholder prints.

enum _AuthMode { login, signUp }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    // TODO: replace with real auth calls, e.g.:
    // if (_mode == _AuthMode.login) {
    //   await AuthService.signInWithEmail(_emailController.text, _passwordController.text);
    // } else {
    //   await AuthService.signUpWithEmail(_emailController.text, _passwordController.text);
    // }

    await Future.delayed(const Duration(milliseconds: 600)); // placeholder

    if (mounted) setState(() => _isSubmitting = false);
  }

  Future<void> _handleGoogleSignIn() async {
    // TODO: call AuthService.signInWithGoogle()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 36),
              _buildModeToggle(),
              const SizedBox(height: 24),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 10),
              if (_mode == _AuthMode.login) _buildForgotPassword(),
              const SizedBox(height: 22),
              _buildSubmitButton(),
              const SizedBox(height: 14),
              _buildStreakTeaser(),
              const SizedBox(height: 18),
              _buildDivider(),
              const SizedBox(height: 18),
              _buildGoogleButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.music_note_rounded,
            color: AppColors.accentPrimary,
            size: 26,
          ),
        ),
        const SizedBox(height: 14),
        Text('Chord Nerd', style: AppTextStyles.logo),
        const SizedBox(height: 4),
        Text(
          'Practice in the dark, sound in the light',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: _buildModeTab('Log in', _AuthMode.login)),
          Expanded(child: _buildModeTab('Sign up', _AuthMode.signUp)),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, _AuthMode mode) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyPrimary.copyWith(
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email', style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.bodyPrimary,
          decoration: const InputDecoration(hintText: 'name@email.com'),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password', style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: AppTextStyles.bodyPrimary,
          decoration: InputDecoration(
            hintText: '••••••••••',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
                size: 18,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          // TODO: navigate to forgot-password flow
        },
        child: Text(
          'Forgot password?',
          style: AppTextStyles.label.copyWith(color: AppColors.accentPrimary),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _handleSubmit,
      child: _isSubmitting
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.onAccentPrimary,
              ),
            )
          : Text(_mode == _AuthMode.login ? 'Log in' : 'Create account'),
    );
  }

  Widget _buildStreakTeaser() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.accentStreak),
        const SizedBox(width: 6),
        Text('3-day streak waiting for you', style: AppTextStyles.streakLabel),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('or continue with', style: AppTextStyles.caption),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton(
      onPressed: _handleGoogleSignIn,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border, width: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.g_mobiledata_rounded, size: 20, color: AppColors.accentLight),
          const SizedBox(width: 6),
          Text('Continue with Google', style: AppTextStyles.bodyPrimary),
        ],
      ),
    );
  }
}
