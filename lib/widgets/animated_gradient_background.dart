import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable animated gradient background with particles effect
/// Provides the same stunning UI/UX as the splash screen
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Duration animationDuration;
  final bool enableParticles;

  const AnimatedGradientBackground({
    required this.child,
    this.particleCount = 15,
    this.animationDuration = const Duration(seconds: 20),
    this.enableParticles = true,
    super.key,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _particlesController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _particlesController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _particlesController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Animated gradient background - runs on raster thread
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1E1B4B),
                            const Color(0xFF312E81),
                            Color.lerp(
                              const Color(0xFF1E3A8A),
                              const Color(0xFF312E81),
                              (_glowController.value * 0.3),
                            )!,
                          ]
                        : [
                            const Color(0xFFE0F2FE),
                            Color.lerp(
                              const Color(0xFFFAE8FF),
                              const Color(0xFFE0F2FE),
                              (_glowController.value * 0.3),
                            )!,
                            const Color(0xFFFEF3C7),
                          ],
                  ),
                ),
              );
            },
          ),
        ),

        // Subtle particles background - isolated rendering
        if (widget.enableParticles)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlesPainter(
                    animation: _particlesController.value,
                    isDark: isDark,
                    particleCount: widget.particleCount,
                  ),
                  size: Size.infinite,
                  isComplex: true,
                  willChange: true,
                );
              },
            ),
          ),

        // Content
        widget.child,
      ],
    );
  }
}

/// Particles painter for animated background - optimized for raster thread
class ParticlesPainter extends CustomPainter {
  final double animation;
  final bool isDark;
  final int particleCount;

  ParticlesPainter({
    required this.animation,
    required this.isDark,
    this.particleCount = 15,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Use a single paint object and reuse it
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Pre-calculate sine value outside loop
    final animationSin = math.sin(animation * math.pi * 2);

    for (int i = 0; i < particleCount; i++) {
      final random = math.Random(i);
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Gentle floating animation
      final floatOffset =
          math.sin((animation + random.nextDouble()) * math.pi * 2) * 20;
      final y = baseY + floatOffset;

      final particleSize = 1.5 + (random.nextDouble() * 2.5);
      final opacity = 0.1 + (random.nextDouble() * 0.2);

      paint.color = (isDark ? Colors.white : Colors.black87)
          .withOpacity(opacity * (0.4 + (animationSin * 0.3)));

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    // Only repaint if animation value changed significantly (threshold optimization)
    return (animation - oldDelegate.animation).abs() > 0.01;
  }

  @override
  bool shouldRebuildSemantics(ParticlesPainter oldDelegate) => false;
}
