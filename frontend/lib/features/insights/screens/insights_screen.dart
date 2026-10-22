import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/aurora_progress_ring.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _timeframe = '30d';
  final List<String> _timeframes = ['7d', '30d', '90d', 'All'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Insights & Flow',
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
              // Timeframe selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _timeframes.map((tf) {
                  final isSelected = _timeframe == tf;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(tf),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceContainer
                          : AppColors.surfaceContainerLow,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        fontWeight: FontWeight.bold,
                      ),
                      shape: const StadiumBorder(),
                      onSelected: (_) => setState(() => _timeframe = tf),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Hero Consistency Gauge Card
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const AuroraProgressRing(
                      progress: 0.88,
                      completedCount: 22,
                      totalCount: 25,
                      size: 110,
                      strokeWidth: 10,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '88% Consistency',
                            style: AppTypography.headline(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+14% velocity surge compared to your previous 30-day window.',
                            style: AppTypography.labelMedium(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Weekly Review CTA Card
              AuroraCard(
                onTap: () => context.go('/weekly-review'),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.auto_graph_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Review Ready',
                            style: AppTypography.titleMedium(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ).copyWith(fontSize: 14),
                          ),
                          Text(
                            'Reflect on friction points and anchor habits.',
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
              const SizedBox(height: 20),

              // Category Breakdown Bars
              Text(
                'Category Equilibrium',
                style: AppTypography.headline(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              AuroraCard(
                child: Column(
                  children: [
                    _buildCategoryRow('Morning Routines', 0.95, AppColors.secondaryFixed, isDark),
                    const SizedBox(height: 12),
                    _buildCategoryRow('Health & Fitness', 0.82, AppColors.secondary, isDark),
                    const SizedBox(height: 12),
                    _buildCategoryRow('Learning & Career', 0.76, AppColors.primary, isDark),
                    const SizedBox(height: 12),
                    _buildCategoryRow('Mindfulness & Evening', 0.65, AppColors.tertiary, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              HabitButton(
                label: 'View Full Weekly Review',
                onPressed: () => context.go('/weekly-review'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String title, double percentage, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.labelMedium(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: AppTypography.labelMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: isDark
              ? AppColors.darkSurfaceContainerHigh
              : AppColors.surfaceContainerHigh,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(9999),
          minHeight: 8,
        ),
      ],
    );
  }
}
