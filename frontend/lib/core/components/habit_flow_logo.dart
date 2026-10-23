import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable brand logo featuring the triumphant Success Tic / Checkmark achievement emblem
class HabitFlowLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const HabitFlowLogo({
    super.key,
    this.size = 54,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success Tic & Achievement Crest
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF006C4B), // Emerald Success
                Color(0xFF5D3ADC), // Aurora Violet
                Color(0xFF7657F6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.32),
            border: Border.all(color: AppColors.secondaryFixed.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.4),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Golden Achievement Star at top right
              Positioned(
                top: size * 0.14,
                right: size * 0.14,
                child: Icon(
                  Icons.star_rounded,
                  size: size * 0.28,
                  color: const Color(0xFFFFD700),
                ),
              ),
              // Triumphant Success Tick (Tic)
              Icon(
                Icons.check_circle_rounded,
                size: size * 0.62,
                color: AppColors.secondaryFixed,
              ),
            ],
          ),
        ),

        if (showText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'HabitFlow',
                    style: AppTypography.displayMedium(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ).copyWith(
                      fontSize: size * 0.42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Compound Daily Momentum',
                style: AppTypography.labelMedium(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
