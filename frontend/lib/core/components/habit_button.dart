import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum HabitButtonVariant { primary, secondary, outline, ghost }

class HabitButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final HabitButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const HabitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = HabitButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 20, color: _getTextColor(isDark)),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: AppTypography.button(color: _getTextColor(isDark)),
          ),
        ],
      ],
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(9999),
          child: Ink(
            decoration: _getBoxDecoration(isDark),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(bool isDark) {
    switch (variant) {
      case HabitButtonVariant.primary:
        return Colors.white;
      case HabitButtonVariant.secondary:
        return AppColors.secondary;
      case HabitButtonVariant.outline:
        return isDark ? AppColors.darkTextPrimary : AppColors.primary;
      case HabitButtonVariant.ghost:
        return isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    }
  }

  BoxDecoration _getBoxDecoration(bool isDark) {
    switch (variant) {
      case HabitButtonVariant.primary:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.32),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case HabitButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.secondaryFixed,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryFixed.withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case HabitButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isDark ? AppColors.darkSurfaceContainerHigh : AppColors.primaryFixedDim,
            width: 1.5,
          ),
        );
      case HabitButtonVariant.ghost:
        return BoxDecoration(
          color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
        );
    }
  }
}
