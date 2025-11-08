import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import '../../providers/messaging_provider.dart';
import '../social/enhanced_friends_screen.dart';
import '../social/search_users_screen.dart';
import '../social/friend_requests_screen.dart';
import '../../widgets/activity_card.dart';
import '../../widgets/glass_card.dart';

class SocialTab extends ConsumerStatefulWidget {
  const SocialTab({super.key});

  @override
  ConsumerState<SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends ConsumerState<SocialTab> {
  int _pendingRequestCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    _loadPendingRequests();

    await ref.read(socialProvider.notifier).loadFriends(authState.user!.id);
    await _loadUnreadMessages();

    await ref
        .read(socialProvider.notifier)
        .loadActivityFeed(authState.user!.id);

    ref.read(socialProvider.notifier).subscribeToActivities(authState.user!.id);

    ref
        .read(messagingProvider.notifier)
        .subscribeToMessages(authState.user!.id);
  }

  @override
  void dispose() {
    try {
      ref.read(socialProvider.notifier).unsubscribeFromActivities();
      ref.read(messagingProvider.notifier).unsubscribeFromMessages();
    } catch (e) {
      debugPrint('⚠️ Error unsubscribing: $e');
    }
    super.dispose();
  }

  Future<void> _loadPendingRequests() async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    try {
      final requestIds = await ref
          .read(socialProvider.notifier)
          .getFriendRequestIds(authState.user!.id);

      debugPrint('📬 Loaded ${requestIds.length} pending friend requests');

      if (mounted) {
        setState(() {
          _pendingRequestCount = requestIds.length;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading pending requests: $e');
    }
  }

  Future<void> _loadUnreadMessages() async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    final socialState = ref.read(socialProvider);
    final friendIds = socialState.friends.map((f) => f.id).toList();

    await ref.read(messagingProvider.notifier).loadUnreadCounts(
          authState.user!.id,
          friendIds,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final socialState = ref.watch(socialProvider);
    final messagingState = ref.watch(messagingProvider);
    final unreadMessageCount =
        messagingState.unreadCounts.values.fold(0, (sum, count) => sum + count);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: GlassAppBar(
          title: 'Social',
          actions: [
            // Friend requests with badge
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FriendRequestsScreen(),
                        ),
                      );
                      // Reload pending requests when returning
                      _loadPendingRequests();
                    },
                  ),
                  if (_pendingRequestCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            _pendingRequestCount > 9
                                ? '9+'
                                : '$_pendingRequestCount',
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
            // Messages with badge
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.message_outlined),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EnhancedFriendsScreen(),
                        ),
                      );
                      // Reload unread messages when returning
                      _loadUnreadMessages();
                    },
                  ),
                  if (unreadMessageCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            unreadMessageCount > 9
                                ? '9+'
                                : '$unreadMessageCount',
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
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchUsersScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EnhancedFriendsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authState.user != null) {
            await ref
                .read(socialProvider.notifier)
                .loadActivityFeed(authState.user!.id);
            // Also refresh pending requests count
            await _loadPendingRequests();
            // Also refresh unread messages count
            await _loadUnreadMessages();
          }
        },
        child: socialState.activityFeed.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: socialState.activityFeed.length,
                // Add keys for better performance
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                addSemanticIndexes: true,
                // Optimize cache extent for smoother scrolling
                cacheExtent: 500,
                itemBuilder: (context, index) {
                  final activity = socialState.activityFeed[index];
                  return RepaintBoundary(
                    key: ValueKey(activity.id),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ActivityCard(activity: activity),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          enableGlow: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              ),
              const SizedBox(height: 20),
              Text(
                'No Activity Yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect with friends to see their progress\nand stay motivated together!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GlassButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchUsersScreen(),
                    ),
                  );
                },
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_add, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Find Friends',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
