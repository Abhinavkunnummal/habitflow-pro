import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/components/habit_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/goal_model.dart';
import '../providers/goals_provider.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _titleController = TextEditingController();
  String _selectedTier = 'Silver';
  int _targetDays = 30;
  int _xpReward = 250;

  final List<String> _tiers = ['Bronze (7d)', 'Silver (30d)', 'Gold (100d)'];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onTierSelected(String tier) {
    setState(() {
      _selectedTier = tier;
      if (tier.startsWith('Bronze')) {
        _targetDays = 7;
        _xpReward = 100;
      } else if (tier.startsWith('Gold')) {
        _targetDays = 100;
        _xpReward = 500;
      } else {
        _targetDays = 30;
        _xpReward = 250;
      }
    });
  }

  Future<void> _handleSaveGoal() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal title')),
      );
      return;
    }

    final rawTier = _selectedTier.split(' ')[0]; // 'Bronze', 'Silver', 'Gold'

    final newGoal = GoalModel(
      id: const Uuid().v4(),
      title: title,
      tier: rawTier,
      targetValue: _targetDays,
      targetUnit: 'days',
      currentProgress: 0,
      status: 'active',
      xpReward: _xpReward,
      createdAt: DateTime.now(),
    );

    await ref.read(goalsProvider.notifier).addGoal(newGoal);

    if (mounted) {
      context.go('/goals');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Horizon Goal',
          style: AppTypography.headline(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/goals'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Reward Preview Card
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF1EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.military_tech_rounded,
                        color: Color(0xFFE6A100),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleController.text.isNotEmpty
                                ? _titleController.text
                                : '30-Day Flow Mastery',
                            style: AppTypography.titleMedium(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+$_xpReward XP Reward upon completion ($_targetDays days)',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              HabitTextField(
                controller: _titleController,
                label: 'Goal Title',
                hintText: 'e.g. 30 Days of Morning Hydration',
              ),
              const SizedBox(height: 20),

              Text(
                'Milestone Tier',
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tiers.map((tier) {
                  final isSelected = _selectedTier == tier;
                  return ChoiceChip(
                    label: Text(tier),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceContainer
                        : AppColors.surfaceContainerLow,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: FontWeight.bold,
                    ),
                    shape: const StadiumBorder(),
                    onSelected: (val) {
                      if (val) _onTierSelected(tier);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              HabitButton(
                label: 'Lock In Goal',
                onPressed: _handleSaveGoal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
