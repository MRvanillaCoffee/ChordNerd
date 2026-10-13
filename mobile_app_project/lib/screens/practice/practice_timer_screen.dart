import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_text_styles.dart';
import '../../services/database_service.dart';

/// A running stopwatch for a practice session. Opened from Dashboard's
/// "Start practice session" button; logs the elapsed time via
/// DatabaseService.logPracticeSession when the user ends the session,
/// replacing the old placeholder that just logged a flat 15 minutes.
class PracticeTimerScreen extends StatefulWidget {
  final String uid;

  const PracticeTimerScreen({super.key, required this.uid});

  @override
  State<PracticeTimerScreen> createState() => _PracticeTimerScreenState();
}

class _PracticeTimerScreenState extends State<PracticeTimerScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  bool _isRunning = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _resume();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _pause() {
    _stopwatch.stop();
    _ticker?.cancel();
    setState(() => _isRunning = false);
  }

  void _resume() {
    _stopwatch.start();
    _isRunning = true;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  String get _formatted {
    final totalSeconds = _stopwatch.elapsed.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _endSession() async {
    _stopwatch.stop();
    _ticker?.cancel();

    final totalSeconds = _stopwatch.elapsed.inSeconds;
    // Round to the nearest minute, but count at least 1 minute if they
    // practiced at all (even a short burst), so it still shows up.
    final minutes = totalSeconds <= 0
        ? 0
        : totalSeconds < 30
            ? 1
            : (totalSeconds / 60).round();

    if (minutes <= 0) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);
    await DatabaseService.logPracticeSession(uid: widget.uid, minutes: minutes);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logged $minutes ${minutes == 1 ? 'minute' : 'minutes'} of practice',
            style: AppTextStyles.bodyPrimary,
          ),
          backgroundColor: AppColors.surfaceCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _confirmDiscard() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text(
          'Discard this session?',
          style: AppTextStyles.bodyPrimary.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Text("Your practice time won't be saved.", style: AppTextStyles.bodySecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Keep practicing', style: AppTextStyles.bodyPrimary.copyWith(color: AppColors.accentPrimary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Discard', style: AppTextStyles.bodyPrimary.copyWith(color: AppColors.accentStreak)),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: AppColors.textPrimary),
            onPressed: _confirmDiscard,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Practicing', style: AppTextStyles.bodySecondary),
                const SizedBox(height: 12),
                Text(
                  _formatted,
                  style: AppTextStyles.h1.copyWith(fontSize: 56, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 40),
                _circleButton(
                  icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  onTap: _isRunning ? _pause : _resume,
                  bg: AppColors.accentPrimary,
                  iconColor: AppColors.onAccentPrimary,
                  size: 72,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryButton,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _isSaving ? null : _endSession,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: _isSaving
                                ? SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onAccentPrimary,
                                    ),
                                  )
                                : Text('End session', style: AppTextStyles.buttonLabel),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color bg,
    required Color iconColor,
    required double size,
  }) {
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: iconColor, size: size * 0.42),
        ),
      ),
    );
  }
}
