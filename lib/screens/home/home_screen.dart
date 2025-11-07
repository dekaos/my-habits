import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/social_provider.dart';
import '../../widgets/animated_gradient_background.dart';
import 'habits_tab.dart';
import 'social_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData(String userId) async {
    if (_hasLoadedData) return;
    _hasLoadedData = true;

    debugPrint('🏠 HomeScreen - Loading data for user: $userId');
    try {
      await Future.wait([
        ref.read(habitProvider.notifier).loadHabits(userId),
        ref.read(socialProvider.notifier).loadFriends(userId),
        ref.read(socialProvider.notifier).loadActivityFeed(userId),
      ]);
      debugPrint('✅ HomeScreen - Data loaded successfully');
    } catch (e) {
      debugPrint('❌ HomeScreen - Error loading data: $e');
      _hasLoadedData = false; // Allow retry on error
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    // Load data when user becomes available
    ref.listen(authProvider, (previous, next) {
      if (next.user != null &&
          (previous?.user == null || previous?.user?.id != next.user?.id)) {
        _hasLoadedData = false;
        // Defer data loading to avoid modifying provider during build
        Future.microtask(() => _loadData(next.user!.id));
      }
    });

    // Load data on first build if user is already authenticated
    if (authState.user != null && !_hasLoadedData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData(authState.user!.id);
      });
    }

    final List<Widget> tabs = [
      const HabitsTab(),
      const SocialTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor:
          isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF8F9FE),
      body: AnimatedGradientBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: _buildGlassBottomNav(isDark),
    );
  }

  Widget _buildGlassBottomNav(bool isDark) {
    return RepaintBoundary(
      child: Container(
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
      child: RepaintBoundary(
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
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: color,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
