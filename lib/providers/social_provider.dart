import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/activity.dart';

// Social State
class SocialState {
  final List<UserProfile> friends;
  final List<Activity> activityFeed;
  final List<UserProfile> friendRequests;
  final bool isLoading;

  SocialState({
    this.friends = const [],
    this.activityFeed = const [],
    this.friendRequests = const [],
    this.isLoading = false,
  });

  SocialState copyWith({
    List<UserProfile>? friends,
    List<Activity>? activityFeed,
    List<UserProfile>? friendRequests,
    bool? isLoading,
  }) {
    return SocialState(
      friends: friends ?? this.friends,
      activityFeed: activityFeed ?? this.activityFeed,
      friendRequests: friendRequests ?? this.friendRequests,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Social Notifier
class SocialNotifier extends Notifier<SocialState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  SocialState build() {
    return SocialState();
  }

  Future<void> loadFriends(String userId) async {
    try {
      state = state.copyWith(isLoading: true);

      final userResponse =
          await _supabase.from('users').select().eq('id', userId).single();

      final friendIds = List<String>.from(userResponse['friends'] ?? []);

      if (friendIds.isEmpty) {
        state = state.copyWith(friends: [], isLoading: false);
      } else {
        final friendsResponse =
            await _supabase.from('users').select().inFilter('id', friendIds);

        final friends = (friendsResponse as List)
            .map((data) => UserProfile.fromMap(data, data['id']))
            .toList();

        state = state.copyWith(friends: friends, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Error loading friends: $e');
    }
  }

  Future<void> loadActivityFeed(String userId) async {
    try {
      debugPrint('🎯 Loading activity feed for user: $userId');

      final userResponse =
          await _supabase.from('users').select().eq('id', userId).single();

      final friendIds = List<String>.from(userResponse['friends'] ?? []);
      friendIds.add(userId); // Include own activities

      debugPrint(
          '🎯 Querying activities from users: $friendIds (${friendIds.length} users)');

      final response = await _supabase
          .from('activities')
          .select()
          .inFilter('user_id', friendIds)
          .order('created_at', ascending: false)
          .limit(50);

      debugPrint(
          '🎯 Activities query returned: ${(response as List).length} activities');

      final activityFeed = (response as List)
          .map((data) => Activity.fromSupabaseMap(data))
          .toList();

      debugPrint(
          '🎯 Activity feed loaded with ${activityFeed.length} activities:');
      for (var activity in activityFeed.take(5)) {
        debugPrint(
            '  - ${activity.userName}: ${activity.type.name} (${activity.habitTitle ?? "no habit"})');
      }

      state = state.copyWith(activityFeed: activityFeed);
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading activity feed: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> sendFriendRequest(
      String currentUserId, String targetUserId) async {
    try {
      debugPrint(
          '📤 Sending friend request from $currentUserId to $targetUserId');

      // Get target user's current friend requests
      final targetUser = await _supabase
          .from('users')
          .select('friend_requests, friends')
          .eq('id', targetUserId)
          .single();

      debugPrint('📥 Target user data: $targetUser');

      // Check if already friends
      final friends = List<String>.from(targetUser['friends'] ?? []);
      if (friends.contains(currentUserId)) {
        debugPrint('⚠️ Already friends!');
        throw Exception('Already friends with this user');
      }

      // Check if request already sent
      final requests = List<String>.from(targetUser['friend_requests'] ?? []);
      if (requests.contains(currentUserId)) {
        debugPrint('⚠️ Friend request already sent!');
        throw Exception('Friend request already sent');
      }

      // Add current user to target's friend requests
      requests.add(currentUserId);
      debugPrint('✍️ Updating friend_requests to: $requests');

      final response = await _supabase
          .from('users')
          .update({'friend_requests': requests})
          .eq('id', targetUserId)
          .select();

      debugPrint('✅ Friend request sent successfully: $response');
    } catch (e, stackTrace) {
      debugPrint('❌ Error sending friend request: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow; // Re-throw to show error to user
    }
  }

  Future<void> acceptFriendRequest(
      String currentUserId, String requesterId) async {
    try {
      // Get current user data
      final currentUserData = await _supabase
          .from('users')
          .select()
          .eq('id', currentUserId)
          .single();

      final friends = List<String>.from(currentUserData['friends'] ?? []);
      final requests =
          List<String>.from(currentUserData['friend_requests'] ?? []);

      friends.add(requesterId);
      requests.remove(requesterId);

      // Update current user
      await _supabase.from('users').update({
        'friends': friends,
        'friend_requests': requests,
      }).eq('id', currentUserId);

      // Add current user to requester's friends
      final requesterData = await _supabase
          .from('users')
          .select('friends')
          .eq('id', requesterId)
          .single();

      final requesterFriends =
          List<String>.from(requesterData['friends'] ?? []);
      requesterFriends.add(currentUserId);

      await _supabase
          .from('users')
          .update({'friends': requesterFriends}).eq('id', requesterId);

      await loadFriends(currentUserId);
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
    }
  }

  Future<void> rejectFriendRequest(
      String currentUserId, String requesterId) async {
    try {
      final userData = await _supabase
          .from('users')
          .select('friend_requests')
          .eq('id', currentUserId)
          .single();

      final requests = List<String>.from(userData['friend_requests'] ?? []);
      requests.remove(requesterId);

      await _supabase
          .from('users')
          .update({'friend_requests': requests}).eq('id', currentUserId);
    } catch (e) {
      debugPrint('Error rejecting friend request: $e');
    }
  }

  Future<void> removeFriend(String currentUserId, String friendId) async {
    try {
      // Remove from current user
      final currentUserData = await _supabase
          .from('users')
          .select('friends')
          .eq('id', currentUserId)
          .single();

      final currentFriends =
          List<String>.from(currentUserData['friends'] ?? []);
      currentFriends.remove(friendId);

      await _supabase
          .from('users')
          .update({'friends': currentFriends}).eq('id', currentUserId);

      // Remove from friend
      final friendData = await _supabase
          .from('users')
          .select('friends')
          .eq('id', friendId)
          .single();

      final friendFriends = List<String>.from(friendData['friends'] ?? []);
      friendFriends.remove(currentUserId);

      await _supabase
          .from('users')
          .update({'friends': friendFriends}).eq('id', friendId);

      await loadFriends(currentUserId);
    } catch (e) {
      debugPrint('Error removing friend: $e');
    }
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      debugPrint('🔍 Searching users with query: $query');

      // Search by both display_name AND email
      final response = await _supabase
          .from('users')
          .select(
              'id, display_name, email, photo_url, bio, total_streaks, created_at')
          .or('display_name.ilike.%$query%,email.ilike.%$query%')
          .limit(20);

      debugPrint('✅ Search response: ${response.length} users found');

      return (response as List)
          .map((data) => UserProfile.fromMap(data, data['id']))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error searching users: $e');
      debugPrint('Stack trace: $stackTrace');

      // Return empty list but don't fail silently
      return [];
    }
  }

  /// Get friend request IDs for a user
  Future<List<String>> getFriendRequestIds(String userId) async {
    try {
      debugPrint('📬 Fetching friend requests for user: $userId');

      final response = await _supabase
          .from('users')
          .select('friend_requests')
          .eq('id', userId)
          .single();

      debugPrint('📬 Raw response: $response');

      final requestIds = List<String>.from(response['friend_requests'] ?? []);
      debugPrint(
          '📬 Friend request IDs: $requestIds (count: ${requestIds.length})');

      return requestIds;
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting friend requests: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Get user profiles by IDs
  Future<List<UserProfile>> getUserProfiles(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      final response = await _supabase
          .from('users')
          .select(
              'id, display_name, email, photo_url, bio, total_streaks, created_at')
          .inFilter('id', userIds);

      return (response as List)
          .map((data) => UserProfile.fromMap(data, data['id']))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting user profiles: $e');
      return [];
    }
  }

  Future<void> addReactionToActivity(
      String activityId, String userId, String emoji) async {
    try {
      final activityData = await _supabase
          .from('activities')
          .select('reactions')
          .eq('id', activityId)
          .single();

      final reactions =
          Map<String, dynamic>.from(activityData['reactions'] ?? {});
      reactions[userId] = emoji;

      await _supabase
          .from('activities')
          .update({'reactions': reactions}).eq('id', activityId);

      // Update local state
      final updatedActivities = state.activityFeed.map((activity) {
        if (activity.id == activityId) {
          return Activity.fromSupabaseMap({
            'id': activity.id,
            'user_id': activity.userId,
            'user_name': activity.userName,
            'user_photo_url': activity.userPhotoUrl,
            'type': activity.type.index,
            'habit_id': activity.habitId,
            'habit_title': activity.habitTitle,
            'message': activity.message,
            'streak_count': activity.streakCount,
            'created_at': activity.createdAt.toIso8601String(),
            'reactions': reactions,
          });
        }
        return activity;
      }).toList();

      state = state.copyWith(activityFeed: updatedActivities);
    } catch (e) {
      debugPrint('Error adding reaction: $e');
    }
  }

  Future<void> postActivity(Activity activity) async {
    try {
      debugPrint(
          '📢 Posting activity: ${activity.type.name} by ${activity.userName}');
      debugPrint('📢 Activity data: ${activity.toSupabaseMap()}');

      final response = await _supabase
          .from('activities')
          .insert(activity.toSupabaseMap())
          .select();

      debugPrint('✅ Activity posted successfully: $response');
    } catch (e, stackTrace) {
      debugPrint('❌ Error posting activity: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

// Provider
final socialProvider =
    NotifierProvider<SocialNotifier, SocialState>(SocialNotifier.new);
