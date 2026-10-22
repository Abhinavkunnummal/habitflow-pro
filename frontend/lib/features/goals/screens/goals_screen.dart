import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Goals & Quests',
          style: AppTypography.headline(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go('/goals/new'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Level & XP Bento Header
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF1EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: Color(0xFFE6A100),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Level 6 Flow Master',
                                  style: AppTypography.headline(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ).copyWith(fontSize: 16),
                                ),
                                Text(
                                  '1,450 / 2,000 XP to Level 7',
                                  style: AppTypography.labelMedium(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: const Text(
                            '+50 XP Today',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: 1450 / 2000,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceContainerHigh
                          : AppColors.surfaceContainerHigh,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Weekly Quest Challenge
              Text(
                'Active Weekly Quest',
                style: AppTypography.headline(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 10),
              AuroraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Perfect Morning Week',
                          style: AppTypography.titleMedium(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          '4 / 5 Days',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete hydration and reading 5 days this week.',
                      style: AppTypography.labelMedium(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: List.generate(5, (index) {
                        final isComplete = index < 4;
                        return Expanded(
                          child: Container(
                            height: 8,
                            margin: EdgeInsets.only(right: index < 4 ? 6 : 0),
                            decoration: BoxDecoration(
                              color: isComplete
                                  ? AppColors.secondaryFixed
                                  : (isDark
                                      ? AppColors.darkSurfaceContainerHigh
                                      : AppColors.surfaceContainerHigh),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Trophy Showcase
              Text(
                'Trophy Cabinet',
                style: AppTypography.headline(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildTrophy('7-Day Streak', Icons.local_fire_department, true, isDark),
                  _buildTrophy('14-Day Streak', Icons.bolt, true, isDark),
                  _buildTrophy('Hydration Pro', Icons.water_drop, true, isDark),
                  _buildTrophy('Deep Scholar', Icons.menu_book, true, isDark),
                  _buildTrophy('30-Day Legend', Icons.shield, false, isDark),
                  _buildTrophy('Century Club', Icons.military_tech, false, isDark),
                ],
              ),
              const SizedBox(height: 24),

              HabitButton(
                label: 'Create New Goal',
                icon: Icons.add_rounded,
                onPressed: () => context.go('/goals/new'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrophy(String name, IconData icon, bool unlocked, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked
            ? (isDark ? AppColors.darkSurfaceContainer : Colors.white)
            : (isDark ? AppColors.darkSurface : AppColors.surfaceContainerHigh),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? AppColors.secondaryFixed.withOpacity(0.5)
              : (isDark ? AppColors.darkSurfaceContainerHigh : AppColors.surfaceContainerHigh),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: unlocked ? const Color(0xFFE6A100) : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: unlocked
                  ? (isDark ? Colors.white : Colors.black87)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
