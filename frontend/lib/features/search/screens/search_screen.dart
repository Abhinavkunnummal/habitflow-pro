import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../dashboard/models/habit.dart';
import '../../dashboard/providers/habits_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<Habit> _curatedHabits = [
    Habit(
      id: 'curated_sun',
      title: 'Morning Sun Exposure',
      description: '10-15 mins of outdoor natural light upon waking',
      category: 'Morning',
      type: 'build',
      icon: 'bolt',
      colorHex: '#FF5E36',
      targetValue: 15,
      targetUnit: 'mins',
      createdAt: DateTime.now(),
    ),
    Habit(
      id: 'curated_meditate',
      title: 'Vipassana Meditation',
      description: 'Observe breath and cultivate equanimity',
      category: 'Mindfulness',
      type: 'build',
      icon: 'spa',
      colorHex: '#79FAC2',
      targetValue: 10,
      targetUnit: 'mins',
      createdAt: DateTime.now(),
    ),
    Habit(
      id: 'curated_walk',
      title: '10,000 Steps Daily',
      description: 'Low-intensity steady state metabolic movement',
      category: 'Health & Fitness',
      type: 'build',
      icon: 'fitness_center',
      colorHex: '#006C4B',
      targetValue: 10000,
      targetUnit: 'steps',
      createdAt: DateTime.now(),
    ),
    Habit(
      id: 'curated_screen',
      title: 'No Screens After 10 PM',
      description: 'Promote melatonin release for deep restorative sleep',
      category: 'Evening',
      type: 'quit',
      icon: 'bedtime',
      colorHex: '#844D2A',
      targetValue: 1,
      targetUnit: 'session',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addCurated(Habit template) {
    final habit = template.copyWith(id: const Uuid().v4());
    ref.read(habitsProvider.notifier).addHabit(habit);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${habit.title}" added to your routine!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = _searchController.text.toLowerCase();

    final filtered = _curatedHabits.where((h) {
      if (query.isNotEmpty && !h.title.toLowerCase().contains(query)) {
        return false;
      }
      if (_selectedCategory != 'All' && h.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Habit Directory',
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
              HabitTextField(
                controller: _searchController,
                label: 'Search Curated Habits',
                hintText: 'e.g. Meditation, Steps, Sun, Sleep...',
                prefixIcon: Icons.search_rounded,
              ),
              const SizedBox(height: 20),

              Text(
                'Popular Pre-Built Routines',
                style: AppTypography.headline(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final habit = filtered[index];

                  return AuroraCard(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: AppTypography.titleMedium(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ).copyWith(fontSize: 14),
                              ),
                              if (habit.description != null)
                                Text(
                                  habit.description!,
                                  style: AppTypography.labelMedium(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                          onPressed: () => _addCurated(habit),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
