import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AuroraProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int completedCount;
  final int totalCount;
  final double size;
  final double strokeWidth;

  const AuroraProgressRing({
    super.key,
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    this.size = 140,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (progress * 100).toInt();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _AuroraRingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              trackColor: isDark
                  ? AppColors.darkSurfaceContainerHigh
                  : AppColors.primaryFixed.withOpacity(0.4),
              isDark: isDark,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: AppTypography.displayLarge(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(fontSize: size * 0.22, height: 1.1),
              ),
              const SizedBox(height: 2),
              Text(
                '$completedCount of $totalCount done',
                style: AppTypography.labelMedium(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ).copyWith(fontSize: size * 0.09),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuroraRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final bool isDark;

  _AuroraRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.001) return;

    // Foreground arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: const [
        AppColors.primary,
        AppColors.primaryContainer,
        AppColors.secondaryFixed,
      ],
      stops: const [0.0, 0.6, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _AuroraRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.isDark != isDark;
  }
}
