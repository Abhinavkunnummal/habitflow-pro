import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/goals_provider.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goals = ref.watch(goalsProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final userLevel = user?.level ?? 6;
    final userXp = user?.xp ?? 1450;
    final targetXp = userLevel * 300;
    final double levelProgress = (targetXp > 0)
        ? (userXp % 300) / 300.0
        : 0.5;

    final activeGoals = goals.where((g) => g.status != 'archived').toList();

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
                                  'Level $userLevel Flow Master',
                                  style: AppTypography.headline(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ).copyWith(fontSize: 16),
                                ),
                                Text(
                                  '$userXp XP Total',
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
                      value: levelProgress.clamp(0.05, 1.0),
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

              // Active Horizon Goals Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Goals & Quests',
                    style: AppTypography.headline(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ).copyWith(fontSize: 18),
                  ),
                  Text(
                    '${activeGoals.length} Active',
                    style: AppTypography.labelMedium(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (activeGoals.isEmpty)
                AuroraCard(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.flag_outlined, size: 40, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          'No horizon goals created yet.',
                          style: AppTypography.titleMedium(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Set a 7, 30, or 100-day milestone to accelerate your streaks.',
                          textAlign: TextAlign.center,
                          style: AppTypography.labelMedium(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...activeGoals.map((goal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AuroraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  goal.title,
                                  style: AppTypography.titleMedium(
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: goal.tier == 'Gold'
                                      ? Colors.amber.withOpacity(0.2)
                                      : (goal.tier == 'Bronze'
                                          ? Colors.brown.withOpacity(0.2)
                                          : Colors.blueGrey.withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${goal.currentProgress} / ${goal.targetValue} ${goal.targetUnit}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (goal.description != null && goal.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              goal.description!,
                              style: AppTypography.labelMedium(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          LinearProgressIndicator(
                            value: goal.progressPercentage,
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceContainerHigh
                                : AppColors.surfaceContainerHigh,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              goal.isCompleted ? AppColors.secondary : AppColors.primary,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 16),

              // Trophy Cabinet
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
