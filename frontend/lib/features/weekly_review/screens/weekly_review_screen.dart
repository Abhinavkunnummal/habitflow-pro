import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/aurora_progress_ring.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class WeeklyReviewScreen extends StatelessWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weekly Review',
          style: AppTypography.headline(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/insights'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Consistency Gauge
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const AuroraProgressRing(
                      progress: 0.86,
                      completedCount: 24,
                      totalCount: 28,
                      size: 110,
                      strokeWidth: 10,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '86% Weekly Rhythm',
                            style: AppTypography.headline(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '24 of 28 habits completed. Strongest momentum in morning blocks.',
                            style: AppTypography.labelMedium(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // AI Coach Synthesis
              AuroraCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.psychology_rounded, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coach Observation',
                            style: AppTypography.titleMedium(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ).copyWith(fontSize: 14),
                          ),
                          Text(
                            'Hydration was 100% consistent. Reading experienced friction on Thursday evening.',
                            style: AppTypography.labelMedium(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3 Commitments for Next Week
              Text(
                'Next Week Commitments',
                style: AppTypography.headline(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 10),
              AuroraCard(
                child: Column(
                  children: [
                    _buildCommitmentItem('1. Read 20 pages right after morning coffee', isDark),
                    const Divider(height: 16),
                    _buildCommitmentItem('2. Prepare gym clothes the night before', isDark),
                    const Divider(height: 16),
                    _buildCommitmentItem('3. Start phone quiet hours by 10:15 PM', isDark),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              HabitButton(
                label: 'Commit to Next Week',
                onPressed: () => context.go('/today'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommitmentItem(String text, bool isDark) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
