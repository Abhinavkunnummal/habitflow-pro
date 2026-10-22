import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle displayLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: color,
      );

  static TextStyle displayMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.manrope(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle headline({Color color = AppColors.textPrimary}) =>
      GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle titleMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.manrope(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle bodyLarge({Color color = AppColors.textSecondary}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium({Color color = AppColors.textSecondary}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle labelMedium({Color color = AppColors.textTertiary}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle button({Color color = Colors.white}) =>
      GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: color,
      );
}
