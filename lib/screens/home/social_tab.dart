import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../l10n/app_localizations.dart';
import '../social/enhanced_friends_screen.dart';
import '../social/search_users_screen.dart';
import '../../widgets/activity_card.dart';
import '../../widgets/glass_card.dart';

class SocialTab extends ConsumerStatefulWidget {
  const SocialTab({super.key});

  @override
  ConsumerState<SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends ConsumerState<SocialTab> {
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

    await ref.read(socialProvider.notifier).loadFriends(authState.user!.id);

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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final socialState = ref.watch(socialProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: GlassAppBar(
          title: l10n.social,
          actions: [
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
          }
        },
        child: socialState.activityFeed.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: socialState.activityFeed.length,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                addSemanticIndexes: true,
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
    final l10n = AppLocalizations.of(context)!;

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
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.6),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.noActivityYet,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.connectWithFriends,
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
                      l10n.findFriends,
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
