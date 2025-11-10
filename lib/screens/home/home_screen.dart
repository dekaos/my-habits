import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/social_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../widgets/animated_gradient_background.dart';
import '../notifications/notifications_screen.dart';
import 'habits_tab.dart';
import 'performance_tab.dart';
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
    try {
      ref.read(notificationProvider.notifier).unsubscribeFromNotifications();
      ref.read(messagingProvider.notifier).unsubscribeFromMessages();
    } catch (e) {
      debugPrint('Error unsubscribing: $e');
    }
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
        ref.read(notificationProvider.notifier).loadNotifications(userId),
      ]);

      final friendIds =
          ref.read(socialProvider).friends.map((f) => f.id).toList();

      if (friendIds.isNotEmpty) {
        await ref
            .read(messagingProvider.notifier)
            .loadUnreadCounts(userId, friendIds);
      }

      debugPrint('🏠 HomeScreen - Setting up realtime subscriptions...');
      ref.read(notificationProvider.notifier).subscribeToNotifications(userId);
      ref.read(messagingProvider.notifier).subscribeToMessages(userId);
      debugPrint('🏠 HomeScreen - Realtime subscriptions requested');

      debugPrint('✅ HomeScreen - Data loaded successfully');
    } catch (e) {
      debugPrint('❌ HomeScreen - Error loading data: $e');
      _hasLoadedData = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.user != null &&
          (previous?.user == null || previous?.user?.id != next.user?.id)) {
        _hasLoadedData = false;
        Future.microtask(() => _loadData(next.user!.id));
      }
    });

    if (authState.user != null && !_hasLoadedData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData(authState.user!.id);
      });
    }

    final List<Widget> tabs = [
      const HabitsTab(),
      const SocialTab(),
      const PerformanceTab(),
      const ProfileTab(),
    ];

    final notificationState = ref.watch(notificationProvider);

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
      floatingActionButton:
          _buildNotificationButton(context, notificationState, isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  Widget _buildNotificationButton(
    BuildContext context,
    NotificationState notificationState,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 48, right: 4),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: notificationState.unreadCount > 0
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: .3)
                  : Colors.black.withValues(alpha: .1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: .6)
                    : Colors.white.withValues(alpha: .8),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: .15)
                      : Colors.white.withValues(alpha: .5),
                  width: 1.5,
                ),
                shape: BoxShape.circle,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                      customBorder: const CircleBorder(),
                      child: Center(
                        child: Icon(
                          notificationState.unreadCount > 0
                              ? Icons.notifications
                              : Icons.notifications_outlined,
                          color: notificationState.unreadCount > 0
                              ? Theme.of(context).colorScheme.primary
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  if (notificationState.unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.black : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            notificationState.unreadCount > 9
                                ? '9+'
                                : '${notificationState.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                    ? Colors.black.withValues(alpha: .6)
                    : Colors.white.withValues(alpha: .7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: .15)
                      : Colors.white.withValues(alpha: .5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
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
                    icon: Icons.trending_up_rounded,
                    selectedIcon: Icons.trending_up_rounded,
                    label: 'Performance',
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    index: 3,
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
