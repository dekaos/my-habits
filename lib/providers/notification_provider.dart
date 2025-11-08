import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart';

// Notification State
class NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Notification Notifier
class NotificationNotifier extends Notifier<NotificationState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _notificationChannel;

  @override
  NotificationState build() {
    return NotificationState();
  }

  /// Load notifications for a user
  Future<void> loadNotifications(String userId) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      final notifications = (response as List)
          .map((data) => AppNotification.fromMap(data))
          .toList();

      final unreadCount = notifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );

      developer.log(
        'Loaded ${notifications.length} notifications, $unreadCount unread',
        name: 'NotificationProvider',
      );
    } catch (e) {
      developer.log('Error loading notifications: $e',
          name: 'NotificationProvider');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Subscribe to real-time notification updates
  void subscribeToNotifications(String userId) {
    try {
      unsubscribeFromNotifications();

      developer.log('🔔 Subscribing to real-time notifications',
          name: 'NotificationProvider');

      _notificationChannel = _supabase
          .channel('notifications_realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              developer.log('🔔 New notification received',
                  name: 'NotificationProvider');
              _handleNewNotification(payload.newRecord);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _handleUpdatedNotification(payload.newRecord);
            },
          )
          .subscribe();

      developer.log('✅ Subscribed to notifications',
          name: 'NotificationProvider');
    } catch (e) {
      developer.log('❌ Error subscribing to notifications: $e',
          name: 'NotificationProvider');
    }
  }

  /// Unsubscribe from real-time notifications
  void unsubscribeFromNotifications() {
    if (_notificationChannel != null) {
      _supabase.removeChannel(_notificationChannel!);
      _notificationChannel = null;
      developer.log('🔔 Unsubscribed from notifications',
          name: 'NotificationProvider');
    }
  }

  /// Handle new notification
  void _handleNewNotification(Map<String, dynamic> data) {
    try {
      final newNotification = AppNotification.fromMap(data);

      developer.log(
        '🔔 Processing notification: ID=${newNotification.id}',
        name: 'NotificationProvider',
      );

      // Check if already exists (prevent duplicates)
      final exists = state.notifications.any((n) => n.id == newNotification.id);

      if (exists) {
        developer.log(
          '⚠️ Notification already exists, skipping duplicate!',
          name: 'NotificationProvider',
        );
        return;
      }

      // Add to beginning
      final updatedNotifications = [newNotification, ...state.notifications];
      final limitedNotifications = updatedNotifications.take(50).toList();
      final unreadCount = limitedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: limitedNotifications,
        unreadCount: unreadCount,
      );

      developer.log(
        '✅ New notification: ${newNotification.getMessage()}',
        name: 'NotificationProvider',
      );
      developer.log(
        '   - Total: ${limitedNotifications.length}, Unread: $unreadCount',
        name: 'NotificationProvider',
      );
    } catch (e) {
      developer.log('Error handling new notification: $e',
          name: 'NotificationProvider');
    }
  }

  /// Handle notification update (mark as read)
  void _handleUpdatedNotification(Map<String, dynamic> data) {
    try {
      final updatedNotification = AppNotification.fromMap(data);

      final updatedNotifications = state.notifications.map((n) {
        return n.id == updatedNotification.id ? updatedNotification : n;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      developer.log('Error handling updated notification: $e',
          name: 'NotificationProvider');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);

      final updatedNotifications = state.notifications.map((n) {
        return n.id == notificationId ? n.copyWith(isRead: true) : n;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      developer.log('Error marking notification as read: $e',
          name: 'NotificationProvider');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      final updatedNotifications = state.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      developer.log('Error marking all as read: $e',
          name: 'NotificationProvider');
    }
  }

  /// Create a notification for a user
  Future<void> createNotification(AppNotification notification) async {
    try {
      await _supabase.from('notifications').insert(notification.toMap());
      developer.log('✅ Created notification', name: 'NotificationProvider');
    } catch (e) {
      developer.log('Error creating notification: $e',
          name: 'NotificationProvider');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);

      final updatedNotifications =
          state.notifications.where((n) => n.id != notificationId).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      developer.log('Error deleting notification: $e',
          name: 'NotificationProvider');
    }
  }

  /// Mark all message notifications from a specific user as read
  Future<void> markMessageNotificationsAsRead(
      String currentUserId, String fromUserId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', currentUserId)
          .eq('from_user_id', fromUserId)
          .eq('type', 6) // NotificationType.message
          .eq('is_read', false);

      // Update local state
      final updatedNotifications = state.notifications.map((n) {
        if (n.type == NotificationType.message &&
            n.fromUserId == fromUserId &&
            !n.isRead) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );

      developer.log('✅ Marked message notifications as read from: $fromUserId',
          name: 'NotificationProvider');
    } catch (e) {
      developer.log('Error marking message notifications as read: $e',
          name: 'NotificationProvider');
    }
  }
}

// Provider
final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
        NotificationNotifier.new);
