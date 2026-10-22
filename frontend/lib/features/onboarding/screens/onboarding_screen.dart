import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../dashboard/providers/theme_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final Set<String> _selectedPillars = {'Mind', 'Body'};

  final List<({String title, String subtitle, IconData icon, Color color})> _pillars = [
    (
      title: 'Mind',
      subtitle: 'Clarity, reading & deep focus',
      icon: Icons.psychology_rounded,
      color: AppColors.primary,
    ),
    (
      title: 'Body',
      subtitle: 'Fitness, hydration & nutrition',
      icon: Icons.fitness_center_rounded,
      color: AppColors.secondary,
    ),
    (
      title: 'Growth',
      subtitle: 'Skills, career & discipline',
      icon: Icons.bolt_rounded,
      color: AppColors.primaryContainer,
    ),
    (
      title: 'Soul',
      subtitle: 'Sleep, mindfulness & gratitude',
      icon: Icons.spa_rounded,
      color: AppColors.tertiary,
    ),
  ];

  void _onComplete() {
    ref.read(localStorageProvider).setOnboardingCompleted();
    context.go('/auth');
  }

  void _onSkipToApp() {
    ref.read(localStorageProvider).setOnboardingCompleted();
    context.go('/today');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-Step Progress Indicator
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixedDim,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceContainerHigh
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Headline
              Text(
                'Build Unbreakable\nMomentum',
                style: AppTypography.displayMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the focus pillars you want to elevate first:',
                style: AppTypography.bodyMedium(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              // Pillar Grid
              Expanded(
                child: ListView.separated(
                  itemCount: _pillars.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final pillar = _pillars[index];
                    final isSelected = _selectedPillars.contains(pillar.title);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            if (_selectedPillars.length > 1) {
                              _selectedPillars.remove(pillar.title);
                            }
                          } else {
                            _selectedPillars.add(pillar.title);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.primary.withOpacity(0.2)
                                  : AppColors.primaryFixed.withOpacity(0.45))
                              : (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.surfaceContainerLowest),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkSurfaceContainerHigh
                                    : AppColors.surfaceContainerHigh),
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: pillar.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                pillar.icon,
                                color: pillar.color,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pillar.title,
                                    style: AppTypography.titleMedium(
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pillar.subtitle,
                                    style: AppTypography.labelMedium(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.textTertiary),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Compound Growth Insight Card
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.secondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1% Better Every Day',
                            style: AppTypography.titleMedium(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ).copyWith(fontSize: 14),
                          ),
                          Text(
                            'Compounding yields 37x growth in 1 year.',
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
              // Actions
              HabitButton(
                label: 'Continue to Setup',
                onPressed: _onComplete,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _onSkipToApp,
                  child: Text(
                    'Explore Offline First',
                    style: AppTypography.button(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ).copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
