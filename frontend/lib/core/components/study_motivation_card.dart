import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class StudyMotivationCard extends StatefulWidget {
  const StudyMotivationCard({super.key});

  @override
  State<StudyMotivationCard> createState() => _StudyMotivationCardState();
}

class _StudyMotivationCardState extends State<StudyMotivationCard> {
  int _currentIndex = 0;

  static const List<({String quote, String author, String tip, IconData icon, Color accentColor})> _motivations = [
    (
      quote: "Success isn't always about greatness. It's about consistency. Consistent hard work leads to success.",
      author: "Dwayne Johnson",
      tip: "Study Hack: Use the 25-minute Pomodoro method to beat procrastination and build momentum.",
      icon: Icons.timer_outlined,
      accentColor: AppColors.secondaryFixed,
    ),
    (
      quote: "You do not rise to the level of your goals. You fall to the level of your systems.",
      author: "James Clear, Atomic Habits",
      tip: "Study Hack: Focus on opening your textbook or code editor for just 2 minutes every single day.",
      icon: Icons.psychology_rounded,
      accentColor: AppColors.primaryContainer,
    ),
    (
      quote: "Deep work is the ability to focus without distraction on a cognitively demanding task.",
      author: "Cal Newport",
      tip: "Study Hack: Put your phone in another room during 50-minute study sprints to double retention.",
      icon: Icons.bolt_rounded,
      accentColor: Color(0xFFFFD54F),
    ),
    (
      quote: "Small disciplines repeated with consistency every day lead to great achievements gained slowly over time.",
      author: "John C. Maxwell",
      tip: "Study Hack: Teach the concept out loud to an imaginary listener (Feynman Technique).",
      icon: Icons.menu_book_rounded,
      accentColor: Color(0xFF3898EC),
    ),
    (
      quote: "The secret of getting ahead is getting started. Break complex tasks into small manageable steps.",
      author: "Mark Twain",
      tip: "Study Hack: Active recall testing produces 50% higher exam retention than passive re-reading.",
      icon: Icons.auto_awesome_rounded,
      accentColor: AppColors.streakFire,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Pick daily motivation based on day of year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    _currentIndex = dayOfYear % _motivations.length;
  }

  void _nextMotivation() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _motivations.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = _motivations[_currentIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E1B2E),
                  const Color(0xFF261F3D),
                  const Color(0xFF1B2428),
                ]
              : [
                  const Color(0xFFF3EEFF),
                  const Color(0xFFE9F9F2),
                  const Color(0xFFFFF7ED),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: item.accentColor.withOpacity(isDark ? 0.35 : 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: item.accentColor.withOpacity(isDark ? 0.15 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Badge & Shuffle Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: item.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 18, color: item.accentColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DAILY STUDY & FLOW WISDOM',
                      style: AppTypography.labelMedium(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ).copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'Next Motivation Tip',
                  icon: Icon(
                    Icons.shuffle_rounded,
                    size: 18,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  onPressed: _nextMotivation,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Inspiring Quote
            Text(
              '“${item.quote}”',
              style: AppTypography.titleMedium(
                color: isDark ? Colors.white : const Color(0xFF1B1B21),
              ).copyWith(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),

            // Author Attribution
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— ${item.author}',
                style: AppTypography.labelMedium(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 11.5),
              ),
            ),
            const SizedBox(height: 8),

            // Actionable Study Tip Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.accentColor.withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_rounded, size: 16, color: item.accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.tip,
                      style: AppTypography.labelMedium(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
