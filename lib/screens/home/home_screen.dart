import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/social_provider.dart';
import 'habits_tab.dart';
import 'social_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late AnimationController _particlesController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Particles animation for subtle background movement
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Glow effect animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Load data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particlesController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authState = ref.read(authProvider);

    if (authState.user != null) {
      await Future.wait([
        ref.read(habitProvider.notifier).loadHabits(authState.user!.id),
        ref.read(socialProvider.notifier).loadFriends(authState.user!.id),
        ref.read(socialProvider.notifier).loadActivityFeed(authState.user!.id),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> tabs = [
      const HabitsTab(),
      const SocialTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor:
          isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _particlesController,
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

          // Subtle particles background
          AnimatedBuilder(
            animation: _particlesController,
            builder: (context, child) {
              return CustomPaint(
                painter: HomeParticlesPainter(
                  animation: _particlesController.value,
                  isDark: isDark,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Content with fade-in animation
          IndexedStack(
            index: _currentIndex,
            children: tabs,
          ),
        ],
      ),
      bottomNavigationBar: _buildGlassBottomNav(isDark),
    );
  }

  Widget _buildGlassBottomNav(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.6)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.check_circle_outline,
                  selectedIcon: Icons.check_circle,
                  label: 'Habits',
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                  label: 'Social',
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Profile',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : (isDark ? Colors.grey[400] : Colors.grey[600]);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
            _animationController.forward(from: 0);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 12 : 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Particles painter for subtle animated background
class HomeParticlesPainter extends CustomPainter {
  final double animation;
  final bool isDark;

  HomeParticlesPainter({required this.animation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Generate fewer, more subtle particles than splash screen
    for (int i = 0; i < 15; i++) {
      final random = math.Random(i);
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Gentle floating animation
      final floatOffset =
          math.sin((animation + random.nextDouble()) * math.pi * 2) * 20;
      final y = baseY + floatOffset;

      final particleSize = 1.5 + (random.nextDouble() * 2.5);
      final opacity = 0.1 + (random.nextDouble() * 0.2);

      paint.color = (isDark ? Colors.white : Colors.black87).withOpacity(
          opacity * (0.4 + (math.sin(animation * math.pi * 2) * 0.3)));

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(HomeParticlesPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
