import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/services/audio_feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../dashboard/providers/habits_provider.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool _morningAlert = true;
  bool _eveningReviewAlert = true;
  bool _streakRescueAlert = true;
  bool _quietHoursEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habits = ref.watch(habitsProvider);
    final reminderHabits = habits.where((h) => !h.isArchived && h.reminderTime != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Reminders & Schedules',
          style: AppTypography.headline(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reminder Sound Card
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.music_note_rounded, color: AppColors.secondary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calm Acoustic Chime',
                            style: AppTypography.titleMedium(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ).copyWith(fontSize: 14),
                          ),
                          Text(
                            'High-clarity harmonic notification sound',
                            style: AppTypography.labelMedium(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        AudioFeedbackService.playReminderChime();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Playing soothing reminder chime 🔔'),
                            duration: Duration(milliseconds: 1200),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text('Play', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Quiet Hours Card
              AuroraCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bedtime_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quiet Hours Window',
                              style: AppTypography.titleMedium(
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ).copyWith(fontSize: 14),
                            ),
                            Text(
                              '10:30 PM — 6:30 AM',
                              style: AppTypography.labelMedium(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _quietHoursEnabled,
                      activeColor: AppColors.secondaryFixed,
                      onChanged: (val) => setState(() => _quietHoursEnabled = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Scheduled Future Day Task Reminders
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scheduled Habit Reminders',
                    style: AppTypography.headline(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ).copyWith(fontSize: 16),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Task', style: TextStyle(fontSize: 12)),
                    onPressed: () => context.go('/habit/new'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (reminderHabits.isEmpty)
                AuroraCard(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No habit reminders scheduled yet.',
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
                      for (int i = 0; i < reminderHabits.length; i++) ...[
                        if (i > 0) const Divider(height: 16),
                        _buildHabitReminderTile(reminderHabits[i], isDark),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Master Routine Alerts
              Text(
                'Master Routine Safeguards',
                style: AppTypography.headline(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              AuroraCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Morning Kickoff (07:30 AM)',
                      'Daily hydration and mindset trigger',
                      _morningAlert,
                      (val) => setState(() => _morningAlert = val),
                      isDark,
                    ),
                    const Divider(height: 20),
                    _buildSwitchTile(
                      'Evening Review (09:30 PM)',
                      'Reflect on wins and complete reflections',
                      _eveningReviewAlert,
                      (val) => setState(() => _eveningReviewAlert = val),
                      isDark,
                    ),
                    const Divider(height: 20),
                    _buildSwitchTile(
                      'Streak Rescue Safeguard',
                      'Gentle chime if high-priority habits remain undone by 8 PM',
                      _streakRescueAlert,
                      (val) => setState(() => _streakRescueAlert = val),
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              HabitButton(
                label: 'Save Notification Schedules',
                onPressed: () {
                  AudioFeedbackService.playReminderChime();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notification schedules saved')),
                  );
                  context.go('/profile');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitReminderTile(dynamic habit, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.alarm_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: AppTypography.titleMedium(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ).copyWith(fontSize: 14),
                ),
                Text(
                  'Daily at ${habit.reminderTime} • ${habit.category}',
                  style: AppTypography.labelMedium(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.volume_up_rounded, size: 20, color: AppColors.secondary),
          tooltip: 'Test Sound',
          onPressed: () => AudioFeedbackService.playReminderChime(),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.labelMedium(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: AppColors.secondaryFixed,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
