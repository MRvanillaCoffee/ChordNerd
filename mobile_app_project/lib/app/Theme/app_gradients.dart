import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable gradients for the "colorful" treatment — pink/mint mixed
/// together rather than used as flat single-color blocks.
class AppGradients {
  AppGradients._();

  static const LinearGradient avatar = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentPrimary, AppColors.accentStreak],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentPrimary, Color(0xFFE0A8E8)],
  );

  static const LinearGradient streakCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A2233), Color(0xFF1D2E27)],
  );

  static const LinearGradient statCardPink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A2A44), AppColors.surfaceSelected],
  );

  static const LinearGradient statCardMint = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1D3A2E), Color(0xFF16241E)],
  );

  // Subtle tints for list-style content (search results, library cards,
  // menu rows) so flat surfaces aren't left fully neutral.
  static const LinearGradient cardTintPink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF241A22), Color(0xFF16151B)],
  );

  static const LinearGradient cardTintMint = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF16241E), Color(0xFF16151B)],
  );

  static const LinearGradient cardTintNeutral = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF201A24), Color(0xFF1A1E24)],
  );
}
