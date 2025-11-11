import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

/// Animation theme based on habit icon
class CelebrationTheme {
  final List<Color> colors;
  final String emoji;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> particles;

  const CelebrationTheme({
    required this.colors,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.particles,
  });
}

/// Celebration overlay with confetti and success animation
class CelebrationAnimation extends StatefulWidget {
  final VoidCallback onComplete;
  final String? habitIcon;

  const CelebrationAnimation({
    required this.onComplete,
    this.habitIcon,
    super.key,
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late CelebrationTheme _theme;

  @override
  void initState() {
    super.initState();

    _theme = _getThemeForIcon(widget.habitIcon);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Start animations immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confettiController.play();
        _scaleController.forward();
        debugPrint('🎊 ${_theme.emoji} celebration launched!');
      }
    });

    // Auto-dismiss after animation
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        debugPrint('✅ Celebration complete, fading out...');
        _scaleController.reverse().then((_) {
          if (mounted) {
            widget.onComplete();
          }
        });
      }
    });
  }

  CelebrationTheme _getThemeForIcon(String? iconName) {
    switch (iconName) {
      case 'fitness':
        return const CelebrationTheme(
          colors: [Color(0xFFEF4444), Color(0xFFF97316), Color(0xFFFBBF24)],
          emoji: '💪',
          title: 'Beast Mode! 💪',
          subtitle: 'One step closer to your fitness goal!',
          icon: Icons.fitness_center,
          particles: ['💪', '🔥', '⚡', '🏋️'],
        );
      case 'book':
        return const CelebrationTheme(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
          emoji: '📚',
          title: 'Bookworm! 📚',
          subtitle: 'Knowledge is power!',
          icon: Icons.book,
          particles: ['📚', '📖', '✨', '💡'],
        );
      case 'water':
        return const CelebrationTheme(
          colors: [Color(0xFF06B6D4), Color(0xFF0EA5E9), Color(0xFF3B82F6)],
          emoji: '💧',
          title: 'Hydrated! 💧',
          subtitle: 'Stay refreshed and healthy!',
          icon: Icons.water_drop,
          particles: ['💧', '💦', '🌊', '✨'],
        );
      case 'sleep':
        return const CelebrationTheme(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFF4F46E5)],
          emoji: '😴',
          title: 'Sweet Dreams! 😴',
          subtitle: 'Rest well, you earned it!',
          icon: Icons.bedtime,
          particles: ['😴', '💤', '⭐', '🌙'],
        );
      case 'restaurant':
        return const CelebrationTheme(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFFFDE68A)],
          emoji: '🍽️',
          title: 'Delicious! 🍽️',
          subtitle: 'Healthy eating habits!',
          icon: Icons.restaurant,
          particles: ['🍽️', '🥗', '🍎', '✨'],
        );
      case 'run':
        return const CelebrationTheme(
          colors: [Color(0xFF10B981), Color(0xFF34D399), Color(0xFF6EE7B7)],
          emoji: '🏃',
          title: 'On the Move! 🏃',
          subtitle: 'Keep running towards your goals!',
          icon: Icons.directions_run,
          particles: ['🏃', '💨', '⚡', '🔥'],
        );
      case 'meditation':
        return const CelebrationTheme(
          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA), Color(0xFFC4B5FD)],
          emoji: '🧘',
          title: 'Inner Peace! 🧘',
          subtitle: 'Mindfulness achieved!',
          icon: Icons.spa,
          particles: ['🧘', '☮️', '✨', '🕉️'],
        );
      case 'yoga':
        return const CelebrationTheme(
          colors: [Color(0xFFEC4899), Color(0xFFF472B6), Color(0xFFFBBCDA)],
          emoji: '🧘‍♀️',
          title: 'Namaste! 🧘‍♀️',
          subtitle: 'Balance and flexibility!',
          icon: Icons.self_improvement,
          particles: ['🧘‍♀️', '🌸', '✨', '💫'],
        );
      case 'art':
        return const CelebrationTheme(
          colors: [Color(0xFFEC4899), Color(0xFFF59E0B), Color(0xFF8B5CF6)],
          emoji: '🎨',
          title: 'Creative! 🎨',
          subtitle: 'Express yourself!',
          icon: Icons.palette,
          particles: ['🎨', '🖌️', '✨', '🌈'],
        );
      case 'music':
        return const CelebrationTheme(
          colors: [Color(0xFF6366F1), Color(0xFFEC4899), Color(0xFF8B5CF6)],
          emoji: '🎵',
          title: 'Harmony! 🎵',
          subtitle: 'Keep the rhythm going!',
          icon: Icons.music_note,
          particles: ['🎵', '🎶', '🎸', '✨'],
        );
      case 'work':
        return const CelebrationTheme(
          colors: [Color(0xFF6366F1), Color(0xFF3B82F6), Color(0xFF60A5FA)],
          emoji: '💼',
          title: 'Productive! 💼',
          subtitle: 'Crushing those tasks!',
          icon: Icons.work,
          particles: ['💼', '✅', '⚡', '🎯'],
        );
      case 'school':
        return const CelebrationTheme(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFF10B981)],
          emoji: '🎓',
          title: 'Smart! 🎓',
          subtitle: 'Learning never stops!',
          icon: Icons.school,
          particles: ['🎓', '📝', '💡', '✨'],
        );
      case 'heart':
        return const CelebrationTheme(
          colors: [Color(0xFFEF4444), Color(0xFFF87171), Color(0xFFFCA5A5)],
          emoji: '❤️',
          title: 'Healthy! ❤️',
          subtitle: 'Taking care of yourself!',
          icon: Icons.favorite,
          particles: ['❤️', '💖', '✨', '🌟'],
        );
      case 'walk':
        return const CelebrationTheme(
          colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF34D399)],
          emoji: '🚶',
          title: 'Step by Step! 🚶',
          subtitle: 'Every step counts!',
          icon: Icons.directions_walk,
          particles: ['🚶', '👣', '🌿', '✨'],
        );
      case 'bike':
        return const CelebrationTheme(
          colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4), Color(0xFF22D3EE)],
          emoji: '🚴',
          title: 'Pedal Power! 🚴',
          subtitle: 'Rolling towards success!',
          icon: Icons.directions_bike,
          particles: ['🚴', '💨', '⚡', '🌟'],
        );
      default:
        return const CelebrationTheme(
          colors: [
            Color(0xFF6366F1),
            Color(0xFFEC4899),
            Color(0xFFF59E0B),
            Color(0xFF10B981),
            Color(0xFF8B5CF6),
          ],
          emoji: '🎉',
          title: '🎉 Great Job! 🎉',
          subtitle: 'Keep up the great work!',
          icon: Icons.celebration,
          particles: ['🎉', '✨', '🌟', '⭐'],
        );
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Confetti from top
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2, // Down
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 15,
                gravity: 0.3,
                colors: _theme.colors,
                createParticlePath: (size) => _drawStar(size),
              ),
            ),

            // Confetti from bottom left
            Align(
              alignment: Alignment.bottomLeft,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -pi / 4, // Up-right
                maxBlastForce: 8,
                minBlastForce: 4,
                emissionFrequency: 0.05,
                numberOfParticles: 10,
                gravity: 0.2,
                colors: _theme.colors,
              ),
            ),

            // Confetti from bottom right
            Align(
              alignment: Alignment.bottomRight,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -3 * pi / 4, // Up-left
                maxBlastForce: 8,
                minBlastForce: 4,
                emissionFrequency: 0.05,
                numberOfParticles: 10,
                gravity: 0.2,
                colors: _theme.colors,
              ),
            ),

            // Floating emoji particles
            ...List.generate(8, (index) => _buildFloatingEmoji(index)),

            // Success icon with scale animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _theme.colors.first,
                          _theme.colors.last,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _theme.colors.first.withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      _theme.icon,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.35,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      _theme.title,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _theme.subtitle,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withValues(alpha: 0.9),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Path _drawStar(Size size) {
    final path = Path();
    final double width = size.width;
    final double height = size.height;

    path.moveTo(width * 0.5, 0);
    path.lineTo(width * 0.61, height * 0.35);
    path.lineTo(width, height * 0.35);
    path.lineTo(width * 0.68, height * 0.57);
    path.lineTo(width * 0.79, height * 0.91);
    path.lineTo(width * 0.5, height * 0.7);
    path.lineTo(width * 0.21, height * 0.91);
    path.lineTo(width * 0.32, height * 0.57);
    path.lineTo(0, height * 0.35);
    path.lineTo(width * 0.39, height * 0.35);
    path.close();

    return path;
  }

  Widget _buildFloatingEmoji(int index) {
    final random = Random(index);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final left = random.nextDouble() * screenWidth;
    final top = random.nextDouble() * screenHeight * 0.6 + screenHeight * 0.2;
    final delay = random.nextInt(1000);
    final duration = 2000 + random.nextInt(1000);

    final particle = _theme.particles[random.nextInt(_theme.particles.length)];

    return Positioned(
      left: left,
      top: top,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: duration),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(
              sin(value * 2 * pi) * 20,
              -value * 100 - 50,
            ),
            child: Opacity(
              opacity: 1.0 - value,
              child: Transform.scale(
                scale: 0.8 + value * 0.4,
                child: child,
              ),
            ),
          );
        },
        child: FutureBuilder(
          future: Future.delayed(Duration(milliseconds: delay)),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox.shrink();
            }
            return Text(
              particle,
              style: const TextStyle(fontSize: 28),
            );
          },
        ),
      ),
    );
  }
}

void showCelebration(BuildContext context, {String? habitIcon}) {
  debugPrint('🎯 showCelebration called with icon: ${habitIcon ?? "default"}');

  try {
    final overlay = Navigator.of(context).overlay;
    if (overlay == null) {
      debugPrint(
          '❌ Warning: Could not access overlay for celebration animation');
      return;
    }

    debugPrint('✅ Overlay accessed, creating themed celebration');

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: CelebrationAnimation(
          habitIcon: habitIcon,
          onComplete: () {
            debugPrint('🧹 Removing celebration overlay');
            overlayEntry.remove();
          },
        ),
      ),
    );

    overlay.insert(overlayEntry);
    debugPrint('🎊 Themed celebration overlay inserted');
  } catch (e) {
    debugPrint('❌ Error showing celebration: $e');
  }
}
