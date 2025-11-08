enum HabitFrequency {
  daily,
  weekly,
  custom,
}

class Habit {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? icon;
  final String color;
  final HabitFrequency frequency;
  final List<int> customDays; // For custom frequency (0-6, Mon-Sun)
  final int targetCount; // Number of times to complete (e.g., daily goal)
  final DateTime createdAt;
  final bool isPublic; // Share with friends
  final DateTime?
      scheduledTime; // Optional time when habit should be done (hour and minute only)
  final List<String> accountabilityPartners; // User IDs
  int currentStreak;
  int longestStreak;
  DateTime? lastCompletedDate;
  int totalCompletions;

  Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.color,
    required this.createdAt,
    this.description,
    this.icon,
    this.frequency = HabitFrequency.daily,
    this.customDays = const [],
    this.targetCount = 1,
    this.isPublic = false,
    this.scheduledTime,
    this.accountabilityPartners = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.totalCompletions = 0,
  });

  factory Habit.fromSupabaseMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      icon: map['icon'],
      color: map['color'] ?? '#6366F1',
      frequency: HabitFrequency.values[map['frequency'] ?? 0],
      customDays: List<int>.from(map['custom_days'] ?? []),
      targetCount: map['target_count'] ?? 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      isPublic: map['is_public'] ?? false,
      scheduledTime: map['scheduled_time'] != null
          ? DateTime.parse(map['scheduled_time'])
          : null,
      accountabilityPartners:
          List<String>.from(map['accountability_partners'] ?? []),
      currentStreak: map['current_streak'] ?? 0,
      longestStreak: map['longest_streak'] ?? 0,
      lastCompletedDate: map['last_completed_date'] != null
          ? DateTime.parse(map['last_completed_date'])
          : null,
      totalCompletions: map['total_completions'] ?? 0,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
      'frequency': frequency.index,
      'custom_days': customDays,
      'target_count': targetCount,
      'created_at': createdAt.toIso8601String(),
      'is_public': isPublic,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'accountability_partners': accountabilityPartners,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_completed_date': lastCompletedDate?.toIso8601String(),
      'total_completions': totalCompletions,
    };
  }

  Habit copyWith({
    String? title,
    String? description,
    String? icon,
    String? color,
    HabitFrequency? frequency,
    List<int>? customDays,
    int? targetCount,
    bool? isPublic,
    DateTime? scheduledTime,
    List<String>? accountabilityPartners,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    int? totalCompletions,
  }) {
    return Habit(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      targetCount: targetCount ?? this.targetCount,
      createdAt: createdAt,
      isPublic: isPublic ?? this.isPublic,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      accountabilityPartners:
          accountabilityPartners ?? this.accountabilityPartners,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      totalCompletions: totalCompletions ?? this.totalCompletions,
    );
  }
}
