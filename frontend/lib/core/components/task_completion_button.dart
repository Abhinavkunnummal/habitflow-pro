import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/audio_feedback_service.dart';
import '../theme/app_colors.dart';

/// Interactive habit completion button featuring scale bounce,
/// radial sparkle particles, and audio feedback.
class TaskCompletionButton extends StatefulWidget {
  final bool isCompleted;
  final VoidCallback onToggle;
  final double size;

  const TaskCompletionButton({
    super.key,
    required this.isCompleted,
    required this.onToggle,
    this.size = 42,
  });

  @override
  State<TaskCompletionButton> createState() => _TaskCompletionButtonState();
}

class _TaskCompletionButtonState extends State<TaskCompletionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.25)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_controller);

    _particleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final willComplete = !widget.isCompleted;
    if (willComplete) {
      _controller.forward(from: 0.0);
      AudioFeedbackService.playTaskComplete();
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size + 24,
        height: widget.size + 24,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Radial Sparkle Particles (active when completing)
            AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                if (!_controller.isAnimating) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  size: Size(widget.size + 24, widget.size + 24),
                  painter: _SparkleParticlesPainter(
                    progress: _particleAnimation.value,
                    radius: widget.size * 0.75,
                  ),
                );
              },
            ),

            // Animated Checkbox Button
            ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.isCompleted
                      ? AppColors.secondaryFixed
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isCompleted
                        ? AppColors.secondaryFixed
                        : (isDark
                            ? AppColors.darkSurfaceContainerHigh
                            : AppColors.surfaceContainerHigh),
                    width: 2.2,
                  ),
                  boxShadow: widget.isCompleted
                      ? [
                          BoxShadow(
                            color: AppColors.secondaryFixed.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: widget.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('completed_check'),
                            color: AppColors.secondary,
                            size: 24,
                          )
                        : const SizedBox.shrink(key: ValueKey('empty_check')),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkleParticlesPainter extends CustomPainter {
  final double progress;
  final double radius;

  _SparkleParticlesPainter({
    required this.progress,
    required this.radius,
  });

  static const List<Color> _particleColors = [
    AppColors.secondaryFixed,
    AppColors.primaryContainer,
    AppColors.streakFire,
    Color(0xFFFFD54F), // Gold
    AppColors.secondary,
    Color(0xFF8B5CF6), // Purple
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final count = _particleColors.length;
    final currentDist = radius * (0.6 + progress * 0.7);
    final particleRadius = (1.0 - progress) * 3.5;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count) + (progress * 0.5);
      final offset = Offset(
        center.dx + currentDist * math.cos(angle),
        center.dy + currentDist * math.sin(angle),
      );

      final paint = Paint()
        ..color = _particleColors[i].withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(offset, particleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkleParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
