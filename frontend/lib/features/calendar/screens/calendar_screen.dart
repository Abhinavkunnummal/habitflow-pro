import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  int _selectedDay = DateTime.now().day;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar & History',
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
              // Month Switcher Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_currentMonth),
                    style: AppTypography.titleMedium(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ).copyWith(fontSize: 18),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(
                              _currentMonth.year,
                              _currentMonth.month - 1,
                            );
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(
                              _currentMonth.year,
                              _currentMonth.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Calendar Grid Card
              AuroraCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Weekday Labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                          .map((d) => Text(
                                d,
                                style: AppTypography.labelMedium(
                                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    // Days Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: daysInMonth,
                      itemBuilder: (context, index) {
                        final dayNumber = index + 1;
                        final isSelected = dayNumber == _selectedDay;
                        final isComplete = dayNumber % 4 != 0;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = dayNumber),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isComplete
                                      ? AppColors.secondaryFixed.withOpacity(0.85)
                                      : (isDark
                                          ? AppColors.darkSurfaceContainerHigh
                                          : AppColors.surfaceContainerHigh)),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isComplete
                                          ? AppColors.secondary
                                          : (isDark ? Colors.white38 : Colors.black45)),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Selected Day Audit
              Text(
                'Day $_selectedDay Breakdown',
                style: AppTypography.headline(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
              AuroraCard(
                child: Column(
                  children: [
                    _buildLogItem('Drink 2L Water', '8/8 glasses', true, isDark),
                    const Divider(height: 16),
                    _buildLogItem('Deep Reading', '20/20 pages', true, isDark),
                    const Divider(height: 16),
                    _buildLogItem('Movement & Cardio', '30/30 mins', true, isDark),
                    const Divider(height: 16),
                    _buildLogItem('Evening Reflection', '1 session', false, isDark),
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

  Widget _buildLogItem(String title, String subtitle, bool done, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
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
        Icon(
          done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: done ? AppColors.secondary : Colors.grey,
          size: 20,
        ),
      ],
    );
  }
}
