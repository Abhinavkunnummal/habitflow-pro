import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/consistency_heatmap.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../dashboard/providers/habits_provider.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habits = ref.watch(habitsProvider);
    final logs = ref.watch(habitLogsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar & Consistency',
          style: AppTypography.headline(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interactive Week / Month / Year Heatmap Component
              const ConsistencyHeatmap(),
              const SizedBox(height: 20),

              // Date Selector Chips (Quick Next Day / Tomorrow Scheduling)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildDateChip(
                      context,
                      ref,
                      'Today',
                      DateTime.now(),
                      selectedDate,
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildDateChip(
                      context,
                      ref,
                      'Tomorrow ⏩',
                      DateTime.now().add(const Duration(days: 1)),
                      selectedDate,
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildDateChip(
                      context,
                      ref,
                      'In 2 Days',
                      DateTime.now().add(const Duration(days: 2)),
                      selectedDate,
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_rounded, size: 14),
                      label: const Text('Pick Date', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: const StadiumBorder(),
                        side: BorderSide(
                          color: isDark ? AppColors.darkSurfaceContainerHigh : AppColors.surfaceContainerHigh,
                        ),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          ref.read(selectedDateProvider.notifier).state = picked;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Next Day Scheduling CTA Banner
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_task_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule Next Day Routine',
                            style: AppTypography.titleMedium(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ).copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Plan tomorrow early to ensure 100% execution.',
                            style: AppTypography.labelMedium(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
                        // Set selected date to tomorrow and navigate to create routine
                        ref.read(selectedDateProvider.notifier).state =
                            DateTime.now().add(const Duration(days: 1));
                        context.go('/habit/new');
                      },
                      child: const Text('Add Task', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Active Day Habits Breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(selectedDate),
                    style: AppTypography.headline(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ).copyWith(fontSize: 16),
                  ),
                  Text(
                    '${activeHabits.where((h) => logs.any((l) => l.habitId == h.id && l.date == dateStr && l.completed)).length}/${activeHabits.length} Done',
                    style: AppTypography.labelMedium(
                      color: AppColors.secondary,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (activeHabits.isEmpty)
                AuroraCard(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No habits created yet. Start tracking today!',
                      style: AppTypography.labelMedium(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                AuroraCard(
                  child: Column(
                    children: [
                      for (int i = 0; i < activeHabits.length; i++) ...[
                        if (i > 0) const Divider(height: 16),
                        _buildHabitRow(activeHabits[i], dateStr, logs, isDark),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              HabitButton(
                label: 'Open Daily Journal',
                variant: HabitButtonVariant.outline,
                icon: Icons.edit_calendar_rounded,
                onPressed: () => context.go('/journal'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    DateTime targetDate,
    DateTime selectedDate,
    bool isDark,
  ) {
    final isSelected = DateFormat('yyyy-MM-dd').format(targetDate) ==
        DateFormat('yyyy-MM-dd').format(selectedDate);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? Colors.white
            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
      ),
      shape: const StadiumBorder(),
      onSelected: (_) {
        ref.read(selectedDateProvider.notifier).state = targetDate;
      },
    );
  }

  Widget _buildHabitRow(dynamic habit, String dateStr, List<dynamic> logs, bool isDark) {
    final isDone = logs.any((l) => l.habitId == habit.id && l.date == dateStr && l.completed);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.title,
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 14),
              ),
              Text(
                '${habit.targetValue} ${habit.targetUnit} • ${habit.category}',
                style: AppTypography.labelMedium(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: isDone ? AppColors.secondaryFixed : Colors.grey.withOpacity(0.5),
          size: 22,
        ),
      ],
    );
  }
}
