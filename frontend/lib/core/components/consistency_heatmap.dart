import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../features/dashboard/models/habit.dart';
import '../../features/dashboard/models/habit_log.dart';
import '../../features/dashboard/providers/habits_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'aurora_card.dart';

enum HeatmapViewMode { week, month, year }

/// Highly interactive Consistency Heatmap supporting Week, Month, and Year modes
class ConsistencyHeatmap extends ConsumerStatefulWidget {
  const ConsistencyHeatmap({super.key});

  @override
  ConsumerState<ConsistencyHeatmap> createState() => _ConsistencyHeatmapState();
}

class _ConsistencyHeatmapState extends ConsumerState<ConsistencyHeatmap> {
  HeatmapViewMode _mode = HeatmapViewMode.month;
  DateTime _referenceDate = DateTime.now();
  DateTime? _selectedDetailDate;

  Color _getIntensityColor(double ratio, bool isDark) {
    if (ratio <= 0.0) {
      return isDark ? AppColors.darkSurfaceContainerHigh : AppColors.surfaceContainerHigh;
    } else if (ratio < 0.34) {
      return AppColors.secondary.withOpacity(0.35);
    } else if (ratio < 0.67) {
      return AppColors.secondary.withOpacity(0.65);
    } else if (ratio < 1.0) {
      return AppColors.secondary;
    } else {
      return AppColors.secondaryFixed;
    }
  }

