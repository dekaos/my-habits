import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedPhoneMockup extends StatefulWidget {
  const AnimatedPhoneMockup({super.key});

  @override
  State<AnimatedPhoneMockup> createState() => _AnimatedPhoneMockupState();
}

class _AnimatedPhoneMockupState extends State<AnimatedPhoneMockup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: child,
          ),
        );
      },
      child: _buildPhoneMockup(),
    );
  }

  Widget _buildPhoneMockup() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final isMobile = size.width < 768;
        final phoneWidth =
            isMobile ? size.width * 0.7 : math.min(300.0, constraints.maxWidth);
        final phoneHeight = phoneWidth * 2.1;

        return Center(
          child: Container(
            width: phoneWidth,
            height: phoneHeight,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(phoneWidth * 0.12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 60,
                  offset: const Offset(0, 30),
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                  blurRadius: 80,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Screen content
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(phoneWidth * 0.1),
                    child: _buildScreenContent(phoneWidth),
                  ),
                ),
                // Notch
                Positioned(
                  top: 0,
                  left: phoneWidth * 0.25,
                  right: phoneWidth * 0.25,
                  child: Container(
                    height: phoneWidth * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(phoneWidth * 0.04),
                      ),
                    ),
                  ),
                ),
                // Reflection effect
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(phoneWidth * 0.1),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScreenContent(double phoneWidth) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: phoneWidth * 0.6,
              height: phoneWidth * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // App content preview
          Padding(
            padding: EdgeInsets.all(phoneWidth * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Habits',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: phoneWidth * 0.08,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: phoneWidth * 0.1,
                      height: phoneWidth * 0.1,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(phoneWidth * 0.03),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: phoneWidth * 0.06,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: phoneWidth * 0.08),

                // Habit cards
                _buildHabitCard(
                    phoneWidth, '💧', 'Drink Water', '7 day streak', 0.8),
                SizedBox(height: phoneWidth * 0.04),
                _buildHabitCard(
                    phoneWidth, '📚', 'Read Books', '3 day streak', 0.6),
                SizedBox(height: phoneWidth * 0.04),
                _buildHabitCard(
                    phoneWidth, '🏃', 'Exercise', '12 day streak', 1.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(
    double phoneWidth,
    String emoji,
    String title,
    String subtitle,
    double progress,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.all(phoneWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(phoneWidth * 0.04),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: phoneWidth * 0.12,
                height: phoneWidth * 0.12,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(phoneWidth * 0.03),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: phoneWidth * 0.06),
                  ),
                ),
              ),
              SizedBox(width: phoneWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: phoneWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: phoneWidth * 0.01),
                    Row(
                      children: [
                        Text(
                          '🔥',
                          style: TextStyle(fontSize: phoneWidth * 0.035),
                        ),
                        SizedBox(width: phoneWidth * 0.01),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: phoneWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: phoneWidth * 0.02),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(phoneWidth * 0.01),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6366F1),
                        ),
                        minHeight: phoneWidth * 0.01,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
