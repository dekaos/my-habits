import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particlesController;
  late AnimationController _textController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoRotation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

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

    _startAnimations();
    _checkAuthStatus();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    final authState = ref.read(authProvider);

    // Fade out animation
    await _logoController.reverse();
    await _textController.reverse();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            authState.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particlesController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E1B4B),
                    const Color(0xFF312E81),
                    const Color(0xFF1E3A8A),
                  ]
                : [
                    const Color(0xFFE0F2FE),
                    const Color(0xFFFAE8FF),
                    const Color(0xFFFEF3C7),
                  ],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlesPainter(
                    animation: _particlesController.value,
                    isDark: isDark,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 40,
                                              spreadRadius: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Custom Habit Hero Logo
                                Container(
                                  width: 120,
                                  height: 120,
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
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      width: 3,
                                    ),
                                  ),
                                  child: CustomPaint(
                                    size: const Size(120, 120),
                                    painter: HabitHeroLogoPainter(
                                      primaryColor: isDark
                                          ? Colors.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                      accentColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      animation: _logoController.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // App title with animation
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textOpacity,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'My Habits',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -1,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildAnimatedIcon(
                                      Icons.trending_up_rounded, 0),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Build Better Habits Together',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.8)
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildAnimatedIcon(Icons.people_rounded, 1),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // Loading dots animation
                  AnimatedBuilder(
                    animation: _particlesController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final delay = index * 0.2;
                          final animation =
                              ((_particlesController.value + delay) % 1.0);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (isDark ? Colors.white : Colors.black87)
                                  .withValues(alpha: 0.3 + (animation * 0.7)),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: animation * 0.5),
                                  blurRadius: 8,
                                  spreadRadius: animation * 2,
                                ),
                              ],
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    return AnimatedBuilder(
      animation: _particlesController,
      builder: (context, child) {
        final value = ((_particlesController.value + (index * 0.5)) % 1.0);
        final scale = 0.8 + (math.sin(value * math.pi * 2) * 0.2);
        return Transform.scale(
          scale: scale,
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ),
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

class ParticlesPainter extends CustomPainter {
  final double animation;
  final bool isDark;

  ParticlesPainter({required this.animation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (int i = 0; i < 20; i++) {
      final random = math.Random(i);
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      final floatOffset =
          math.sin((animation + random.nextDouble()) * math.pi * 2) * 30;
      final y = baseY + floatOffset;

      final particleSize = 2 + (random.nextDouble() * 4);
      final opacity = 0.2 + (random.nextDouble() * 0.3);

      paint.color = (isDark ? Colors.white : Colors.black87).withValues(
          alpha: opacity * (0.5 + (math.sin(animation * math.pi * 2) * 0.5)));

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
