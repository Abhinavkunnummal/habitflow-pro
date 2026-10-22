import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/components/habit_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _selectedMoodIndex = 1;
  final _winsController = TextEditingController();
  final _frictionController = TextEditingController();
  final _gratitudeController = TextEditingController();

  final List<({String emoji, String label})> _moods = [
    (emoji: '😄', label: 'Energized'),
    (emoji: '😊', label: 'Flow'),
    (emoji: '😐', label: 'Steady'),
    (emoji: '😔', label: 'Drained'),
    (emoji: '😫', label: 'Friction'),
  ];

  @override
  void dispose() {
    _winsController.dispose();
    _frictionController.dispose();
    _gratitudeController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reflection saved to offline history ✓')),
    );
    context.go('/calendar');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Reflection',
          style: AppTypography.headline(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/calendar'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Evening Affirmation
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.nightlight_round_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        '"Self-discipline is the highest form of self-love."',
                        style: AppTypography.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ).copyWith(fontStyle: FontStyle.italic, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Mood Selector
              Text(
                'Today\'s Energy State',
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_moods.length, (index) {
                  final isSelected = _selectedMoodIndex == index;
                  final mood = _moods[index];

                  return GestureDetector(
                    onTap: () => setState(() => _selectedMoodIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryFixed
                            : (isDark
                                ? AppColors.darkSurfaceContainer
                                : AppColors.surfaceContainerLowest),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkSurfaceContainerHigh
                                  : AppColors.surfaceContainerHigh),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(
                            mood.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primary : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Structured Prompts
              HabitTextField(
                controller: _winsController,
                label: 'Wins & Breakthroughs',
                hintText: 'What micro-victory did you claim today?',
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              HabitTextField(
                controller: _frictionController,
                label: 'Friction & Triggers',
                hintText: 'What disrupted your flow or distracted you?',
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              HabitTextField(
                controller: _gratitudeController,
                label: 'Gratitude Anchor',
                hintText: 'One thing you are genuinely thankful for today.',
                maxLines: 2,
              ),
              const SizedBox(height: 28),

              HabitButton(
                label: 'Save Reflection',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _saveEntry,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
