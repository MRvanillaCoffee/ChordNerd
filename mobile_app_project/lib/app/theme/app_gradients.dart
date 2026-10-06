import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable gradients — pink/mint mixed together rather than flat single
/// colors. Every gradient here branches on AppColors.isDark so it works
/// correctly in both themes.
class AppGradients {
  AppGradients._();

  static LinearGradient get avatar => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.accentPrimary, AppColors.accentStreak],
      );

  static LinearGradient get primaryButton => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accentPrimary,
          AppColors.isDark ? const Color(0xFFE0A8E8) : const Color(0xFFF0A0D0),
        ],
      );

  static LinearGradient get streakCard => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.isDark
            ? const [Color(0xFF3A2233), Color(0xFF1D2E27)]
            : const [Color(0xFFFDEAF2), Color(0xFFE3F7EC)],
      );

  static LinearGradient get statCardPink => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.isDark
            ? [const Color(0xFF3A2A44), AppColors.surfaceSelected]
            : const [Color(0xFFFCE4F0), Color(0xFFF6EEF8)],
      );

  static LinearGradient get statCardMint => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.isDark
            ? const [Color(0xFF1D3A2E), Color(0xFF16241E)]
            : const [Color(0xFFE1F7ED), Color(0xFFEFF6F1)],
      );

  // Subtle tints for list-style content (search results, library cards,
  // menu rows) — bright enough to visibly lift off the background in
  // either theme.
  static LinearGradient get cardTintPink => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.isDark
            ? const [Color(0xFF35222E), Color(0xFF201C24)]
            : const [Color(0xFFFDEFF5), Color(0xFFFFFFFF)],
      );

  static LinearGradient get cardTintMint => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.isDark
            ? const [Color(0xFF1B3327), Color(0xFF1C201F)]
            : const [Color(0xFFE8F8F0), Color(0xFFFFFFFF)],
      );

  static LinearGradient get cardTintNeutral => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.isDark
            ? const [Color(0xFF2B2230), Color(0xFF23222C)]
            : const [Color(0xFFF3EEF7), Color(0xFFF5F3F8)],
      );

  // Shared "pop out" treatment for cards — a solid colored shadow plus a
  // solid matching border (no transparency).
  static List<BoxShadow> cardGlow(Color color) => [
        BoxShadow(
          color: color,
          blurRadius: 10,
          spreadRadius: -6,
          offset: const Offset(0, 5),
        ),
      ];

  static Border cardBorder(Color color) => Border.all(
        color: color,
        width: 1,
      );
}
