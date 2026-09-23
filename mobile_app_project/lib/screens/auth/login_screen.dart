import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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

    try {
      await AuthService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      _showMessage('Logged in successfully', isError: false);
    } on FirebaseAuthException catch (e) {
      _showMessage(_friendlyAuthError(e), isError: true);
    } catch (e) {
      _showMessage('Something went wrong. Please try again.', isError: true);
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.bodyPrimary),
        backgroundColor: isError ? AppColors.surfaceCard : AppColors.surfaceSelected,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Login failed. Please try again.';
    }
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await AuthService.signInWithGoogle();
      _showMessage('Logged in with Google', isError: false);
    } on FirebaseAuthException catch (e) {
      debugPrint('[google] FirebaseAuthException: ${e.code} — ${e.message}');
      _showMessage(_friendlyAuthError(e), isError: true);
    } catch (e) {
      debugPrint('[google] unexpected error: $e');
      _showMessage('Google sign-in failed. Please try again.', isError: true);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    try {
      await AuthService.signInWithFacebook();
      _showMessage('Logged in with Facebook', isError: false);
    } on FirebaseAuthException catch (e) {
      debugPrint('[facebook] FirebaseAuthException: ${e.code} — ${e.message}');
      _showMessage(_friendlyAuthError(e), isError: true);
    } catch (e) {
      debugPrint('[facebook] unexpected error: $e');
      _showMessage('Facebook sign-in failed. Please try again.', isError: true);
    }
  }

  Future<void> _handleGitHubSignIn() async {
    try {
      await AuthService.signInWithGitHub();
      _showMessage('Logged in with GitHub', isError: false);
    } on FirebaseAuthException catch (e) {
      debugPrint('[github] FirebaseAuthException: ${e.code} — ${e.message}');
      _showMessage(_friendlyAuthError(e), isError: true);
    } catch (e) {
      debugPrint('[github] unexpected error: $e');
      _showMessage('GitHub sign-in failed. Please try again.', isError: true);
    }
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
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 10),
              _buildForgotPassword(),
              const SizedBox(height: 22),
              _buildSubmitButton(),
              const SizedBox(height: 16),
              _buildSignUpLink(),
              const SizedBox(height: 14),
              _buildStreakTeaser(),
              const SizedBox(height: 18),
              _buildDivider(),
              const SizedBox(height: 18),
              _buildGoogleButton(),
              const SizedBox(height: 10),
              _buildFacebookButton(),
              const SizedBox(height: 10),
              _buildGitHubButton(),
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

  Widget _buildSignUpLink() {
    return GestureDetector(
      onTap: _goToRegister,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTextStyles.bodySecondary,
          children: [
            const TextSpan(text: "Don't have an account? "),
            TextSpan(
              text: 'Sign up',
              style: TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.w500),
            ),
          ],
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
          : const Text('Log in'),
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

  Widget _buildFacebookButton() {
    return OutlinedButton(
      onPressed: _handleFacebookSignIn,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border, width: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.facebook_rounded, size: 20, color: AppColors.accentLight),
          const SizedBox(width: 6),
          Text('Continue with Facebook', style: AppTextStyles.bodyPrimary),
        ],
      ),
    );
  }

  Widget _buildGitHubButton() {
    return OutlinedButton(
      onPressed: _handleGitHubSignIn,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border, width: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.code_rounded, size: 18, color: AppColors.accentLight),
          const SizedBox(width: 6),
          Text('Continue with GitHub', style: AppTextStyles.bodyPrimary),
        ],
      ),
    );
  }
}