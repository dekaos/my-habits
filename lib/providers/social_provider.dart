import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/activity.dart';
import '../models/notification.dart';

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
  RealtimeChannel? _activitiesChannel;

  @override
  SocialState build() {
    return SocialState();
  }

  /// Subscribe to real-time activity updates
  void subscribeToActivities(String userId) {
    try {
      // Unsubscribe from previous channel if exists
      unsubscribeFromActivities();

      debugPrint('🔴 Subscribing to real-time activities for user: $userId');

      _activitiesChannel = _supabase
          .channel('activities_realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'activities',
            callback: (payload) {
              debugPrint('🔴 New activity received: ${payload.newRecord}');
              _handleNewActivity(payload.newRecord);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'activities',
            callback: (payload) {
              debugPrint('🔴 Activity updated: ${payload.newRecord}');
              _handleUpdatedActivity(payload.newRecord);
            },
          )
          .subscribe();

      debugPrint('✅ Subscribed to real-time activities');
    } catch (e) {
      debugPrint('❌ Error subscribing to activities: $e');
    }
  }

  /// Unsubscribe from real-time activity updates
  void unsubscribeFromActivities() {
    if (_activitiesChannel != null) {
      _supabase.removeChannel(_activitiesChannel!);
      _activitiesChannel = null;
      debugPrint('🔴 Unsubscribed from real-time activities');
    }
  }

  /// Handle new activity inserted
  void _handleNewActivity(Map<String, dynamic> data) {
    try {
      final newActivity = Activity.fromSupabaseMap(data);

      debugPrint('🔴 REALTIME: New activity received');
      debugPrint('   - ID: ${newActivity.id}');
      debugPrint('   - Habit: ${newActivity.habitTitle}');
      debugPrint('   - User: ${newActivity.userName}');
      debugPrint('   - Created: ${newActivity.createdAt}');
      debugPrint('   - Current feed size: ${state.activityFeed.length}');

      // Check if this activity already exists in the feed (prevent duplicates)
      final exists =
          state.activityFeed.any((activity) => activity.id == newActivity.id);

      if (exists) {
        debugPrint('⚠️ REALTIME: Activity already exists, skipping!');
        debugPrint(
            '   - Existing IDs: ${state.activityFeed.map((a) => a.id).take(3).join(", ")}...');
        return;
      }

      debugPrint('✅ REALTIME: Adding activity to feed');

      // Add to the beginning of the feed
      final updatedFeed = [newActivity, ...state.activityFeed];

      // Limit to 50 activities
      final limitedFeed = updatedFeed.take(50).toList();

      state = state.copyWith(activityFeed: limitedFeed);
      debugPrint(
          '✅ REALTIME: Activity added! Feed now has ${limitedFeed.length} items');
    } catch (e) {
      debugPrint('❌ Error handling new activity: $e');
    }
  }

  /// Handle activity update (for reactions)
  void _handleUpdatedActivity(Map<String, dynamic> data) {
    try {
      final updatedActivity = Activity.fromSupabaseMap(data);

      // Find and update the activity in the feed
      final updatedFeed = state.activityFeed.map((activity) {
        return activity.id == updatedActivity.id ? updatedActivity : activity;
      }).toList();

      state = state.copyWith(activityFeed: updatedFeed);
      debugPrint('✅ Updated activity reactions: ${updatedActivity.habitTitle}');
    } catch (e) {
      debugPrint('❌ Error handling updated activity: $e');
    }
  }

  Future<void> loadFriends(String userId) async {
    try {
      state = state.copyWith(isLoading: true);

      final userResponse = await _supabase
          .from('users')
          .select('friends')
          .eq('id', userId)
          .single();

      final friendIds = List<String>.from(userResponse['friends'] ?? []);

      if (friendIds.isEmpty) {
        state = state.copyWith(friends: [], isLoading: false);
      } else {
        final friendsResponse = await _supabase
            .from('users')
            .select(
                'id, email, display_name, photo_url, bio, total_streaks, longest_streak')
            .inFilter('id', friendIds);

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

      final userResponse = await _supabase
          .from('users')
          .select('friends')
          .eq('id', userId)
          .single();

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

      final newActivities = (response as List)
          .map((data) => Activity.fromSupabaseMap(data))
          .toList();

      debugPrint(
          '🎯 DATABASE: Got ${newActivities.length} activities from query');

      // Check for duplicates in the database response itself
      final dbIds = newActivities.map((a) => a.id).toList();
      final dbUniqueIds = dbIds.toSet();
      if (dbIds.length != dbUniqueIds.length) {
        debugPrint(
            '⚠️ DATABASE: Response contains ${dbIds.length - dbUniqueIds.length} duplicate IDs!');
      }

      // Deduplicate by ID using a Map (keeps most recent version)
      final activitiesMap = <String, Activity>{};

      // Add new activities from database first
      for (var activity in newActivities) {
        activitiesMap[activity.id] = activity;
      }

      debugPrint(
          '🎯 DATABASE: Deduplicated to ${activitiesMap.length} unique activities');

      // Convert back to list and sort by date
      final activityFeed = activitiesMap.values.toList();
      activityFeed.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Limit to 50 most recent
      final limitedFeed = activityFeed.take(50).toList();

      debugPrint(
          '🎯 DATABASE: Final feed has ${limitedFeed.length} activities');

      // Show first 3 IDs for debugging
      if (limitedFeed.isNotEmpty) {
        debugPrint(
            '   - First 3 IDs: ${limitedFeed.take(3).map((a) => a.id).join(", ")}');
      }

      state = state.copyWith(activityFeed: limitedFeed);
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

      // Check if already friends
      final targetUser = await _supabase
          .from('users')
          .select('friends')
          .eq('id', targetUserId)
          .single();

      final friends = List<String>.from(targetUser['friends'] ?? []);
      if (friends.contains(currentUserId)) {
        debugPrint('⚠️ Already friends!');
        throw Exception('Already friends with this user');
      }

      // Check if request already exists
      final existingRequest = await _supabase
          .from('friend_requests')
          .select()
          .eq('from_user_id', currentUserId)
          .eq('to_user_id', targetUserId)
          .eq('status', 'pending')
          .maybeSingle();

      if (existingRequest != null) {
        debugPrint('⚠️ Friend request already sent!');
        throw Exception('Friend request already sent');
      }

      // Insert friend request
      await _supabase.from('friend_requests').insert({
        'from_user_id': currentUserId,
        'to_user_id': targetUserId,
        'status': 'pending',
      });

      debugPrint('✅ Friend request sent successfully');

      // Create notification for the recipient
      await _createFriendRequestNotification(currentUserId, targetUserId);
    } catch (e, stackTrace) {
      debugPrint('❌ Error sending friend request: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow; // Re-throw to show error to user
    }
  }

  Future<void> _createFriendRequestNotification(
    String fromUserId,
    String toUserId,
  ) async {
    try {
      // Get sender's profile
      final userProfile = await _supabase
          .from('users')
          .select()
          .eq('id', fromUserId)
          .maybeSingle();

      if (userProfile == null) return;

      final notification = AppNotification(
        id: '',
        userId: toUserId,
        fromUserId: fromUserId,
        fromUserName: userProfile['display_name'] ?? 'Someone',
        fromUserPhotoUrl: userProfile['photo_url'],
        type: NotificationType.friendRequest,
        createdAt: DateTime.now(),
      );

      await _supabase.from('notifications').insert(notification.toMap());
      debugPrint('✅ Created friend request notification');
    } catch (e) {
      debugPrint('❌ Error creating friend request notification: $e');
    }
  }

  Future<void> acceptFriendRequest(
      String currentUserId, String requesterId) async {
    try {
      debugPrint('✅ Accepting friend request from $requesterId');

      // Get current user friends
      final currentUserData = await _supabase
          .from('users')
          .select('friends')
          .eq('id', currentUserId)
          .single();

      final friends = List<String>.from(currentUserData['friends'] ?? []);
      friends.add(requesterId);

      // Update current user's friends list
      await _supabase.from('users').update({
        'friends': friends,
      }).eq('id', currentUserId);

      // Add current user to requester's friends list
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

      // Update friend request status to 'accepted' (or delete it)
      await _supabase
          .from('friend_requests')
          .delete()
          .eq('from_user_id', requesterId)
          .eq('to_user_id', currentUserId);

      debugPrint('✅ Friend request accepted successfully');

      await loadFriends(currentUserId);
    } catch (e) {
      debugPrint('❌ Error accepting friend request: $e');
    }
  }

  Future<void> rejectFriendRequest(
      String currentUserId, String requesterId) async {
    try {
      debugPrint('🚫 Rejecting friend request from $requesterId');

      // Delete the friend request
      await _supabase
          .from('friend_requests')
          .delete()
          .eq('from_user_id', requesterId)
          .eq('to_user_id', currentUserId);

      debugPrint('✅ Friend request rejected successfully');
    } catch (e) {
      debugPrint('❌ Error rejecting friend request: $e');
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

      // Query friend_requests table for pending requests TO this user
      final response = await _supabase
          .from('friend_requests')
          .select('from_user_id')
          .eq('to_user_id', userId)
          .eq('status', 'pending');

      debugPrint('📬 Raw response: $response');

      final requestIds = (response as List)
          .map((item) => item['from_user_id'] as String)
          .toList();

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
              'id, email, display_name, photo_url, bio, total_streaks, longest_streak')
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
          .select()
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

      // Create notification for activity owner (if not reacting to own activity)
      final activityOwnerId = activityData['user_id'];
      if (activityOwnerId != userId) {
        await _createReactionNotification(
          activityOwnerId: activityOwnerId,
          activityId: activityId,
          fromUserId: userId,
          emoji: emoji,
        );
      }
    } catch (e) {
      debugPrint('Error adding reaction: $e');
    }
  }

  Future<void> _createReactionNotification({
    required String activityOwnerId,
    required String activityId,
    required String fromUserId,
    required String emoji,
  }) async {
    try {
      // Get reactor's profile
      final userProfile = await _supabase
          .from('users')
          .select()
          .eq('id', fromUserId)
          .maybeSingle();

      if (userProfile == null) return;

      final notification = AppNotification(
        id: '',
        userId: activityOwnerId,
        fromUserId: fromUserId,
        fromUserName: userProfile['display_name'] ?? 'Someone',
        fromUserPhotoUrl: userProfile['photo_url'],
        type: NotificationType.reactionAdded,
        activityId: activityId,
        emoji: emoji,
        createdAt: DateTime.now(),
      );

      await _supabase.from('notifications').insert(notification.toMap());
      debugPrint('✅ Created reaction notification');
    } catch (e) {
      debugPrint('Error creating reaction notification: $e');
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
