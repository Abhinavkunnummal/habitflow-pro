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
    final level = user?.level ?? 1;
    final streak = user?.currentStreak ?? 0;
    final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';

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
                          _buildStatItem('Best', '${user?.longestStreak ?? 0}d', isDark),
                          _buildDivider(isDark),
                          _buildStatItem('XP', '${user?.xp ?? 0}', isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
}
