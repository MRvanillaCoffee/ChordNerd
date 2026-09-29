import 'package:flutter/material.dart';

/// Chord Nerd color palette — dark theme, pastel pink + soft mint accents.
/// Reference: StringTracker_Color_Palette.md
class AppColors {
  AppColors._();

  // Backgrounds & surfaces
  static const Color background = Color(0xFF000000);
  static const Color surfaceInput = Color(0xFF131217);
  static const Color surfaceCard = Color(0xFF16151B);
  static const Color surfaceSelected = Color(0xFF241E26);
  static const Color border = Color(0xFF2A2830);

  // Chart / secondary fill (used for inactive bars, subtle blocks)
  static const Color chartInactive = Color(0xFF332C36);

  // Accents
  static const Color accentPrimary = Color(0xFFF3B8CE); // buttons, links, active states — pastel pink
  static const Color accentLight = Color(0xFFF7D3E2); // icons, subtle highlights (lighter pink)
  static const Color accentStreak = Color(0xFF9DE0C4); // streaks, success, positive moments — soft mint

  // Text
  static const Color textPrimary = Color(0xFFF2F1F4);
  static const Color textSecondary = Color(0xFF9E9BA8);
  static const Color textMuted = Color(0xFF6B6874);

  // On-accent (text/icons placed on top of accentPrimary, e.g. primary button label)
  static const Color onAccentPrimary = Color(0xFF1A1420);
}