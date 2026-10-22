import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/components/streak_badge.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../dashboard/providers/habits_provider.dart';

class HabitDetailsScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailsScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habits = ref.watch(habitsProvider);
    final logsNotifier = ref.watch(habitLogsProvider.notifier);
    final selectedDate = ref.watch(selectedDateProvider);

    final habit = habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => habits.first,
    );

    final isCompleted = logsNotifier.isCompleted(habit.id, selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          habit.title,
          style: AppTypography.headline(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/today'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/habit/$habitId/edit'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Status Card
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            habit.category,
                            style: AppTypography.labelMedium(
                              color: AppColors.primary,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        StreakBadge(streakDays: habit.streak),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      habit.title,
                      style: AppTypography.displayMedium(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (habit.description != null &&
                        habit.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        habit.description!,
                        style: AppTypography.bodyMedium(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    // Today Completion Toggle CTA
                    HabitButton(
                      label: isCompleted
                          ? 'Completed Today ✓'
                          : 'Mark Completed Today',
                      variant: isCompleted
                          ? HabitButtonVariant.secondary
                          : HabitButtonVariant.primary,
                      icon: isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                      onPressed: () {
                        logsNotifier.toggleHabitCompletion(habit.id, selectedDate);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3 KPI Pillars
              Row(
                children: [
                  Expanded(
                    child: AuroraCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Streak',
                            style: AppTypography.labelMedium(
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${habit.streak}d',
                            style: AppTypography.headline(
                              color: AppColors.streakFire,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AuroraCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '30d Rate',
                            style: AppTypography.labelMedium(
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '92%',
                            style: AppTypography.headline(
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AuroraCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total',
                            style: AppTypography.labelMedium(
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '48',
                            style: AppTypography.headline(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Monthly Completion Heatmap
              Text(
                '30-Day Heatmap Rhythm',
                style: AppTypography.headline(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              AuroraCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 28,
                      itemBuilder: (context, index) {
                        final isDone = index % 3 != 0;
                        return Container(
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppColors.secondaryFixed
                                : (isDark
                                    ? AppColors.darkSurfaceContainerHigh
                                    : AppColors.surfaceContainerHigh),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDone
                                    ? AppColors.secondary
                                    : (isDark ? Colors.white38 : Colors.black38),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Completed',
                          style: AppTypography.labelMedium(),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceContainerHigh
                                : AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Rest / Missed',
                          style: AppTypography.labelMedium(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Start Focus Timer CTA
              HabitButton(
                label: 'Start Habit Focus Timer',
                variant: HabitButtonVariant.outline,
                icon: Icons.timer_outlined,
                onPressed: () => context.go('/timer'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
