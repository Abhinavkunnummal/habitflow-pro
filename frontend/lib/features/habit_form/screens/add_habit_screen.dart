import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/components/habit_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../dashboard/models/habit.dart';
import '../../dashboard/providers/habits_provider.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Morning';
  String _habitType = 'build'; // 'build' or 'quit'
  String _selectedIcon = 'water_drop';
  String _selectedColor = '#79FAC2';
  int _targetValue = 1;
  String _targetUnit = 'times';
  String _reminderTime = '08:00';
  bool _reminderEnabled = true;

  final List<String> _categories = [
    'Morning',
    'Health & Fitness',
    'Learning & Career',
    'Evening',
    'Mindfulness',
  ];

  final List<({String name, IconData icon})> _icons = [
    (name: 'water_drop', icon: Icons.water_drop_rounded),
    (name: 'menu_book', icon: Icons.menu_book_rounded),
    (name: 'fitness_center', icon: Icons.fitness_center_rounded),
    (name: 'spa', icon: Icons.spa_rounded),
    (name: 'bolt', icon: Icons.bolt_rounded),
    (name: 'psychology', icon: Icons.psychology_rounded),
    (name: 'bedtime', icon: Icons.bedtime_rounded),
    (name: 'savings', icon: Icons.savings_rounded),
  ];

  final List<String> _colors = [
    '#79FAC2', // Mint
    '#5D3ADC', // Violet
    '#006C4B', // Forest
    '#844D2A', // Terracotta
    '#FF5E36', // Flame
    '#3898EC', // Sky
  ];

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

  void _saveHabit() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit title')),
      );
      return;
    }

    final newHabit = Habit(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
      category: _selectedCategory,
      type: _habitType,
      icon: _selectedIcon,
      colorHex: _selectedColor,
      targetValue: _targetValue,
      targetUnit: _targetUnit,
      reminderTime: _reminderEnabled ? _reminderTime : null,
      createdAt: DateTime.now(),
    );

    ref.read(habitsProvider.notifier).addHabit(newHabit);
    context.go('/today');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Habit',
          style: AppTypography.headline(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/today'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Build vs Quit Habit Selector
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _habitType = 'build'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _habitType == 'build'
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkSurfaceContainer
                                  : AppColors.surfaceContainerLow),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Center(
                          child: Text(
                            'Build Habit',
                            style: AppTypography.button(
                              color: _habitType == 'build'
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            ).copyWith(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _habitType = 'quit'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _habitType == 'quit'
                              ? AppColors.streakFire
                              : (isDark
                                  ? AppColors.darkSurfaceContainer
                                  : AppColors.surfaceContainerLow),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Center(
                          child: Text(
                            'Quit Habit',
                            style: AppTypography.button(
                              color: _habitType == 'quit'
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            ).copyWith(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title Field
              HabitTextField(
                controller: _titleController,
                label: 'Habit Name',
                hintText: 'e.g. Morning Hydration, 20m Yoga',
                prefixIcon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 16),

              // Motivation / Description Field
              HabitTextField(
                controller: _descController,
                label: 'Motivation / Why It Matters (Optional)',
                hintText: 'e.g. Keeps my focus sharp before 9 AM',
                prefixIcon: Icons.lightbulb_outline_rounded,
              ),
              const SizedBox(height: 20),

              // Category Selector
              Text(
                'Focus Category',
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceContainer
                        : AppColors.surfaceContainerLow,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    shape: const StadiumBorder(),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Icon Selector
              Text(
                'Icon Badge',
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = _icons[index];
                    final isSelected = _selectedIcon == item.name;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = item.name),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkSurfaceContainer
                                  : AppColors.surfaceContainerLowest),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkSurfaceContainerHigh
                                    : AppColors.surfaceContainerHigh),
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Color Palette Swatches
              Text(
                'Card Accent Color',
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _colors.map((hex) {
                  final color = _parseColor(hex);
                  final isSelected = _selectedColor == hex;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.55),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.black87, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Target Metric Stepper
              AuroraCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Goal Target',
                          style: AppTypography.titleMedium(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ).copyWith(fontSize: 14),
                        ),
                        Text(
                          '$_targetValue $_targetUnit per day',
                          style: AppTypography.labelMedium(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_targetValue > 1) {
                              setState(() => _targetValue--);
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                        ),
                        Text(
                          '$_targetValue',
                          style: AppTypography.titleMedium(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => _targetValue++);
                          },
                          icon: const Icon(Icons.add_circle_outline_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Save CTA
              HabitButton(
                label: 'Save & Track Habit',
                icon: Icons.check_rounded,
                onPressed: _saveHabit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