  ({int completed, int total, double ratio}) _getDayStats(
    DateTime date,
    List<Habit> habits,
    List<HabitLog> logs,
  ) {
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    if (activeHabits.isEmpty) return (completed: 0, total: 0, ratio: 0.0);

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    int completed = 0;
    for (final h in activeHabits) {
      final isDone = logs.any((l) => l.habitId == h.id && l.date == dateStr && l.completed);
      if (isDone) completed++;
    }

    final ratio = completed / activeHabits.length;
    return (completed: completed, total: activeHabits.length, ratio: ratio);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habits = ref.watch(habitsProvider);
    final logs = ref.watch(habitLogsProvider);

    return AuroraCard(
      hasAuroraBorder: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & View Selector Chips [ Week | Month | Year ]
          Row(
            children: [
              Expanded(
                child: Text(
                  'Consistency Heatmap',
                  style: AppTypography.titleMedium(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeTab('Week', HeatmapViewMode.week, isDark),
                    _buildModeTab('Month', HeatmapViewMode.month, isDark),
                    _buildModeTab('Year', HeatmapViewMode.year, isDark),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Navigation Header
          _buildNavigationHeader(isDark),
          const SizedBox(height: 14),

          // View Content based on Selected Mode
          if (_mode == HeatmapViewMode.week)
            _buildWeekView(habits, logs, isDark)
          else if (_mode == HeatmapViewMode.month)
            _buildMonthView(habits, logs, isDark)
          else
            _buildYearView(habits, logs, isDark),

          // Detail Card if a date is selected
          if (_selectedDetailDate != null) ...[
            const SizedBox(height: 14),
            _buildSelectedDetailCard(habits, logs, isDark),
          ],

          const SizedBox(height: 12),
          // Intensity Legend
          _buildLegend(isDark),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, HeatmapViewMode mode, bool isDark) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _mode = mode;
          _selectedDetailDate = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationHeader(bool isDark) {
    String title;
    if (_mode == HeatmapViewMode.week) {
      final startOfWeek = _referenceDate.subtract(Duration(days: _referenceDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      title = '${DateFormat('MMM d').format(startOfWeek)} — ${DateFormat('MMM d').format(endOfWeek)}';
    } else if (_mode == HeatmapViewMode.month) {
      title = DateFormat('MMMM').format(_referenceDate);
    } else {
      title = 'Year ${DateFormat('yyyy').format(_referenceDate)}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            setState(() {
              if (_mode == HeatmapViewMode.week) {
                _referenceDate = _referenceDate.subtract(const Duration(days: 7));
              } else if (_mode == HeatmapViewMode.month) {
                _referenceDate = DateTime(_referenceDate.year, _referenceDate.month - 1, 1);
              } else {
                _referenceDate = DateTime(_referenceDate.year - 1, 1, 1);
              }
            });
          },
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: AppTypography.titleMedium(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            setState(() {
              if (_mode == HeatmapViewMode.week) {
                _referenceDate = _referenceDate.add(const Duration(days: 7));
              } else if (_mode == HeatmapViewMode.month) {
                _referenceDate = DateTime(_referenceDate.year, _referenceDate.month + 1, 1);
              } else {
                _referenceDate = DateTime(_referenceDate.year + 1, 1, 1);
              }
            });
          },
        ),
      ],
    );
  }

  // --- 1. WEEK VIEW ---
  Widget _buildWeekView(List<Habit> habits, List<HabitLog> logs, bool isDark) {
    final startOfWeek = _referenceDate.subtract(Duration(days: _referenceDate.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Column(
      children: [
        Row(
          children: days.map((day) {
            final stats = _getDayStats(day, habits, logs);
            final isToday = DateFormat('yyyy-MM-dd').format(day) ==
                DateFormat('yyyy-MM-dd').format(DateTime.now());
            final isSelected = _selectedDetailDate != null &&
                DateFormat('yyyy-MM-dd').format(day) ==
                    DateFormat('yyyy-MM-dd').format(_selectedDetailDate!);

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDetailDate = day),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : (isToday
                            ? AppColors.primaryFixedDim.withOpacity(0.15)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isToday ? AppColors.primaryContainer : Colors.transparent),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(day).substring(0, 1),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _getIntensityColor(stats.ratio, isDark),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: stats.ratio >= 1.0
                              ? [
                                  BoxShadow(
                                    color: AppColors.secondaryFixed.withOpacity(0.5),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: stats.ratio >= 1.0
                              ? const Icon(Icons.check, size: 16, color: AppColors.secondary)
                              : Text(
                                  '${stats.completed}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: stats.ratio > 0.5 ? Colors.white : Colors.black54,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(stats.ratio * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- 2. MONTH VIEW ---
  Widget _buildMonthView(List<Habit> habits, List<HabitLog> logs, bool isDark) {
    final firstDayOfMonth = DateTime(_referenceDate.year, _referenceDate.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_referenceDate.year, _referenceDate.month);
    final startWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun
    final totalCells = ((startWeekday - 1) + daysInMonth + 6) ~/ 7 * 7;

    return Column(
      children: [
        // Weekday labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((w) {
            return SizedBox(
              width: 32,
              child: Center(
                child: Text(
                  w,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // 7-column calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final dayOffset = index - (startWeekday - 1);
            if (dayOffset < 0 || dayOffset >= daysInMonth) {
              return const SizedBox.shrink();
            }

            final dayNumber = dayOffset + 1;
            final day = DateTime(_referenceDate.year, _referenceDate.month, dayNumber);
            final stats = _getDayStats(day, habits, logs);
            final isToday = DateFormat('yyyy-MM-dd').format(day) ==
                DateFormat('yyyy-MM-dd').format(DateTime.now());
            final isSelected = _selectedDetailDate != null &&
                DateFormat('yyyy-MM-dd').format(day) ==
                    DateFormat('yyyy-MM-dd').format(_selectedDetailDate!);

            return GestureDetector(
              onTap: () => setState(() => _selectedDetailDate = day),
              child: Container(
                decoration: BoxDecoration(
                  color: _getIntensityColor(stats.ratio, isDark),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isToday ? AppColors.primaryFixedDim : Colors.transparent),
                    width: isSelected ? 2.0 : (isToday ? 1.5 : 0),
                  ),
                  boxShadow: stats.ratio >= 1.0
                      ? [
                          BoxShadow(
                            color: AppColors.secondaryFixed.withOpacity(0.4),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.w600,
                      color: stats.ratio >= 1.0
                          ? AppColors.secondary
                          : (stats.ratio > 0.3
                              ? Colors.white
                              : (isDark ? Colors.white60 : Colors.black87)),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- 3. YEAR VIEW (52-week annual matrix) ---
  Widget _buildYearView(List<Habit> habits, List<HabitLog> logs, bool isDark) {
    final year = _referenceDate.year;
    final firstDay = DateTime(year, 1, 1);
    final totalDays = (DateTime(year + 1, 1, 1).difference(firstDay)).inDays;

    int totalCompletions = 0;
    int activeDays = 0;

    for (int i = 0; i < totalDays; i++) {
      final d = firstDay.add(Duration(days: i));
      final stats = _getDayStats(d, habits, logs);
      totalCompletions += stats.completed;
      if (stats.completed > 0) activeDays++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year stats summary banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricColumn('$totalCompletions', 'Habits Done', isDark),
              _buildMetricColumn('$activeDays', 'Active Days', isDark),
              _buildMetricColumn(
                totalDays > 0 ? '${((activeDays / totalDays) * 100).toInt()}%' : '0%',
                'Consistency',
                isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal scrollable 52-week matrix
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(53, (colIdx) {
              return Padding(
                padding: const EdgeInsets.only(right: 3.5),
                child: Column(
                  children: List.generate(7, (rowIdx) {
                    final dayIndex = colIdx * 7 + rowIdx;
                    if (dayIndex >= totalDays) return const SizedBox(width: 11, height: 11);

                    final day = firstDay.add(Duration(days: dayIndex));
                    final stats = _getDayStats(day, habits, logs);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDetailDate = day),
                      child: Container(
                        width: 11,
                        height: 11,
                        margin: const EdgeInsets.only(bottom: 3.5),
                        decoration: BoxDecoration(
                          color: _getIntensityColor(stats.ratio, isDark),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricColumn(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildSelectedDetailCard(List<Habit> habits, List<HabitLog> logs, bool isDark) {
    final date = _selectedDetailDate!;
    final stats = _getDayStats(date, habits, logs);
    final dateFormatted = DateFormat('EEEE, MMMM d, yyyy').format(date);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormatted,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${stats.completed} of ${stats.total} habits completed (${(stats.ratio * 100).toInt()}%)',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: () => setState(() => _selectedDetailDate = null),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less  ',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
        ),
        _buildLegendBox(0.0, isDark),
        _buildLegendBox(0.25, isDark),
        _buildLegendBox(0.5, isDark),
        _buildLegendBox(0.85, isDark),
        _buildLegendBox(1.0, isDark),
        Text(
          '  More',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendBox(double ratio, bool isDark) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: _getIntensityColor(ratio, isDark),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
