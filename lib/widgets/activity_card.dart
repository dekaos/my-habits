import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity.dart';
import '../providers/auth_provider.dart';
import '../providers/social_provider.dart';
import '../l10n/app_localizations.dart';
import 'glass_card.dart';
import '../../widgets/animated_gradient_background.dart';

class ActivityCard extends ConsumerWidget {
  final Activity activity;

  const ActivityCard({required this.activity, super.key});

  String _getTimeAgo(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays > 0) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.minutesAgo(difference.inMinutes);
    } else {
      return l10n.justNow;
    }
  }

  IconData _getActivityIcon() {
    switch (activity.type) {
      case ActivityType.habitCompleted:
        return Icons.check_circle;
      case ActivityType.streakMilestone:
        return Icons.local_fire_department;
      case ActivityType.newHabit:
        return Icons.add_circle;
      case ActivityType.encouragement:
        return Icons.favorite;
    }
  }

  Color _getActivityColor(BuildContext context) {
    switch (activity.type) {
      case ActivityType.habitCompleted:
        return Colors.green;
      case ActivityType.streakMilestone:
        return Colors.orange;
      case ActivityType.newHabit:
        return Theme.of(context).colorScheme.primary;
      case ActivityType.encouragement:
        return Colors.pink;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: GlassCard(
        padding: const EdgeInsets.all(16.0),
        enableGlow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            _getActivityColor(context).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: activity.userPhotoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              activity.userPhotoUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  activity.userName.isNotEmpty
                                      ? activity.userName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            activity.userName.isNotEmpty
                                ? activity.userName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Activity content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.getActivityMessage(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTimeAgo(context, activity.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getActivityColor(context).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getActivityIcon(),
                    color: _getActivityColor(context),
                    size: 22,
                  ),
                ),
              ],
            ),

            // Reactions grouped by emoji
            if (activity.reactions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildReactionBubbles(context, ref, isDark),
              ),
            ],

            // Add reaction button
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _showReactionPicker(context, ref);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.react,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
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

  List<Widget> _buildReactionBubbles(
      BuildContext context, WidgetRef ref, bool isDark) {
    final Map<String, List<String>> groupedReactions = {};

    activity.reactions.forEach((userId, emoji) {
      if (!groupedReactions.containsKey(emoji)) {
        groupedReactions[emoji] = [];
      }
      groupedReactions[emoji]!.add(userId);
    });

    final authState = ref.read(authProvider);
    final currentUserId = authState.user?.id;

    return groupedReactions.entries.map((entry) {
      final emoji = entry.key;
      final userIds = entry.value;
      final count = userIds.length;
      final hasReacted =
          currentUserId != null && userIds.contains(currentUserId);

      return GestureDetector(
        onTap: () => _showReactionDetails(context, ref, emoji, userIds),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: hasReacted
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasReacted
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.transparent),
              width: hasReacted ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasReacted
                      ? Theme.of(context).colorScheme.primary
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Future<void> _showReactionDetails(
    BuildContext context,
    WidgetRef ref,
    String emoji,
    List<String> userIds,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.35,
          minChildSize: 0.25,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: AnimatedGradientBackground(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.reactionCount(userIds.length),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchUserProfiles(userIds),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                l10n.couldNotLoadUsers,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            );
                          }

                          final users = snapshot.data!;

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: users.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final displayName =
                                  user['display_name'] ?? 'User';
                              final photoUrl = user['photo_url'];

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  backgroundImage: photoUrl != null
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: photoUrl == null
                                      ? Text(
                                          displayName[0].toUpperCase(),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUserProfiles(
      List<String> userIds) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('users')
          .select('id, display_name, photo_url')
          .inFilter('id', userIds);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error fetching user profiles: $e');
      return [];
    }
  }

  void _showReactionPicker(
    BuildContext context,
    WidgetRef ref,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final reactions = ['👍', '❤️', '🔥', '🎉', '💪', '👏'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.read(authProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.6,
          expand: false,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: AnimatedGradientBackground(
                  child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.chooseReaction,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: reactions.map((emoji) {
                        return GestureDetector(
                          onTap: () async {
                            if (authState.user != null) {
                              await ref
                                  .read(socialProvider.notifier)
                                  .addReactionToActivity(
                                    activity.id,
                                    authState.user!.id,
                                    emoji,
                                  );
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              )),
            );
          },
        );
      },
    );
  }
}
