import 'package:flutter/material.dart';

enum NotificationType {
  friendRequest,
  friendAccepted,
  habitCompleted,
  reactionAdded,
  streakMilestone,
  encouragement,
  message,
}

class AppNotification {
  final String id;
  final String userId; // Who receives this notification
  final String fromUserId; // Who triggered it
  final String fromUserName;
  final String? fromUserPhotoUrl;
  final NotificationType type;
  final String? habitId;
  final String? habitTitle;
  final String? activityId;
  final String? emoji; // For reaction notifications
  final String? message;
  final String? messageId; // For message notifications
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.fromUserId,
    required this.fromUserName,
    required this.type,
    required this.createdAt,
    this.fromUserPhotoUrl,
    this.habitId,
    this.habitTitle,
    this.activityId,
    this.emoji,
    this.message,
    this.messageId,
    this.isRead = false,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      fromUserId: map['from_user_id'] ?? '',
      fromUserName: map['from_user_name'] ?? '',
      fromUserPhotoUrl: map['from_user_photo_url'],
      type: NotificationType.values[map['type'] ?? 0],
      habitId: map['habit_id'],
      habitTitle: map['habit_title'],
      activityId: map['activity_id'],
      emoji: map['emoji'],
      message: map['message'],
      messageId: map['message_id'],
      isRead: map['is_read'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at']).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'from_user_id': fromUserId,
      'from_user_name': fromUserName,
      'from_user_photo_url': fromUserPhotoUrl,
      'type': type.index,
      'habit_id': habitId,
      'habit_title': habitTitle,
      'activity_id': activityId,
      'emoji': emoji,
      'message': message,
      'message_id': messageId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };

    if (id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }

  String getMessage() {
    switch (type) {
      case NotificationType.friendRequest:
        return '$fromUserName sent you a friend request';
      case NotificationType.friendAccepted:
        return '$fromUserName accepted your friend request';
      case NotificationType.habitCompleted:
        return '$fromUserName completed "${habitTitle ?? 'a habit'}"';
      case NotificationType.reactionAdded:
        return '$fromUserName reacted $emoji to your activity';
      case NotificationType.streakMilestone:
        return '$fromUserName reached a milestone on "${habitTitle ?? 'a habit'}"';
      case NotificationType.encouragement:
        return message ?? '$fromUserName sent you encouragement';
      case NotificationType.message:
        return message ?? '$fromUserName sent you a message';
    }
  }

  IconData getIcon() {
    switch (type) {
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.friendAccepted:
        return Icons.people;
      case NotificationType.habitCompleted:
        return Icons.check_circle;
      case NotificationType.reactionAdded:
        return Icons.favorite;
      case NotificationType.streakMilestone:
        return Icons.local_fire_department;
      case NotificationType.encouragement:
        return Icons.chat_bubble;
      case NotificationType.message:
        return Icons.message;
    }
  }

  Color getColor() {
    switch (type) {
      case NotificationType.friendRequest:
        return Colors.blue;
      case NotificationType.friendAccepted:
        return Colors.green;
      case NotificationType.habitCompleted:
        return Colors.teal;
      case NotificationType.reactionAdded:
        return Colors.pink;
      case NotificationType.streakMilestone:
        return Colors.orange;
      case NotificationType.encouragement:
        return Colors.purple;
      case NotificationType.message:
        return Colors.blue.shade200;
    }
  }

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      userId: userId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserPhotoUrl: fromUserPhotoUrl,
      type: type,
      habitId: habitId,
      habitTitle: habitTitle,
      activityId: activityId,
      emoji: emoji,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
