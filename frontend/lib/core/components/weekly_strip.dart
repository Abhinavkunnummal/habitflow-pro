import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WeeklyStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const WeeklyStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    // Start on Monday of the current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = weekDays[index];
          final isSelected = day.year == selectedDate.year &&
              day.month == selectedDate.month &&
              day.day == selectedDate.day;
          final isToday = day.year == now.year &&
              day.month == now.month &&
              day.day == now.day;

          return GestureDetector(
            onTap: () => onDateSelected(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkSurfaceContainer
                        : AppColors.surfaceContainerLowest),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isToday
                          ? AppColors.secondaryFixed
                          : (isDark
                              ? AppColors.darkSurfaceContainerHigh
                              : AppColors.surfaceContainerHigh)),
                  width: isToday ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day).substring(0, 2).toUpperCase(),
                    style: AppTypography.labelMedium(
                      color: isSelected
                          ? Colors.white.withOpacity(0.85)
                          : (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                    ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: AppTypography.titleMedium(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (isToday && !isSelected) ...[
                    const SizedBox(height: 3),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryFixed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
