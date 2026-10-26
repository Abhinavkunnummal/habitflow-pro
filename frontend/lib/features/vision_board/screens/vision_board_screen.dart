import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/services/audio_feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class VisionGoal {
  final String id;
  final String title;
  final String category;
  final String description;
  final String milestone;
  final double progress;
  final String colorHex;
  final IconData icon;
  final String quote;

  VisionGoal({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.milestone,
    required this.progress,
    required this.colorHex,
    required this.icon,
    required this.quote,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'milestone': milestone,
        'progress': progress,
        'colorHex': colorHex,
        'iconCode': icon.codePoint,
        'quote': quote,
      };

  factory VisionGoal.fromMap(Map<String, dynamic> map) => VisionGoal(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        category: map['category'] ?? 'Career & Mastery',
        description: map['description'] ?? '',
        milestone: map['milestone'] ?? '',
        progress: (map['progress'] as num?)?.toDouble() ?? 0.5,
        colorHex: map['colorHex'] ?? '#2563EB',
        icon: map['iconCode'] != null
            ? IconData(map['iconCode'], fontFamily: 'MaterialIcons')
            : Icons.star_rounded,
        quote: map['quote'] ?? '',
      );
}

class VisionBoardScreen extends StatefulWidget {
  const VisionBoardScreen({super.key});

  @override
  State<VisionBoardScreen> createState() => _VisionBoardScreenState();
}

class _VisionBoardScreenState extends State<VisionBoardScreen>
    with SingleTickerProviderStateMixin {
  static const String _prefsKeyCustomGoals = 'habitflow_custom_vision_goals_v1';
  static const String _prefsKeyCustomAffirmations =
      'habitflow_custom_affirmations_v1';

  final List<String> _defaultAffirmations = [
    'I possess boundless concentration. Every focused hour compounds into unstoppable career growth.',
    'Distractions are cheap; deep work is my unfair competitive advantage.',
    'I master complex concepts with calm curiosity and razor-sharp execution.',
    'Consistency is my superpower. I show up daily, execute with precision, and crush my goals.',
    'My mind is clear, disciplined, and locked in on building an extraordinary future.',
    'Every line of code and every chapter studied builds the cathedral of my ambitions.',
    'I thrive under intellectual challenges; hard problems are where my greatest value is forged.',
    'I do not wait for motivation. I cultivate fierce, unwavering discipline.',
    'My career trajectory is exponential because my daily habits are relentless.',
    'I am deeply present in whatever I undertake. My flow state is my sanctuary.',
  ];

  late List<String> _allAffirmations;
  int _currentAffirmationIndex = 0;
  List<VisionGoal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _allAffirmations = List.from(_defaultAffirmations);
    _currentAffirmationIndex = Random().nextInt(_allAffirmations.length);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load custom affirmations
      final customAffs = prefs.getStringList(_prefsKeyCustomAffirmations);
      if (customAffs != null && customAffs.isNotEmpty) {
        _allAffirmations.addAll(customAffs);
      }

      // Load goals
      final rawCustomGoals = prefs.getStringList(_prefsKeyCustomGoals);
      List<VisionGoal> loaded = [];

      if (rawCustomGoals != null && rawCustomGoals.isNotEmpty) {
        for (final raw in rawCustomGoals) {
          try {
            final map = jsonDecode(raw) as Map<String, dynamic>;
            loaded.add(VisionGoal.fromMap(map));
          } catch (_) {}
        }
      }

      // Default core vision pillars
      if (loaded.isEmpty) {
        loaded = [
          VisionGoal(
            id: 'v_career',
            title: 'Top 1% Senior Software Architect',
            category: 'Career Acceleration 🚀',
            description:
                'Master distributed cloud architectures, high-performance systems, and scalable full-stack craft to build market-defining software.',
            milestone: 'Target: Lead tier-1 architecture & 50+ PRs shipped',
            progress: 0.72,
            colorHex: '#2563EB',
            icon: Icons.rocket_launch_rounded,
            quote: 'Execution over excuses. Build systems that outlive today.',
          ),
          VisionGoal(
            id: 'v_focus',
            title: 'Unbreakable 90m Flow State',
            category: 'Deep Concentration 🧠',
            description:
                'Enter frictionless, distraction-free deep work daily. Eliminate phone notifications and context switching.',
            milestone: 'Target: 30 consecutive days of 2+ Pomodoros',
            progress: 0.85,
            colorHex: '#7C3AED',
            icon: Icons.psychology_rounded,
            quote: 'Deep focus is the currency of world-class creators.',
          ),
          VisionGoal(
            id: 'v_learning',
            title: 'Technical & Strategic Polymath',
            category: 'Knowledge & Mastery 📚',
            description:
                'Read 24 transformative engineering, philosophy, and business books this year. Synthesize learnings into real projects.',
            milestone: 'Target: 20 pages read every single morning',
            progress: 0.60,
            colorHex: '#059669',
            icon: Icons.auto_stories_rounded,
            quote: 'The more you learn, the higher your leverage in the world.',
          ),
          VisionGoal(
            id: 'v_autonomy',
            title: 'Financial & Time Autonomy',
            category: 'Freedom & High Leverage 💎',
            description:
                'Develop high-income engineering expertise and scalable digital products to secure complete geographic and financial sovereignty.',
            milestone: 'Target: Launch 2 profitable software side-products',
            progress: 0.48,
            colorHex: '#D97706',
            icon: Icons.diamond_rounded,
            quote: 'Own your time, own your output, own your freedom.',
          ),
          VisionGoal(
            id: 'v_vitality',
            title: 'Peak Energy & Physical Stamina',
            category: 'Bio-Energy & Vitality ⚡',
            description:
                'Uncompromised 7.5 hours of sleep, clean whole food fuel, 3L daily hydration, and relentless physical conditioning.',
            milestone: 'Target: Daily workout & 10k steps maintained',
            progress: 0.80,
            colorHex: '#0284C7',
            icon: Icons.bolt_rounded,
            quote: 'A powerful mind requires an indomitable biological vessel.',
          ),
        ];
      }

      if (mounted) {
        setState(() {
          _goals = loaded;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCustomGoal(VisionGoal goal) async {
    setState(() {
      _goals.insert(0, goal);
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _goals.map((g) => jsonEncode(g.toMap())).toList();
      await prefs.setStringList(_prefsKeyCustomGoals, list);
    } catch (_) {}
  }

  void _shuffleAffirmation() {
    AudioFeedbackService.playReminderChime();
    setState(() {
      _currentAffirmationIndex = (_currentAffirmationIndex + 1) % _allAffirmations.length;
    });
  }

  void _showAddAffirmationDialog() {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Write Focus Affirmation ✍️',
                  style: AppTypography.headline(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ).copyWith(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Program your subconscious mind with high-conviction statements that demand focus and success.',
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              autofocus: true,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. I concentrate deeply for 60 minutes with zero impulse to check my phone.',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceContainer
                    : AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            HabitButton(
              label: 'Save & Ignite Affirmation',
              icon: Icons.check_circle_rounded,
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _allAffirmations.insert(0, text);
                    _currentAffirmationIndex = 0;
                  });
                  Navigator.pop(ctx);
                  AudioFeedbackService.playTaskComplete();
                  final prefs = await SharedPreferences.getInstance();
                  final currentCustom =
                      prefs.getStringList(_prefsKeyCustomAffirmations) ?? [];
                  currentCustom.add(text);
                  await prefs.setStringList(
                      _prefsKeyCustomAffirmations, currentCustom);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVisionDialog() {
    final titleCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final milestoneCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Craft New Vision 🌟',
                    style: AppTypography.headline(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ).copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Define a bold vision for your career, intellect, or physical power.',
                style: AppTypography.bodySmall(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Vision Title (e.g., Staff AI Engineer)',
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceContainer
                      : AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: catCtrl,
                decoration: InputDecoration(
                  labelText: 'Pillar / Category (e.g., Career Mastery 🚀)',
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceContainer
                      : AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Detailed Vision Description',
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceContainer
                      : AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: milestoneCtrl,
                decoration: InputDecoration(
                  labelText: 'Key Daily / Weekly Milestone',
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceContainer
                      : AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              HabitButton(
                label: 'Anchor Vision to Board',
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  if (title.isNotEmpty) {
                    final newGoal = VisionGoal(
                      id: 'v_${DateTime.now().millisecondsSinceEpoch}',
                      title: title,
                      category: catCtrl.text.trim().isNotEmpty
                          ? catCtrl.text.trim()
                          : 'Ambition & Career',
                      description: descCtrl.text.trim().isNotEmpty
                          ? descCtrl.text.trim()
                          : 'Relentless execution towards personal mastery.',
                      milestone: milestoneCtrl.text.trim().isNotEmpty
                          ? milestoneCtrl.text.trim()
                          : 'Daily deliberate practice',
                      progress: 0.50,
                      colorHex: '#7C3AED',
                      icon: Icons.flag_circle_rounded,
                      quote: 'Consistency turns distant dreams into inevitable reality.',
                    );
                    Navigator.pop(ctx);
                    AudioFeedbackService.playTaskComplete();
                    _saveCustomGoal(newGoal);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseHex(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeAffirmation = _allAffirmations[_currentAffirmationIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/today');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Vision & Mindset Board',
            style: AppTypography.headline(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ).copyWith(fontSize: 19),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/today');
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_task_rounded),
              tooltip: 'Add Affirmation',
              onPressed: _showAddAffirmationDialog,
            ),
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_rounded),
              tooltip: 'Add Vision Pillar',
              onPressed: _showAddVisionDialog,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle Header
                      Text(
                        'Engineer your career & fuel deep concentration',
                        style: AppTypography.labelMedium(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ).copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 14),

                      // Daily Focus Affirmation Bento
                      AuroraCard(
                        hasAuroraBorder: true,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.16),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.self_improvement_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Daily Focus Affirmation',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        color: isDark
                                            ? AppColors.primaryFixedDim
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  tooltip: 'Shuffle Affirmation',
                                  onPressed: _shuffleAffirmation,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                '"$activeAffirmation"',
                                key: ValueKey<int>(_currentAffirmationIndex),
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.45,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _shuffleAffirmation,
                                  icon: const Icon(Icons.autorenew_rounded, size: 16),
                                  label: const Text('New Affirmation 🎲'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? AppColors.darkSurfaceContainer
                                        : AppColors.surfaceContainerLow,
                                    foregroundColor: isDark ? Colors.white : Colors.black87,
                                    elevation: 0,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: _showAddAffirmationDialog,
                                  icon: const Icon(Icons.add_rounded, size: 16),
                                  label: const Text('Add Custom'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Section Header: Career & Mastery Vision Pillars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Career & Mastery Pillars',
                            style: AppTypography.headline(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ).copyWith(fontSize: 18),
                          ),
                          TextButton.icon(
                            onPressed: _showAddVisionDialog,
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add Vision'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Vision Cards List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _goals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          final goalColor = _parseHex(goal.colorHex);

                          return AuroraCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Icon + Category + Status Chip
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            goalColor.withOpacity(0.9),
                                            goalColor.withOpacity(0.6),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        goal.icon,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            goal.category.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.6,
                                              color: goalColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            goal.title,
                                            style: AppTypography.titleMedium(
                                              color: isDark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.textPrimary,
                                            ).copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Description
                                Text(
                                  goal.description,
                                  style: AppTypography.bodySmall(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ).copyWith(height: 1.4),
                                ),
                                const SizedBox(height: 12),

                                // Target Milestone Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: goalColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: goalColor.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.flag_rounded,
                                        size: 14,
                                        color: goalColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          goal.milestone,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Progress Bar and Quick Action
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Mastery Alignment',
                                                style: AppTypography.labelSmall(
                                                  color: isDark
                                                      ? AppColors.darkTextTertiary
                                                      : AppColors.textTertiary,
                                                ),
                                              ),
                                              Text(
                                                '${(goal.progress * 100).toInt()}%',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: goalColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(9999),
                                            child: LinearProgressIndicator(
                                              value: goal.progress,
                                              minHeight: 6,
                                              backgroundColor: isDark
                                                  ? AppColors.darkSurfaceContainerHigh
                                                  : AppColors.surfaceContainerHigh,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      goalColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        AudioFeedbackService.playReminderChime();
                                        context.go(
                                          '/timer?habitTitle=${Uri.encodeComponent(goal.title)}',
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.timer_outlined,
                                        size: 14,
                                      ),
                                      label: const Text(
                                        'Focus Flow',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: goalColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: const StadiumBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Bottom Deep Work Flow Ignition Button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF7C3AED)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Unleash 25-Min Deep Focus Flow',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Transform ambitious visions into relentless daily execution.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () {
                                AudioFeedbackService.playTaskComplete();
                                context.go(
                                  '/timer?habitTitle=${Uri.encodeComponent("Deep Focus Mastery")}',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_arrow_rounded),
                                  SizedBox(width: 6),
                                  Text(
                                    'Start Flow Session Now',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
