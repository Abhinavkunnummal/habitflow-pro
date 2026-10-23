import 'package:flutter/material.dart';
import '../services/motivation_quotes_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class StudyMotivationCard extends StatefulWidget {
  const StudyMotivationCard({super.key});

  @override
  State<StudyMotivationCard> createState() => _StudyMotivationCardState();
}

class _StudyMotivationCardState extends State<StudyMotivationCard> {
  late MotivationQuote _quote;

  @override
  void initState() {
    super.initState();
    // Pick a fresh random motivation quote on every load/refresh
    _quote = MotivationQuotesService.getRandomQuote();
  }

  void _nextMotivation() {
    setState(() {
      _quote = MotivationQuotesService.getRandomQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          color: _quote.accentColor.withOpacity(isDark ? 0.35 : 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _quote.accentColor.withOpacity(isDark ? 0.15 : 0.1),
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
                        color: _quote.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_quote.icon, size: 18, color: _quote.accentColor),
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
                  tooltip: 'Shuffle Inspiration',
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
              '“${_quote.quote}”',
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
                '— ${_quote.author}',
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
                  color: _quote.accentColor.withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_rounded, size: 16, color: _quote.accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _quote.tip,
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
