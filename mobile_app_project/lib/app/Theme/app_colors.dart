import 'package:flutter/material.dart';

/// Chord Nerd color palette — dark theme, two-tone violet/pink accents.
/// Reference: StringTracker_Color_Palette.md
class AppColors {
  AppColors._();

  // Backgrounds & surfaces
  static const Color background = Color(0xFF0A0A0B);
  static const Color surfaceInput = Color(0xFF141416);
  static const Color surfaceCard = Color(0xFF18181B);
  static const Color surfaceSelected = Color(0xFF2A2233);
  static const Color border = Color(0xFF2B2B30);

  // Chart / secondary fill (used for inactive bars, subtle blocks)
  static const Color chartInactive = Color(0xFF3A3140);

  // Accents
  static const Color accentPrimary = Color(0xFF9D7BFF); // buttons, links, active states
  static const Color accentLight = Color(0xFFC9AEFF); // icons, subtle highlights
  static const Color accentStreak = Color(0xFFFF8FCB); // streaks, badges — use sparingly

  // Text
  static const Color textPrimary = Color(0xFFF2F2F3);
  static const Color textSecondary = Color(0xFF9C9BA2);
  static const Color textMuted = Color(0xFF6B6A70);

  // On-accent (text/icons placed on top of accentPrimary, e.g. primary button label)
  static const Color onAccentPrimary = background;
}