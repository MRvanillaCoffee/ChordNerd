import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Chord Nerd's app-wide ThemeData, built from AppColors + AppTextStyles.
/// AppColors.background/accentPrimary/etc. are reactive getters (light by
/// default, dark when AppColors.mode is toggled), so this ThemeData is
/// rebuilt fresh each time the mode changes rather than being const.
class AppTheme {
  AppTheme._();

  static ThemeData get current {
    final brightness = AppColors.isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Manrope',

      colorScheme: ColorScheme(
        brightness: brightness,
        surface: AppColors.background,
        primary: AppColors.accentPrimary,
        secondary: AppColors.accentStreak,
        onPrimary: AppColors.onAccentPrimary,
        onSurface: AppColors.textPrimary,
        error: AppColors.accentStreak,
        onError: AppColors.onAccentPrimary,
        onSecondary: AppColors.onAccentPrimary,
      ),

      textTheme: TextTheme(
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        bodyLarge: AppTextStyles.bodyPrimary,
        bodyMedium: AppTextStyles.bodySecondary,
        labelLarge: AppTextStyles.label,
        labelSmall: AppTextStyles.caption,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleTextStyle: AppTextStyles.logo,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: AppColors.onAccentPrimary,
          textStyle: AppTextStyles.buttonLabel,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        hintStyle: AppTextStyles.bodyPrimary.copyWith(color: AppColors.textMuted),
        labelStyle: AppTextStyles.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.accentPrimary, width: 1),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.accentPrimary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: AppTextStyles.navLabel.copyWith(color: AppColors.accentPrimary),
        unselectedLabelStyle: AppTextStyles.navLabel,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
      ),
    );
  }
}
