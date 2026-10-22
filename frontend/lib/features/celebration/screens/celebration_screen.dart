import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CelebrationScreen extends StatelessWidget {
  const CelebrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF26194D), Color(0xFF131317)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFE6DEFF), Color(0xFFFCF8FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Hero Trophy Badge
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1EB),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5E36).withOpacity(0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 60,
                      color: Color(0xFFE6A100),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Headline
                Text(
                  'Daily Triumph!',
                  style: AppTypography.displayLarge(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All core daily habits completed with discipline.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // XP & Streak Summary Card
                AuroraCard(
                  hasAuroraBorder: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            '+100 XP',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Earned Today',
                            style: AppTypography.labelMedium(),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.local_fire_department, color: AppColors.streakFire, size: 20),
                              SizedBox(width: 4),
                              Text(
                                '15 Days',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.streakFire,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Streak Active',
                            style: AppTypography.labelMedium(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),

                // Actions
                HabitButton(
                  label: 'Back to Today Dashboard',
                  onPressed: () => context.go('/today'),
                ),
                const SizedBox(height: 12),
                HabitButton(
                  label: 'Record in Daily Journal',
                  variant: HabitButtonVariant.outline,
                  icon: Icons.edit_note_rounded,
                  onPressed: () => context.go('/journal'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
