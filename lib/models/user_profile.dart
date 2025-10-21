class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final DateTime joinedAt;
  final List<String> friends;
  final List<String> friendRequests; // Pending friend requests
  final int totalStreaks;
  final int longestStreak;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.joinedAt, this.photoUrl,
    this.bio,
    this.friends = const [],
    this.friendRequests = const [],
    this.totalStreaks = 0,
    this.longestStreak = 0,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      email: map['email'] ?? '',
      displayName: map['display_name'] ?? '',
      photoUrl: map['photo_url'],
      bio: map['bio'],
      joinedAt: map['joined_at'] != null
          ? DateTime.parse(map['joined_at'])
          : DateTime.now(),
      friends: List<String>.from(map['friends'] ?? []),
      friendRequests: List<String>.from(map['friend_requests'] ?? []),
      totalStreaks: map['total_streaks'] ?? 0,
      longestStreak: map['longest_streak'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'bio': bio,
      'joined_at': joinedAt.toIso8601String(),
      'friends': friends,
      'friend_requests': friendRequests,
      'total_streaks': totalStreaks,
      'longest_streak': longestStreak,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    List<String>? friends,
    List<String>? friendRequests,
    int? totalStreaks,
    int? longestStreak,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      joinedAt: joinedAt,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      totalStreaks: totalStreaks ?? this.totalStreaks,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }
}
