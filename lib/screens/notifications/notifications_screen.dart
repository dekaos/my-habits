import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification.dart';
import '../../models/user_profile.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/glass_card.dart';
import '../social/chat_screen.dart';
import '../../widgets/animated_gradient_background.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String? _processingNotificationId;
  String? _processingAction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        ref
            .read(notificationProvider.notifier)
            .loadNotifications(authState.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notificationState = ref.watch(notificationProvider);
    final authState = ref.watch(authProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: GlassAppBar(
          title: l10n.notifications,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (notificationState.unreadCount > 0)
              TextButton.icon(
                onPressed: () {
                  if (authState.user != null) {
                    ref
                        .read(notificationProvider.notifier)
                        .markAllAsRead(authState.user!.id);
                  }
                },
                icon: const Icon(Icons.done_all, size: 18),
                label: Text(l10n.markAllRead),
              ),
          ],
        ),
        body: notificationState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : notificationState.notifications.isEmpty
                ? _buildEmptyState(context)
                : RefreshIndicator(
                    onRefresh: () async {
                      if (authState.user != null) {
                        await ref
                            .read(notificationProvider.notifier)
                            .loadNotifications(authState.user!.id);
                      }
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.only(
                        top: 16 +
                            kToolbarHeight +
                            MediaQuery.of(context).padding.top,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      itemCount: notificationState.notifications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notification =
                            notificationState.notifications[index];
                        return _buildNotificationCard(context, notification);
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, AppNotification notification) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref
            .read(notificationProvider.notifier)
            .deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notificationDeleted),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: notification.type == NotificationType.message
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      notification.getColor().withValues(alpha: 0.05),
                      notification.getColor().withValues(alpha: 0.02),
                    ],
                  ),
                )
              : null,
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            enableGlow: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: notification.getColor().withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        notification.getColor().withValues(alpha: 0.2),
                    backgroundImage: notification.fromUserPhotoUrl != null
                        ? NetworkImage(notification.fromUserPhotoUrl!)
                        : null,
                    child: notification.fromUserPhotoUrl == null
                        ? Icon(
                            notification.getIcon(),
                            color: notification.getColor(),
                            size: 24,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.getMessage(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                if (notification.type ==
                                        NotificationType.message &&
                                    notification.message != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: notification
                                          .getColor()
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: notification
                                            .getColor()
                                            .withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      notification.message!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: notification.getColor(),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            _getTimeAgo(notification.createdAt),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                          ),
                          if (notification.type ==
                              NotificationType.message) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: notification
                                    .getColor()
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 10,
                                    color: notification.getColor(),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.tapToReply,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: notification.getColor(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (notification.type ==
                          NotificationType.friendRequest) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _processingNotificationId ==
                                        notification.id
                                    ? null
                                    : () => _acceptFriendRequest(notification),
                                icon: _processingNotificationId ==
                                            notification.id &&
                                        _processingAction == 'accept'
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.check, size: 18),
                                label: Text(l10n.accept),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _processingNotificationId ==
                                        notification.id
                                    ? null
                                    : () => _rejectFriendRequest(notification),
                                icon: _processingNotificationId ==
                                            notification.id &&
                                        _processingAction == 'reject'
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.red,
                                        ),
                                      )
                                    : const Icon(Icons.close, size: 18),
                                label: Text(l10n.reject),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    await ref.read(notificationProvider.notifier).markAsRead(notification.id);

    if (!mounted) return;

    switch (notification.type) {
      case NotificationType.message:
        await _openChatFromNotification(notification);
        break;
      case NotificationType.friendRequest:
        break;
      case NotificationType.friendAccepted:
      case NotificationType.habitCompleted:
      case NotificationType.reactionAdded:
      case NotificationType.streakMilestone:
      case NotificationType.encouragement:
        break;
    }
  }

  Future<void> _openChatFromNotification(AppNotification notification) async {
    try {
      final friendProfile = UserProfile(
        id: notification.fromUserId,
        email: '',
        displayName: notification.fromUserName,
        photoUrl: notification.fromUserPhotoUrl,
        bio: null,
        joinedAt: DateTime.now(),
      );

      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(friend: friendProfile),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOpeningChat(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                Icons.notifications_none,
                size: 80,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.6),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.noNotificationsTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.youreAllCaughtUpMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptFriendRequest(AppNotification notification) async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _processingNotificationId = notification.id;
      _processingAction = 'accept';
    });

    try {
      await ref.read(socialProvider.notifier).acceptFriendRequest(
            authState.user!.id,
            notification.fromUserId,
          );

      await ref
          .read(notificationProvider.notifier)
          .deleteNotification(notification.id);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l10n.nowFriends(notification.fromUserName)),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorAcceptingRequest(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingNotificationId = null;
          _processingAction = null;
        });
      }
    }
  }

  Future<void> _rejectFriendRequest(AppNotification notification) async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _processingNotificationId = notification.id;
      _processingAction = 'reject';
    });

    try {
      await ref.read(socialProvider.notifier).rejectFriendRequest(
            authState.user!.id,
            notification.fromUserId,
          );

      await ref
          .read(notificationProvider.notifier)
          .deleteNotification(notification.id);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                      l10n.friendRequestDeclined(notification.fromUserName)),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorRejectingRequest(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingNotificationId = null;
          _processingAction = null;
        });
      }
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return l10n.weeksAgo((difference.inDays / 7).floor());
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
}
