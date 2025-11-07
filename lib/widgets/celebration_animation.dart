import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

/// Celebration overlay with confetti and success animation
class CelebrationAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const CelebrationAnimation({
    required this.onComplete,
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

  @override
  void initState() {
    super.initState();

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
        print('🎊 Confetti launched!');
      }
    });

    // Auto-dismiss after animation
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        print('✅ Celebration complete, dismissing...');
        widget.onComplete();
      }
    });
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
                colors: const [
                  Color(0xFF6366F1),
                  Color(0xFFEC4899),
                  Color(0xFFF59E0B),
                  Color(0xFF10B981),
                  Color(0xFF8B5CF6),
                ],
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
                colors: const [
                  Color(0xFF6366F1),
                  Color(0xFFEC4899),
                  Color(0xFFF59E0B),
                  Color(0xFF10B981),
                ],
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
                colors: const [
                  Color(0xFF6366F1),
                  Color(0xFFEC4899),
                  Color(0xFFF59E0B),
                  Color(0xFF10B981),
                ],
              ),
            ),

            // Success icon with scale animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF10B981),
                      Color(0xFF34D399),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),

            // "Great Job!" text
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.35,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      '🎉 Great Job! 🎉',
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
                      'Keep up the great work!',
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
}

/// Show celebration animation overlay
void showCelebration(BuildContext context) {
  print('🎯 showCelebration called');

  try {
    // Use Navigator overlay to ensure it's always accessible
    final overlay = Navigator.of(context).overlay;
    if (overlay == null) {
      print('❌ Warning: Could not access overlay for celebration animation');
      return;
    }

    print('✅ Overlay accessed, creating celebration');

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: CelebrationAnimation(
          onComplete: () {
            print('🧹 Removing celebration overlay');
            overlayEntry.remove();
          },
        ),
      ),
    );

    overlay.insert(overlayEntry);
    print('🎊 Celebration overlay inserted');
  } catch (e) {
    print('❌ Error showing celebration: $e');
  }
}
