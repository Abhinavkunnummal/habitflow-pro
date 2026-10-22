import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class StreakBadge extends StatelessWidget {
  final int streakDays;
  final bool compact;

  const StreakBadge({
    super.key,
    required this.streakDays,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EB),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xFFFFD4C4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.streakFire,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            compact ? '$streakDays' : '$streakDays days',
            style: AppTypography.button(color: AppColors.streakFire).copyWith(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
