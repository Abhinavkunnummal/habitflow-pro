import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

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
        // Brand Flame & Flow Emblem
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF5D3ADC), // Violet
                Color(0xFF7657F6),
                Color(0xFF006C4B), // Emerald
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Lotus Flame left wing
              Positioned(
                left: size * 0.22,
                top: size * 0.24,
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: size * 0.55,
                  color: AppColors.streakFire,
                ),
              ),
              // Mindful Mint drop overlay
              Positioned(
                right: size * 0.22,
                bottom: size * 0.22,
                child: Icon(
                  Icons.water_drop_rounded,
                  size: size * 0.48,
                  color: AppColors.secondaryFixed,
                ),
              ),
              // Center Brilliance Sparkle
              Icon(
                Icons.auto_awesome,
                size: size * 0.32,
                color: Colors.white,
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
