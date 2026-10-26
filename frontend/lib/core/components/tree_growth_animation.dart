import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated Focus Tree that dynamically grows from a tiny sprout into a majestic
/// blooming tree based on focus timer progress (0.0 to 1.0).
class TreeGrowthAnimation extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final bool isCompleted;

  const TreeGrowthAnimation({
    super.key,
    required this.progress,
    this.size = 180,
    this.isCompleted = false,
  });

  @override
  State<TreeGrowthAnimation> createState() => _TreeGrowthAnimationState();
}

class _TreeGrowthAnimationState extends State<TreeGrowthAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _swayController;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  String _getStageTitle(double p) {
    if (widget.isCompleted || p >= 1.0) return '🌸 Ancient Bloom Tree';
    if (p >= 0.80) return '🌳 Flourishing Canopy';
    if (p >= 0.50) return '🪴 Branching Young Tree';
    if (p >= 0.20) return '🌿 Growing Sapling';
    return '🌱 Sprouting Seed';
  }

  @override
  Widget build(BuildContext context) {
    final clampedProgress = widget.progress.clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, child) {
        final sway = math.sin(_swayController.value * math.pi) * 0.04;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _TreePainter(
                  progress: clampedProgress,
                  sway: sway,
                  isCompleted: widget.isCompleted || clampedProgress >= 1.0,
                  pulse: _swayController.value,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondaryFixed.withOpacity(0.18),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: AppColors.secondaryFixed.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Text(
                _getStageTitle(clampedProgress),
                style: const TextStyle(
                  color: AppColors.secondaryFixed,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TreePainter extends CustomPainter {
  final double progress;
  final double sway;
  final bool isCompleted;
  final double pulse;

  _TreePainter({
    required this.progress,
    required this.sway,
    required this.isCompleted,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final width = size.width;
    final height = size.height;

    // 1. Draw Soil Mound Base
    final soilPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4A3525),
          const Color(0xFF2E1F14),
          const Color(0xFF1B120B),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(size.width / 2, height - 10),
        width: width * 0.7,
        height: 35,
      ));

    final soilPath = Path()
      ..moveTo(width * 0.2, height - 8)
      ..quadraticBezierTo(width * 0.5, height - 28, width * 0.8, height - 8)
      ..quadraticBezierTo(width * 0.5, height, width * 0.2, height - 8)
      ..close();
    canvas.drawPath(soilPath, soilPaint);

    // Subtle grass patch atop mound
    final grassPaint = Paint()
      ..color = const Color(0xFF006C4B).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width / 2, height - 16),
        width: width * 0.38,
        height: 10,
      ),
      grassPaint,
    );

    // 2. STAGE 1: Sprout (0.0 to 0.20)
    if (progress < 0.20) {
      final sproutP = progress / 0.20;
      final sproutHeight = 15.0 + (sproutP * 25.0);

      final stemPaint = Paint()
        ..color = const Color(0xFF79FAC2)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final stemPath = Path()
        ..moveTo(center.dx, height - 16)
        ..quadraticBezierTo(
          center.dx + (sway * 40),
          height - 16 - (sproutHeight * 0.6),
          center.dx + (sway * 70),
          height - 16 - sproutHeight,
        );
      canvas.drawPath(stemPath, stemPaint);

      // Two tiny unfurling leaves
      final leafPaint = Paint()
        ..color = const Color(0xFF00E676)
        ..style = PaintingStyle.fill;

      final tipX = center.dx + (sway * 70);
      final tipY = height - 16 - sproutHeight;

      // Left leaf
      canvas.save();
      canvas.translate(tipX, tipY);
      canvas.rotate(-0.6 + sway);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-8, -4), width: 14 * sproutP + 4, height: 7 * sproutP + 2),
        leafPaint,
      );
      canvas.restore();

      // Right leaf
      canvas.save();
      canvas.translate(tipX, tipY);
      canvas.rotate(0.6 + sway);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(8, -4), width: 14 * sproutP + 4, height: 7 * sproutP + 2),
        leafPaint,
      );
      canvas.restore();
      return;
    }

    // 3. STAGES 2, 3, 4, 5: Growing Trunk & Foliage
    final trunkProgress = ((progress - 0.20) / 0.80).clamp(0.0, 1.0);
    final trunkHeight = 40.0 + (trunkProgress * (height * 0.48));
    final trunkBaseWidth = 6.0 + (trunkProgress * 8.0);
    final trunkTopWidth = 3.0 + (trunkProgress * 5.0);

    final trunkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF5D4037),
          const Color(0xFF795548),
          const Color(0xFF8D6E63),
        ],
      ).createShader(Rect.fromLTWH(0, height - 16 - trunkHeight, width, trunkHeight));

    final trunkPath = Path()
      ..moveTo(center.dx - trunkBaseWidth / 2, height - 16)
      ..quadraticBezierTo(
        center.dx - trunkBaseWidth / 3 + (sway * 20),
        height - 16 - trunkHeight * 0.5,
        center.dx - trunkTopWidth / 2 + (sway * 50),
        height - 16 - trunkHeight,
      )
      ..lineTo(
        center.dx + trunkTopWidth / 2 + (sway * 50),
        height - 16 - trunkHeight,
      )
      ..quadraticBezierTo(
        center.dx + trunkBaseWidth / 3 + (sway * 20),
        height - 16 - trunkHeight * 0.5,
        center.dx + trunkBaseWidth / 2,
        height - 16,
      )
      ..close();
    canvas.drawPath(trunkPath, trunkPaint);

    // Branches if progress >= 0.40
    if (progress >= 0.40) {
      final branchPaint = Paint()
        ..color = const Color(0xFF795548)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final branchProgress = ((progress - 0.40) / 0.60).clamp(0.0, 1.0);
      final bLen = 25.0 * branchProgress;

      // Left branch
      canvas.drawPath(
        Path()
          ..moveTo(center.dx - 2 + (sway * 25), height - 16 - trunkHeight * 0.65)
          ..quadraticBezierTo(
            center.dx - bLen * 0.6,
            height - 16 - trunkHeight * 0.72,
            center.dx - bLen,
            height - 16 - trunkHeight * 0.78,
          ),
        branchPaint,
      );

      // Right branch
      canvas.drawPath(
        Path()
          ..moveTo(center.dx + 2 + (sway * 30), height - 16 - trunkHeight * 0.75)
          ..quadraticBezierTo(
            center.dx + bLen * 0.6,
            height - 16 - trunkHeight * 0.82,
            center.dx + bLen,
            height - 16 - trunkHeight * 0.88,
          ),
        branchPaint,
      );
    }

    // Foliage Canopies
    final foliageProgress = ((progress - 0.30) / 0.70).clamp(0.0, 1.0);
    final canopyRadius = 18.0 + (foliageProgress * 36.0);
    final canopyCenterY = height - 16 - trunkHeight - (canopyRadius * 0.55);
    final canopyCenterX = center.dx + (sway * 50);

    // Foliage gradient
    final leafGradient = RadialGradient(
      colors: isCompleted
          ? [
              const Color(0xFF79FAC2),
              const Color(0xFF00C853),
              const Color(0xFF007E33),
            ]
          : [
              const Color(0xFF69F0AE),
              const Color(0xFF00C853),
              const Color(0xFF1B5E20),
            ],
    ).createShader(Rect.fromCircle(
      center: Offset(canopyCenterX, canopyCenterY),
      radius: canopyRadius * 1.2,
    ));

    final foliagePaint = Paint()..shader = leafGradient;

    // Draw main fluffy canopy spheres
    canvas.drawCircle(Offset(canopyCenterX, canopyCenterY), canopyRadius, foliagePaint);
    canvas.drawCircle(
      Offset(canopyCenterX - canopyRadius * 0.55, canopyCenterY + canopyRadius * 0.25),
      canopyRadius * 0.75,
      foliagePaint,
    );
    canvas.drawCircle(
      Offset(canopyCenterX + canopyRadius * 0.55, canopyCenterY + canopyRadius * 0.2),
      canopyRadius * 0.78,
      foliagePaint,
    );
    canvas.drawCircle(
      Offset(canopyCenterX, canopyCenterY - canopyRadius * 0.45),
      canopyRadius * 0.7,
      foliagePaint,
    );

    // Stage 5 & Completed: Blooming Flowers & Floating Sparkles
    if (isCompleted || progress >= 0.85) {
      final flowerPaint = Paint()
        ..color = const Color(0xFFFF80AB) // Cherry blossom pink
        ..style = PaintingStyle.fill;

      final goldFlowerPaint = Paint()
        ..color = const Color(0xFFFFD54F) // Golden blossom
        ..style = PaintingStyle.fill;

      final blossomOffsets = [
        Offset(canopyCenterX - canopyRadius * 0.4, canopyCenterY - canopyRadius * 0.2),
        Offset(canopyCenterX + canopyRadius * 0.35, canopyCenterY - canopyRadius * 0.3),
        Offset(canopyCenterX - canopyRadius * 0.2, canopyCenterY + canopyRadius * 0.3),
        Offset(canopyCenterX + canopyRadius * 0.45, canopyCenterY + canopyRadius * 0.15),
        Offset(canopyCenterX, canopyCenterY - canopyRadius * 0.6),
        Offset(canopyCenterX + canopyRadius * 0.1, canopyCenterY + canopyRadius * 0.05),
      ];

      for (int i = 0; i < blossomOffsets.length; i++) {
        final pos = blossomOffsets[i];
        final paint = (i % 2 == 0) ? flowerPaint : goldFlowerPaint;
        final r = (i % 2 == 0) ? 4.5 : 3.5;

        // Draw 4-petal flower
        canvas.drawCircle(pos, r, paint);
        canvas.drawCircle(pos.translate(0, -2), r * 0.75, paint);
        canvas.drawCircle(pos.translate(0, 2), r * 0.75, paint);
        canvas.drawCircle(pos.translate(-2, 0), r * 0.75, paint);
        canvas.drawCircle(pos.translate(2, 0), r * 0.75, paint);
        // Center pistil
        canvas.drawCircle(pos, 1.8, Paint()..color = Colors.white);
      }

      // Floating Aura Sparkles if completed
      if (isCompleted) {
        final sparklePaint = Paint()
          ..color = Colors.white.withOpacity(0.7 + pulse * 0.3)
          ..style = PaintingStyle.fill;

        for (int i = 0; i < 8; i++) {
          final angle = (i * math.pi / 4) + (pulse * math.pi * 0.3);
          final dist = canopyRadius * 1.35 + (math.sin(pulse * math.pi * 2 + i) * 8);
          final sx = canopyCenterX + math.cos(angle) * dist;
          final sy = canopyCenterY + math.sin(angle) * dist * 0.8;
          canvas.drawCircle(Offset(sx, sy), 2.5 + (i % 2), sparklePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.sway != sway ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.pulse != pulse;
  }
}
