import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../dashboard/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                          child: const Center(
                            child: Text(
                              'A',
                              style: TextStyle(
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
                                'Alex Rivera',
                                style: AppTypography.headline(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'alex@habitflow.pro',
                                style: AppTypography.labelMedium(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
                          _buildStatItem('Level', '6', isDark),
                          _buildDivider(isDark),
                          _buildStatItem('Streak', '14d', isDark),
                          _buildDivider(isDark),
                          _buildStatItem('Logs', '148', isDark),
                          _buildDivider(isDark),
                          _buildStatItem('Badges', '6', isDark),
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
                    // Cloud Sync
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cloud_done_outlined, color: AppColors.secondary),
                      title: Text(
                        'Cloud Sync & Offline Vault',
                        style: AppTypography.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ).copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Local cache active • Ready for MongoDB Atlas',
                        style: AppTypography.labelMedium(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              HabitButton(
                label: 'Sign Out / Switch Mode',
                variant: HabitButtonVariant.outline,
                onPressed: () => context.go('/auth'),
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
