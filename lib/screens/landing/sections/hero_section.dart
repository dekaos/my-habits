import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/animated_phone_mockup.dart';
import '../widgets/floating_particles.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1200;

    return Container(
      height: math.max(size.height, 700),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
            Color(0xFFEC4899),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated particles background
          const FloatingParticles(),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : (isTablet ? 48 : 80),
                vertical: isMobile ? 40 : 80,
              ),
              child: isMobile
                  ? _buildMobileLayout(context)
                  : _buildDesktopLayout(context, isMobile, isTablet),
            ),
          ),

          // Scroll indicator
          if (!isMobile)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _buildScrollIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextContent(context, true),
            const SizedBox(height: 60),
            const AnimatedPhoneMockup(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, bool isMobile, bool isTablet) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Row(
          children: [
            Expanded(
              flex: isTablet ? 6 : 5,
              child: _buildTextContent(context, false),
            ),
            if (!isMobile) const SizedBox(width: 60),
            if (!isMobile)
              Expanded(
                flex: isTablet ? 4 : 5,
                child: const AnimatedPhoneMockup(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Build Better Habits',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 24 : 32),

        // Main headline
        Text(
          'Transform Your Life,\nOne Habit at a Time',
          style: TextStyle(
            fontSize: isMobile ? 40 : 64,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -1.5,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        SizedBox(height: isMobile ? 16 : 24),

        // Subtitle
        Text(
          'Join thousands building better habits with social accountability, '
          'beautiful progress tracking, and real-time motivation from friends.',
          style: TextStyle(
            fontSize: isMobile ? 16 : 20,
            color: Colors.white.withValues(alpha: 0.95),
            height: 1.5,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        SizedBox(height: isMobile ? 32 : 48),

        // CTA Buttons
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildCTAButton(
              context,
              'Get Started Free',
              Icons.arrow_forward_rounded,
              isPrimary: true,
            ),
            _buildCTAButton(
              context,
              'Watch Demo',
              Icons.play_circle_outline_rounded,
              isPrimary: false,
            ),
          ],
        ),

        SizedBox(height: isMobile ? 32 : 48),

        // Social proof
        _buildSocialProof(isMobile),
      ],
    );
  }

  Widget _buildCTAButton(
    BuildContext context,
    String text,
    IconData icon, {
    required bool isPrimary,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(icon, size: 20),
          label: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.2),
            foregroundColor: isPrimary ? const Color(0xFF6366F1) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isPrimary
                  ? BorderSide.none
                  : BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
            ),
            elevation: isPrimary ? 8 : 0,
            shadowColor: Colors.black.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialProof(bool isMobile) {
    return Row(
      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
      children: [
        // Star rating
        ...List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: isMobile ? 20 : 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '4.9',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '• 50k+ users',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Scroll to explore',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: 32,
              ),
            ],
          ),
        );
      },
    );
  }
}
