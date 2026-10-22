import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/components/habit_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../dashboard/providers/habits_provider.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final String habitId;

  const EditHabitScreen({super.key, required this.habitId});

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _streakShield = false;

  @override
  void initState() {
    super.initState();
    final habits = ref.read(habitsProvider);
    final habit = habits.firstWhere(
      (h) => h.id == widget.habitId,
      orElse: () => habits.first,
    );

    _titleController = TextEditingController(text: habit.title);
    _descController = TextEditingController(text: habit.description ?? '');
    _streakShield = habit.streakShieldEnabled;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final habits = ref.read(habitsProvider);
    final habit = habits.firstWhere((h) => h.id == widget.habitId);

    final updated = habit.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      streakShieldEnabled: _streakShield,
    );

    ref.read(habitsProvider.notifier).updateHabit(updated);
    context.go('/habit/${widget.habitId}');
  }

  void _deleteHabit() {
    ref.read(habitsProvider.notifier).deleteHabit(widget.habitId);
    context.go('/today');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Habit',
          style: AppTypography.headline(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/habit/${widget.habitId}'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HabitTextField(
                controller: _titleController,
                label: 'Habit Title',
              ),
              const SizedBox(height: 16),
              HabitTextField(
                controller: _descController,
                label: 'Motivation Note',
              ),
              const SizedBox(height: 20),

              // Streak Shield Toggle
              AuroraCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Streak Shield',
                              style: AppTypography.titleMedium(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ).copyWith(fontSize: 14),
                            ),
                            Text(
                              'Protects streak if you miss 1 day',
                              style: AppTypography.labelMedium(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _streakShield,
                      activeColor: AppColors.secondaryFixed,
                      onChanged: (val) => setState(() => _streakShield = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              HabitButton(
                label: 'Save Changes',
                onPressed: _saveChanges,
              ),
              const SizedBox(height: 16),
              HabitButton(
                label: 'Delete Habit',
                variant: HabitButtonVariant.outline,
                onPressed: _deleteHabit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
