class HabitCompletion {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedAt;
  final String? note;
  final String? imageUrl;
  final int count; // For habits with multiple completions per day

  HabitCompletion({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    this.note,
    this.imageUrl,
    this.count = 1,
  });

  factory HabitCompletion.fromSupabaseMap(Map<String, dynamic> map) {
    return HabitCompletion(
      id: map['id'] ?? '',
      habitId: map['habit_id'] ?? '',
      userId: map['user_id'] ?? '',
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : DateTime.now(),
      note: map['note'],
      imageUrl: map['image_url'],
      count: map['count'] ?? 1,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'habit_id': habitId,
      'user_id': userId,
      'completed_at': completedAt.toIso8601String(),
      'note': note,
      'image_url': imageUrl,
      'count': count,
    };
  }
}
