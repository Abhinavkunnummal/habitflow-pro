import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/aurora_progress_ring.dart';
import '../../../core/components/streak_badge.dart';
import '../../../core/components/study_motivation_card.dart';
import '../../../core/components/task_completion_button.dart';
import '../../../core/components/weekly_strip.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/habits_provider.dart';
import '../providers/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  Key _refreshKey = UniqueKey();

  Future<void> _handleRefresh() async {
    setState(() {
      _refreshKey = UniqueKey();
    });
    await ref.read(habitsProvider.notifier).fetchHabitsFromBackend();
    await ref.read(habitLogsProvider.notifier).syncTodayCompletions(DateTime.now());
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 22) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'bedtime':
        return Icons.bedtime_rounded;
      case 'savings':
        return Icons.savings_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habits = ref.watch(habitsProvider);
    final logsNotifier = ref.watch(habitLogsProvider.notifier);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final progressData = ref.watch(dailyProgressProvider);

    final filteredHabits = habits.where((h) {
      if (h.isArchived) return false;
      if (selectedCategory == 'All') return true;
      return h.category.toLowerCase().contains(selectedCategory.toLowerCase());
    }).toList();

    final categories = [
      'All',
      'Morning',
      'Health & Fitness',
      'Learning & Career',
      'Evening',
    ];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  children: [
                    // Dynamic greeting with crystal-clear high-contrast visibility
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d').format(selectedDate).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: isDark ? AppColors.primaryFixedDim : AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Builder(
                            builder: (context) {
                              final user = ref.watch(authProvider).user;
                              final rawName = user?.name.trim();
                              final firstName = (rawName != null && rawName.isNotEmpty)
                                  ? rawName.split(' ').first
                                  : 'Champion';
                              return Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${_getTimeGreeting()}, ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                    TextSpan(
                                      text: firstName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : AppColors.primary,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' 👋',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action controls with compact bounds to prevent horizontal overflow
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StreakBadge(
                          streakDays: habits.fold<int>(
                            ref.watch(authProvider).user?.currentStreak ?? 0,
                            (prev, h) => h.streak > prev ? h.streak : prev,
                          ),
                          compact: true,
                        ),
                        const SizedBox(width: 2),
                        IconButton(
                          tooltip: 'Community Contests & Leaderboard',
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(5),
                          constraints: const BoxConstraints(),
                          onPressed: () => context.go('/contests'),
                          icon: const Icon(
                            Icons.emoji_events_rounded,
                            color: AppColors.streakFire,
                            size: 20,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Focus Timer',
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(5),
                          constraints: const BoxConstraints(),
                          onPressed: () => context.go('/timer'),
                          icon: Icon(
                            Icons.timer_outlined,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Search Directory',
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(5),
                          constraints: const BoxConstraints(),
                          onPressed: () => context.go('/search'),
                          icon: Icon(
                            Icons.search_rounded,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Toggle Theme',
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(5),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            ref.read(themeModeProvider.notifier).toggleTheme();
                          },
                          icon: Icon(
                            isDark
                                ? Icons.wb_sunny_rounded
                                : Icons.nightlight_round_rounded,
                            color: isDark
                                ? AppColors.secondaryFixed
                                : AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Hero Aurora Progress Ring Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: AuroraCard(
                  hasAuroraBorder: true,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      AuroraProgressRing(
                        progress: progressData.progress,
                        completedCount: progressData.completed,
                        totalCount: progressData.total,
                        size: 118,
                        strokeWidth: 10,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryFixed.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.trending_up_rounded,
                                    size: 14,
                                    color: AppColors.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+12% Momentum',
                                    style: AppTypography.labelMedium(
                                      color: AppColors.secondary,
                                    ).copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Consistency Flow',
                              style: AppTypography.titleMedium(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              progressData.completed == progressData.total &&
                                      progressData.total > 0
                                  ? 'Daily routine completed! 🎉'
                                  : 'Complete remaining habits to keep your streak ablaze.',
                              style: AppTypography.labelMedium(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ).copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                InkWell(
                                  onTap: () => context.go('/timer'),
                                  borderRadius: BorderRadius.circular(9999),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(9999),
                                      border: Border.all(
                                        color: AppColors.primary.withOpacity(0.25),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.timer_outlined,
                                          size: 13,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Focus Timer',
                                          style: AppTypography.labelMedium(
                                            color: AppColors.primary,
                                          ).copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => context.go('/contests'),
                                  borderRadius: BorderRadius.circular(9999),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.streakFire.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(9999),
                                      border: Border.all(
                                        color: AppColors.streakFire.withOpacity(0.25),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.emoji_events_rounded,
                                          size: 13,
                                          color: AppColors.streakFire,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Contests 🏆',
                                          style: AppTypography.labelMedium(
                                            color: AppColors.streakFire,
                                          ).copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Daily Study & Flow Motivation Card (Refreshes with fresh quote on pull-to-refresh)
            SliverToBoxAdapter(
              child: StudyMotivationCard(key: _refreshKey),
            ),

            // 7-Day Horizontal Calendar Strip
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: WeeklyStrip(
                  selectedDate: selectedDate,
                  onDateSelected: (newDate) {
                    ref.read(selectedDateProvider.notifier).state = newDate;
                  },
                ),
              ),
            ),

            // Category Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selectedCategory == cat;

                    return FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      labelStyle: AppTypography.labelMedium(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary),
                      ).copyWith(fontWeight: FontWeight.w600),
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceContainer
                          : AppColors.surfaceContainerLow,
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkSurfaceContainerHigh
                                  : AppColors.surfaceContainerHigh),
                        ),
                      ),
                      onSelected: (_) {
                        ref.read(selectedCategoryFilterProvider.notifier).state =
                            cat;
                      },
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Habits Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Routines',
                      style: AppTypography.headline(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ).copyWith(fontSize: 18),
                    ),
                    Text(
                      '${filteredHabits.length} habits',
                      style: AppTypography.labelMedium(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Habit Cards or Empty State
            if (filteredHabits.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AuroraCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 36,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your Canvas is Open',
                          style: AppTypography.headline(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No habits for this filter yet. Tap the button below to craft a new habit routine.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/habit/new'),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add a Habit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = filteredHabits[index];
                      final isCompleted =
                          logsNotifier.isCompleted(habit.id, selectedDate);
                      final habitColor = _parseColor(habit.colorHex);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: AuroraCard(
                          onTap: () => context.go('/habit/${habit.id}'),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Icon Pill
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: habitColor.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  _getIconData(habit.icon),
                                  color: habitColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Habit Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      habit.title,
                                      style: AppTypography.titleMedium(
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.textPrimary,
                                      ).copyWith(
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: isCompleted
                                            ? (isDark
                                                ? AppColors.darkTextTertiary
                                                : AppColors.textTertiary)
                                            : (isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.textPrimary),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Text(
                                          '${habit.targetValue} ${habit.targetUnit}',
                                          style: AppTypography.labelMedium(
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 3,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors.darkTextTertiary
                                                : AppColors.textTertiary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.local_fire_department_rounded,
                                          size: 14,
                                          color: AppColors.streakFire,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${habit.streak}d',
                                          style: AppTypography.labelMedium(
                                            color: AppColors.streakFire,
                                          ).copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Completion Checkbox Button with celebratory animation & audio feedback
                              TaskCompletionButton(
                                isCompleted: isCompleted,
                                onToggle: () {
                                  logsNotifier.toggleHabitCompletion(
                                    habit.id,
                                    selectedDate,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filteredHabits.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/habit/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
