import 'package:flutter/material.dart';

/// One full set of color tokens — Chord Nerd has a light set and a dark
/// set, both built from the same pink/mint identity.
class AppColorScheme {
  final Color background;
  final Color surfaceInput;
  final Color surfaceCard;
  final Color surfaceSelected;
  final Color border;
  final Color chartInactive;
  final Color accentPrimary;
  final Color accentLight;
  final Color accentStreak;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color onAccentPrimary;
  final Color badgeBgPink;
  final Color badgeBgMint;

  const AppColorScheme({
    required this.background,
    required this.surfaceInput,
    required this.surfaceCard,
    required this.surfaceSelected,
    required this.border,
    required this.chartInactive,
    required this.accentPrimary,
    required this.accentLight,
    required this.accentStreak,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.onAccentPrimary,
    required this.badgeBgPink,
    required this.badgeBgMint,
  });
}

/// Chord Nerd color tokens. Call sites keep using `AppColors.background`,
/// `AppColors.accentPrimary`, etc. exactly as before — these are now
/// getters that read from whichever scheme (light/dark) is currently
/// active, so the whole app can switch live via [AppColors.mode].
class AppColors {
  AppColors._();

  /// Default is light. Call `AppColors.setDark(true)` or `.toggle()` to
  /// switch — listen to `AppColors.mode` (a ValueNotifier) to rebuild
  /// the app when it changes (see main.dart).
  static final ValueNotifier<bool> mode = ValueNotifier<bool>(false);

  static bool get isDark => mode.value;

  static void setDark(bool isDark) => mode.value = isDark;

  static void toggle() => mode.value = !mode.value;

  static AppColorScheme get _scheme => isDark ? dark : light;

  // ---------------------------------------------------------------------
  // Light scheme (default)
  // ---------------------------------------------------------------------
  static const AppColorScheme light = AppColorScheme(
    background: Color(0xFFFAF9FB),
    surfaceInput: Color(0xFFF1EEF4),
    surfaceCard: Color(0xFFFFFFFF),
    surfaceSelected: Color(0xFFF6E3EE),
    border: Color(0xFFE6E0EA),
    chartInactive: Color(0xFFE9E3EC),
    accentPrimary: Color(0xFFE0559C),
    accentLight: Color(0xFFF6B9D8),
    accentStreak: Color(0xFF1FAE7E),
    textPrimary: Color(0xFF1C1723),
    textSecondary: Color(0xFF6C6675),
    textMuted: Color(0xFF9C97A4),
    onAccentPrimary: Color(0xFFFFFFFF),
    badgeBgPink: Color(0xFFFBE1EE),
    badgeBgMint: Color(0xFFDDF5EA),
  );

  // ---------------------------------------------------------------------
  // Dark scheme (optional, toggled on)
  // ---------------------------------------------------------------------
  static const AppColorScheme dark = AppColorScheme(
    background: Color(0xFF000000),
    surfaceInput: Color(0xFF131217),
    surfaceCard: Color(0xFF16151B),
    surfaceSelected: Color(0xFF241E26),
    border: Color(0xFF2A2830),
    chartInactive: Color(0xFF332C36),
    accentPrimary: Color(0xFFF98CBB),
    accentLight: Color(0xFFFCB8D6),
    accentStreak: Color(0xFF65E3B5),
    textPrimary: Color(0xFFF2F1F4),
    textSecondary: Color(0xFF9E9BA8),
    textMuted: Color(0xFF6B6874),
    onAccentPrimary: Color(0xFF1A1420),
    badgeBgPink: Color(0xFF3A2233),
    badgeBgMint: Color(0xFF1D3A2E),
  );

  // ---------------------------------------------------------------------
  // Facade — existing call sites (AppColors.background, etc.) are
  // unchanged; they now resolve dynamically against the active scheme.
  // ---------------------------------------------------------------------
  static Color get background => _scheme.background;
  static Color get surfaceInput => _scheme.surfaceInput;
  static Color get surfaceCard => _scheme.surfaceCard;
  static Color get surfaceSelected => _scheme.surfaceSelected;
  static Color get border => _scheme.border;
  static Color get chartInactive => _scheme.chartInactive;
  static Color get accentPrimary => _scheme.accentPrimary;
  static Color get accentLight => _scheme.accentLight;
  static Color get accentStreak => _scheme.accentStreak;
  static Color get textPrimary => _scheme.textPrimary;
  static Color get textSecondary => _scheme.textSecondary;
  static Color get textMuted => _scheme.textMuted;
  static Color get onAccentPrimary => _scheme.onAccentPrimary;
  static Color get badgeBgPink => _scheme.badgeBgPink;
  static Color get badgeBgMint => _scheme.badgeBgMint;
}
