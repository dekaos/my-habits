enum ActivityType {
  habitCompleted,
  streakMilestone,
  newHabit,
  encouragement,
}

class Activity {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final ActivityType type;
  final String? habitId;
  final String? habitTitle;
  final String? message;
  final int? streakCount;
  final DateTime createdAt;
  final Map<String, String> reactions; // userId: emoji

  Activity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.createdAt,
    this.userPhotoUrl,
    this.habitId,
    this.habitTitle,
    this.message,
    this.streakCount,
    this.reactions = const {},
  });

  factory Activity.fromSupabaseMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      userName: map['user_name'] ?? '',
      userPhotoUrl: map['user_photo_url'],
      type: ActivityType.values[map['type'] ?? 0],
      habitId: map['habit_id'],
      habitTitle: map['habit_title'],
      message: map['message'],
      streakCount: map['streak_count'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      reactions: Map<String, String>.from(map['reactions'] ?? {}),
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'type': type.index,
      'habit_id': habitId,
      'habit_title': habitTitle,
      'message': message,
      'streak_count': streakCount,
      'created_at': createdAt.toIso8601String(),
      'reactions': reactions,
    };
  }

  String getActivityMessage() {
    switch (type) {
      case ActivityType.habitCompleted:
        return '$userName completed "${habitTitle ?? 'a habit'}"';
      case ActivityType.streakMilestone:
        return '$userName reached a ${streakCount ?? 0} day streak on "${habitTitle ?? 'a habit'}"! 🔥';
      case ActivityType.newHabit:
        return '$userName started a new habit: "${habitTitle ?? 'Untitled'}"';
      case ActivityType.encouragement:
        return message ?? '$userName sent encouragement';
    }
  }
}
