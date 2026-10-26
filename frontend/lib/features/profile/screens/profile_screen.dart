import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/habits_provider.dart';
import '../../dashboard/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showServerConfigDialog(BuildContext context, WidgetRef ref) {
    final sessionStorage = ref.read(sessionStorageProvider);
    final apiClient = ref.read(apiClientProvider);
    final urlController = TextEditingController(text: apiClient.currentBaseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Backend API Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure the REST API endpoint for physical phone testing or cloud hosting:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://192.168.1.X:5000/api/v1',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Quick Presets:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('Render Cloud (onrender.com)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    urlController.text = 'https://habitflow-pro-bz24.onrender.com/api/v1';
                  },
                ),
                ActionChip(
                  label: const Text('PC Wi-Fi (192.168.1.2)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    urlController.text = 'http://192.168.1.2:5000/api/v1';
                  },
                ),
                ActionChip(
                  label: const Text('Localhost (5000)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    urlController.text = 'http://localhost:5000/api/v1';
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newUrl = urlController.text.trim();
              if (newUrl.isNotEmpty) {
                await sessionStorage.setCustomBaseUrl(newUrl);
                apiClient.updateBaseUrl(newUrl);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Server URL updated to $newUrl')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final displayName = user?.name ?? 'Alex Rivera';
    final displayEmail = user?.email ?? (authState.isOfflineMode ? 'Offline Mode' : 'alex@habitflow.pro');
    final habits = ref.watch(habitsProvider);
    final storage = ref.watch(localStorageProvider);

    final maxHabitStreak = habits.fold<int>(0, (max, h) => h.streak > max ? h.streak : max);
    final streak = (user?.currentStreak != null && user!.currentStreak > maxHabitStreak)
        ? user.currentStreak
        : maxHabitStreak;
    final bestStreak = (user?.longestStreak != null && user!.longestStreak > streak)
        ? user.longestStreak
        : streak;
    final xp = user?.xp ?? (streak * 50);
    final level = user?.level ?? (1 + xp ~/ 200);
    final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';
    final weeklyMinutes = storage.getWeeklyFocusMinutes();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
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
              // User Avatar Card
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            gradient: AppColors.auroraGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              firstLetter,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: AppTypography.headline(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                displayEmail,
                                style: AppTypography.labelMedium(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (authState.isAuthenticated)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryFixed.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.cloud_done_rounded, size: 14, color: AppColors.secondary),
                                SizedBox(width: 4),
                                Text(
                                  'Synced',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // 4-Grid Stats Pill
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Level', '$level', isDark),
                          _buildDivider(isDark),
                          _buildStatItem('Streak', '${streak}d', isDark),
                          _buildDivider(isDark),
                          _buildStatItem('Best', '${bestStreak}d', isDark),
                          _buildDivider(isDark),
                          _buildStatItem('XP', '$xp', isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Learning & Deep Focus Progress Curve Card
              _buildLearningProgressCard(isDark, weeklyMinutes),
              const SizedBox(height: 24),

              // Preferences Section
              Text(
                'App Preferences',
                style: AppTypography.headline(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              AuroraCard(
                child: Column(
                  children: [
                    // Theme Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Dark Theme',
                              style: AppTypography.titleMedium(
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ).copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                        Switch(
                          value: isDark,
                          activeColor: AppColors.secondaryFixed,
                          onChanged: (_) {
                            ref.read(themeModeProvider.notifier).toggleTheme();
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    // Server Connection Settings
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.settings_ethernet_rounded, color: AppColors.primary),
                      title: Text(
                        'Backend Server URL',
                        style: AppTypography.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ).copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        ref.watch(apiClientProvider).currentBaseUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMedium(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      trailing: const Icon(Icons.edit_outlined, size: 18),
                      onTap: () => _showServerConfigDialog(context, ref),
                    ),
                    const Divider(height: 20),
                    // Reminders & Quiet Hours
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                      title: Text(
                        'Reminders & Quiet Hours',
                        style: AppTypography.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ).copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Quiet hours: 10:30 PM - 6:30 AM',
                        style: AppTypography.labelMedium(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.go('/reminders'),
                    ),
                    const Divider(height: 20),
                    // Focus Timer & Soundscapes
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.timer_outlined, color: AppColors.primary),
                      title: Text(
                        'Focus Timer & Soundscapes',
                        style: AppTypography.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ).copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Pomodoro presets & ambient focus sounds',
                        style: AppTypography.labelMedium(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.go('/timer'),
                    ),
                    const Divider(height: 20),
                    // Contests & Community Leaderboard
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.emoji_events_rounded, color: AppColors.streakFire),
                      title: Text(
                        'Community Contests & Leaderboard',
                        style: AppTypography.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ).copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Compete with friends, climb ranks & claim badges',
                        style: AppTypography.labelMedium(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.go('/contests'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              HabitButton(
                label: 'Sign Out / Switch Account',
                variant: HabitButtonVariant.outline,
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  await ref.read(habitsProvider.notifier).clearUserData();
                  if (context.mounted) {
                    context.go('/auth');
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 24,
      color: isDark ? AppColors.darkSurfaceContainerHigh : AppColors.surfaceContainerHigh,
    );
  }

  Widget _buildLearningProgressCard(bool isDark, Map<int, int> weeklyMinutes) {
    final todayWeekday = DateTime.now().weekday; // 1 to 7
    final totalMins = weeklyMinutes.values.fold<int>(0, (sum, v) => sum + v);
    final avgMins = (totalMins / 7).round();
    final maxMins = math.max(80, weeklyMinutes.values.fold<int>(0, (m, v) => v > m ? v : m));
    final days = [
      (day: 1, label: 'M'),
      (day: 2, label: 'T'),
      (day: 3, label: 'W'),
      (day: 4, label: 'T'),
      (day: 5, label: 'F'),
      (day: 6, label: 'S'),
      (day: 7, label: 'S'),
    ];

    return AuroraCard(
      hasAuroraBorder: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_graph_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learning & Focus Curve',
                        style: AppTypography.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Weekly deep focus minutes',
                        style: AppTypography.labelMedium(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '${(totalMins / 60).toStringAsFixed(1)} hrs total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryFixed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 7-Day Bar Chart
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((d) {
                final mins = weeklyMinutes[d.day] ?? 0;
                final isToday = d.day == todayWeekday;
                final barHeight = mins > 0 ? (72.0 * (mins / maxMins)).clamp(10.0, 72.0) : 4.0;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${mins}m',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          color: isToday
                              ? AppColors.secondaryFixed
                              : (isDark ? Colors.white54 : Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 18,
                        height: barHeight,
                        decoration: BoxDecoration(
                          gradient: mins > 0
                              ? LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: isToday
                                      ? [AppColors.primary, AppColors.secondaryFixed]
                                      : [
                                          AppColors.primary.withOpacity(0.6),
                                          AppColors.primaryContainer.withOpacity(0.4),
                                        ],
                                )
                              : null,
                          color: mins > 0
                              ? null
                              : (isDark ? AppColors.darkSurfaceContainerHigh : AppColors.surfaceContainerHigh),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: (isToday && mins > 0)
                              ? [
                                  BoxShadow(
                                    color: AppColors.secondaryFixed.withOpacity(0.35),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday
                              ? AppColors.primary
                              : (isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerHigh),
                        ),
                        child: Center(
                          child: Text(
                            d.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isToday
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Summary Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⚡ Avg: $avgMins mins/day',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 14, color: AppColors.secondaryFixed),
                  const SizedBox(width: 4),
                  Text(
                    totalMins > 0 ? 'Logged Focus Curve' : 'No Sessions Yet',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
