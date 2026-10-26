import 'package:flutter/material.dart';

/// Design tokens extracted directly from the Stitch HabitFlow Pro project
/// Theme: "Forest Calm Habit Flow" / "Aurora Glow"
class AppColors {
  AppColors._();

  // Primary: Hero Deep Violet
  static const Color primary = Color(0xFF5D3ADC);
  static const Color primaryContainer = Color(0xFF7657F6);
  static const Color primaryFixed = Color(0xFFE6DEFF);
  static const Color primaryFixedDim = Color(0xFFC7B8FF);

  // Secondary: Forest Emerald & Fresh Mint
  static const Color secondary = Color(0xFF006C4B);
  static const Color secondaryFixed = Color(0xFF79FAC2); // Brand Mint
  static const Color secondaryFixedDim = Color(0xFF5BDDA7);
  static const Color secondaryContainer = Color(0xFF5BDDA7);
  static const Color secondaryLight = Color(0xFFE3FBEF);

  // Tertiary: Warm Terracotta & Peach
  static const Color tertiary = Color(0xFF844D2A);
  static const Color tertiaryFixed = Color(0xFFFFDBC9);
  static const Color tertiaryContainer = Color(0xFFA16540);
  static const Color tertiaryLight = Color(0xFFFFF3ED);

  // Neutral Surfaces (Light Mode)
  static const Color background = Color(0xFFFCF8FF);
  static const Color surface = Color(0xFFFCF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F2FA);
  static const Color surfaceContainer = Color(0xFFF1ECF5);
  static const Color surfaceContainerHigh = Color(0xFFEBE6EF);
  static const Color surfaceContainerHighest = Color(0xFFE5E0E9);

  // Neutral Surfaces (Dark Mode)
  static const Color darkBackground = Color(0xFF131317);
  static const Color darkSurface = Color(0xFF1F1E26);
  static const Color darkSurfaceContainerLow = Color(0xFF262530);
  static const Color darkSurfaceContainer = Color(0xFF2D2B37);
  static const Color darkSurfaceContainerHigh = Color(0xFF383544);

  // Text / Content
  static const Color textPrimary = Color(0xFF1B1B21);
  static const Color textSecondary = Color(0xFF47464F);
  static const Color textTertiary = Color(0xFF787680);
  static const Color textOnPrimary = Colors.white;

  static const Color darkTextPrimary = Color(0xFFE4E1EC);
  static const Color darkTextSecondary = Color(0xFFC8C5D0);
  static const Color darkTextTertiary = Color(0xFF928F9A);

  // Accent & Functional
  static const Color streakFire = Color(0xFFFF5E36);
  static const Color success = Color(0xFF006C4B);
  static const Color warning = Color(0xFFE6A100);
  static const Color error = Color(0xFFBA1A1A);

  // Aurora Gradients
  static const LinearGradient auroraGradient = LinearGradient(
    colors: [primary, primaryContainer, secondaryFixed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGaugeGradient = LinearGradient(
    colors: [primary, secondaryFixed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF5D3ADC), Color(0xFF3A1F9E), Color(0xFF131317)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF262530), Color(0xFF1F1E26)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
