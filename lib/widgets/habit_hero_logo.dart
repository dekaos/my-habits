import 'package:flutter/material.dart';
import 'dart:math' as math;

class HabitHeroLogo extends StatefulWidget {
  final double size;

  const HabitHeroLogo({
    super.key,
    this.size = 90,
  });

  @override
  State<HabitHeroLogo> createState() => _HabitHeroLogoState();
}

class _HabitHeroLogoState extends State<HabitHeroLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: widget.size + 10,
                height: widget.size + 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
            // Logo container
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: HabitHeroLogoPainter(
                  primaryColor: isDark
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  accentColor: Theme.of(context).colorScheme.secondary,
                  animation: 1.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class HabitHeroLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final double animation;

  HabitHeroLogoPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.55;

    _drawProgressCircle(canvas, center, radius);
    _drawCheckmark(canvas, center, radius);
  }

  void _drawProgressCircle(Canvas canvas, Offset center, double radius) {
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = primaryColor.withValues(alpha: 0.2);

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = primaryColor;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * animation,
      false,
      progressPaint,
    );
  }

  void _drawCheckmark(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = primaryColor;

    final checkPath = Path();
    final checkSize = radius * 0.7;

    checkPath.moveTo(
      center.dx - checkSize * 0.35,
      center.dy,
    );
    checkPath.lineTo(
      center.dx - checkSize * 0.05,
      center.dy + checkSize * 0.35,
    );
    checkPath.lineTo(
      center.dx + checkSize * 0.45,
      center.dy - checkSize * 0.35,
    );

    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(HabitHeroLogoPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        primaryColor != oldDelegate.primaryColor ||
        accentColor != oldDelegate.accentColor;
  }
}
