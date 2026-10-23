import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/task_completion_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../dashboard/models/habit.dart';
import '../../dashboard/providers/habits_provider.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  DateTime _timelineDate = DateTime.now();

  String _formatTimeHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${h.toString().padLeft(2, '0')}:00 $period';
  }

  int _parseHourFromReminder(String? reminderTime) {
    if (reminderTime == null) return -1;
    final parts = reminderTime.split(':');
    return int.tryParse(parts[0]) ?? -1;
  }

  int _defaultHourForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('morning')) return 8;
    if (c.contains('learning') || c.contains('career')) return 11;
    if (c.contains('health') || c.contains('fitness')) return 17;
    if (c.contains('evening') || c.contains('mindfulness')) return 21;
    return 14;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habits = ref.watch(habitsProvider);
    final logs = ref.watch(habitLogsProvider);
    final logsNotifier = ref.watch(habitLogsProvider.notifier);

    final activeHabits = habits.where((h) => !h.isArchived).toList();
    final dateStr = DateFormat('yyyy-MM-dd').format(_timelineDate);
    final isViewingToday = dateStr == DateFormat('yyyy-MM-dd').format(DateTime.now());
    final currentHour = DateTime.now().hour;

    // Group habits into hourly timeline slots
    final Map<int, List<Habit>> hourlySchedule = {};
    for (final h in activeHabits) {
      int hour = _parseHourFromReminder(h.reminderTime);
      if (hour < 0 || hour > 23) {
        hour = _defaultHourForCategory(h.category);
      }
      hourlySchedule.putIfAbsent(hour, () => []).add(h);
    }

    final sortedHours = hourlySchedule.keys.toList()..sort();
    final completedCount = activeHabits.where((h) =>
        logs.any((l) => l.habitId == h.id && l.date == dateStr && l.completed)).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Timeline Planner',
          style: AppTypography.headline(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Scheduled Task',
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            onPressed: () => context.go('/habit/new'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Navigation Strip: [ Today | Tomorrow | In 2 Days | Pick Date ]
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildDayTab('Today', DateTime.now(), isDark),
                    const SizedBox(width: 8),
                    _buildDayTab(
                      'Tomorrow',
                      DateTime.now().add(const Duration(days: 1)),
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildDayTab(
                      'Next Day',
                      DateTime.now().add(const Duration(days: 2)),
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.event_rounded, size: 14),
                      label: const Text('Pick Date', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: BorderSide(
                          color: isDark ? AppColors.darkSurfaceContainerHigh : AppColors.surfaceContainerHigh,
                        ),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _timelineDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => _timelineDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Timeline Overview Header Card
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondaryFixed.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Text(
                          activeHabits.isNotEmpty
                              ? '${((completedCount / activeHabits.length) * 100).toInt()}%'
                              : '0%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d').format(_timelineDate),
                            style: AppTypography.titleMedium(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ).copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$completedCount of ${activeHabits.length} daily time blocks executed',
                            style: AppTypography.labelMedium(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () => context.go('/habit/new'),
                      child: const Text('+ Plan', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section Header: Chronological Schedule
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CHRONOLOGICAL TIMELINE',
                    style: AppTypography.labelMedium(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                    ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
                  ),
                  Text(
                    '${sortedHours.length} time slots',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Empty State or Timeline List
              if (activeHabits.isEmpty)
                AuroraCard(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 40, color: AppColors.primary),
                        const SizedBox(height: 12),
                        const Text(
                          'Your timeline is empty',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add your morning routines, study blocks, and evening habits to generate your custom day plan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.go('/habit/new'),
                          child: const Text('Add First Time Block'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedHours.length,
                  itemBuilder: (context, index) {
                    final hour = sortedHours[index];
                    final hourHabits = hourlySchedule[hour] ?? [];
                    final isCurrentHour = isViewingToday && currentHour == hour;

                    return _buildTimelineHourBlock(
                      hour: hour,
                      habits: hourHabits,
                      logs: logs,
                      logsNotifier: logsNotifier,
                      dateStr: dateStr,
                      isCurrentHour: isCurrentHour,
                      isDark: isDark,
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Quick Action: Focus Sprint CTA
              AuroraCard(
                onTap: () => context.go('/timer'),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.streakFire.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.timer_outlined, color: AppColors.streakFire),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter Focus Timer Mode',
                            style: AppTypography.titleMedium(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ).copyWith(fontSize: 14),
                          ),
                          Text(
                            'Execute your active time block with unbroken deep work.',
                            style: AppTypography.labelMedium(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayTab(String label, DateTime date, bool isDark) {
    final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(_timelineDate);

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
      onSelected: (_) => setState(() => _timelineDate = date),
    );
  }

  Widget _buildTimelineHourBlock({
    required int hour,
    required List<Habit> habits,
    required List<dynamic> logs,
    required dynamic logsNotifier,
    required String dateStr,
    required bool isCurrentHour,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Time Column + Connector Dot
          SizedBox(
            width: 78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTimeHour(hour),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isCurrentHour ? FontWeight.w800 : FontWeight.w600,
                    color: isCurrentHour
                        ? AppColors.primary
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                ),
                if (isCurrentHour)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'NOW ⚡',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Timeline Node & Habit Cards
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentHour
                    ? (isDark ? const Color(0xFF231E3D) : const Color(0xFFF3EEFF))
                    : (isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrentHour
                      ? AppColors.primary
                      : (isDark ? AppColors.darkSurfaceContainerHigh : AppColors.surfaceContainerHigh),
                  width: isCurrentHour ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: habits.map((h) {
                  final isDone = logs.any((l) => l.habitId == h.id && l.date == dateStr && l.completed);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                  color: isDone
                                      ? Colors.grey
                                      : (isDark ? Colors.white : Colors.black87),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${h.targetValue} ${h.targetUnit} • ${h.category}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Interactive completion button right on the timeline!
                        TaskCompletionButton(
                          isCompleted: isDone,
                          size: 34,
                          onToggle: () {
                            logsNotifier.toggleHabitCompletion(h.id, _timelineDate);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
