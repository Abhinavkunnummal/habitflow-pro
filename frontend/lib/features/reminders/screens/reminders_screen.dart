import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _morningAlert = true;
  bool _eveningReviewAlert = true;
  bool _streakRescueAlert = true;
  bool _quietHoursEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Reminders',
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
              // Quiet Hours Card
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bedtime_rounded, color: AppColors.primary, size: 24),
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
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Routine Alerts
              Text(
                'Master Routine Alerts',
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
                      'Gentle ping if high-priority habits remain undone by 8 PM',
                      _streakRescueAlert,
                      (val) => setState(() => _streakRescueAlert = val),
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              HabitButton(
                label: 'Save Notification Settings',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification schedules updated')),
                  );
                  context.go('/profile');
                },
              ),
            ],
          ),
        ),
      ),
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
