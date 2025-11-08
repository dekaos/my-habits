import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/activity.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

// Habit State
class HabitState {
  final List<Habit> habits;
  final bool isLoading;
  final String? error;

  HabitState({
    this.habits = const [],
    this.isLoading = false,
    this.error,
  });

  HabitState copyWith({
    List<Habit>? habits,
    bool? isLoading,
    String? error,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Habit Notifier
class HabitNotifier extends Notifier<HabitState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  HabitState build() {
    return HabitState();
  }

  Future<void> loadHabits(String userId) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await _supabase
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final habits = (response as List)
          .map((data) => Habit.fromSupabaseMap(data))
          .toList();

      state = state.copyWith(habits: habits, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      final data = habit.toSupabaseMap();
      await _supabase.from('habits').insert(data);

      final updatedHabits = [habit, ...state.habits];
      state = state.copyWith(habits: updatedHabits);
    } catch (e) {
      debugPrint('Error adding habit: $e');
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _supabase
          .from('habits')
          .update(habit.toSupabaseMap())
          .eq('id', habit.id);

      final updatedHabits = state.habits.map((h) {
        return h.id == habit.id ? habit : h;
      }).toList();

      state = state.copyWith(habits: updatedHabits);

      // Reschedule notification if habit has a scheduled time
      if (habit.scheduledTime != null) {
        try {
          final notificationService = NotificationService();
          await notificationService.cancelHabitNotification(habit.id);
          await notificationService.scheduleHabitNotification(habit);
        } catch (e) {
          debugPrint('Error rescheduling notification: $e');
        }
      }
    } catch (e) {
      debugPrint('Error updating habit: $e');
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      // Cancel scheduled notification
      try {
        await NotificationService().cancelHabitNotification(habitId);
      } catch (e) {
        debugPrint('Error cancelling notification: $e');
      }

      // Delete from database
      await _supabase.from('habits').delete().eq('id', habitId);

      final updatedHabits = state.habits.where((h) => h.id != habitId).toList();
      state = state.copyWith(habits: updatedHabits);
    } catch (e) {
      debugPrint('Error deleting habit: $e');
    }
  }

  Future<void> completeHabit(Habit habit,
      {String? note, String? imageUrl}) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Create completion record
      final completion = HabitCompletion(
        id: '',
        habitId: habit.id,
        userId: habit.userId,
        completedAt: now,
        note: note,
        imageUrl: imageUrl,
      );

      await _supabase
          .from('habit_completions')
          .insert(completion.toSupabaseMap());

      // Update streak
      int newStreak = habit.currentStreak;
      final lastCompleted = habit.lastCompletedDate;

      if (lastCompleted == null) {
        newStreak = 1;
      } else {
        final lastDate = DateTime(
          lastCompleted.year,
          lastCompleted.month,
          lastCompleted.day,
        );
        final difference = today.difference(lastDate).inDays;

        if (difference == 1) {
          newStreak += 1;
        } else if (difference == 0) {
          // Already completed today, don't change streak
          return;
        } else {
          newStreak = 1;
        }
      }

      final updatedHabit = habit.copyWith(
        currentStreak: newStreak,
        longestStreak:
            newStreak > habit.longestStreak ? newStreak : habit.longestStreak,
        lastCompletedDate: now,
        totalCompletions: habit.totalCompletions + 1,
      );

      await _supabase
          .from('habits')
          .update(updatedHabit.toSupabaseMap())
          .eq('id', updatedHabit.id);

      // Update local state immediately for instant UI feedback
      final updatedHabits = state.habits.map((h) {
        return h.id == habit.id ? updatedHabit : h;
      }).toList();

      state = state.copyWith(habits: updatedHabits);

      // Create activity for social feed (only once!)
      debugPrint('📢 About to create habit activity...');
      try {
        await _createHabitActivity(habit, updatedHabit);
      } catch (e) {
        debugPrint('❌ Error creating activity: $e');
      }
      debugPrint('📢 Finished creating habit activity');

      // Update user's total streaks stats
      try {
        await _updateUserStreakStats(habit.userId);
      } catch (e) {
        debugPrint('Error updating user streak stats: $e');
      }

      // Reload to ensure data consistency
      await loadHabits(habit.userId);
    } catch (e) {
      debugPrint('Error completing habit: $e');
    }
  }

  Future<void> _updateUserStreakStats(String userId) async {
    try {
      // Get all user's habits
      final habitsResponse =
          await _supabase.from('habits').select().eq('user_id', userId);

      final habits = (habitsResponse as List)
          .map((data) => Habit.fromSupabaseMap(data))
          .toList();

      // Calculate total active streaks
      final totalStreaks = habits.where((h) => h.currentStreak > 0).length;

      // Calculate longest streak across all habits
      final longestStreak = habits.isEmpty
          ? 0
          : habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);

      // Update user profile
      await _supabase.from('users').update({
        'total_streaks': totalStreaks,
        'longest_streak': longestStreak,
      }).eq('id', userId);

      debugPrint(
          '✅ Updated user stats: $totalStreaks active streaks, longest: $longestStreak');
    } catch (e) {
      debugPrint('Error in _updateUserStreakStats: $e');
    }
  }

  Future<void> _createHabitActivity(Habit habit, Habit updatedHabit) async {
    try {
      // Get user profile info
      final userProfile = await _supabase
          .from('users')
          .select()
          .eq('id', habit.userId)
          .maybeSingle();

      if (userProfile == null) return;

      final userName = userProfile['display_name'] ?? 'Someone';
      final userPhotoUrl = userProfile['photo_url'];

      // Create habit completion activity
      final completionActivity = Activity(
        id: '',
        userId: habit.userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        type: ActivityType.habitCompleted,
        habitId: habit.id,
        habitTitle: habit.title,
        createdAt: DateTime.now(),
      );

      await _supabase
          .from('activities')
          .insert(completionActivity.toSupabaseMap());
      debugPrint('✅ Created habit completion activity');

      // Notify friends about the completion
      if (habit.isPublic) {
        await _notifyFriendsAboutCompletion(
            habit.userId, userName, habit.title, userPhotoUrl);
      }

      // Check for streak milestones (7, 30, 50, 100 days)
      final milestones = [7, 30, 50, 100, 365];
      if (milestones.contains(updatedHabit.currentStreak)) {
        final milestoneActivity = Activity(
          id: '',
          userId: habit.userId,
          userName: userName,
          userPhotoUrl: userPhotoUrl,
          type: ActivityType.streakMilestone,
          habitId: habit.id,
          habitTitle: habit.title,
          streakCount: updatedHabit.currentStreak,
          createdAt: DateTime.now(),
        );

        await _supabase
            .from('activities')
            .insert(milestoneActivity.toSupabaseMap());
        debugPrint(
            '🔥 Created streak milestone activity: ${updatedHabit.currentStreak} days!');
      }
    } catch (e) {
      debugPrint('Error in _createHabitActivity: $e');
    }
  }

  Future<void> _notifyFriendsAboutCompletion(
    String userId,
    String userName,
    String habitTitle,
    String? userPhotoUrl,
  ) async {
    try {
      debugPrint(
          '🔔 _notifyFriendsAboutCompletion called for: $userName - $habitTitle');

      // Get user's friends list
      final userResponse = await _supabase
          .from('users')
          .select('friends')
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null) {
        debugPrint('⚠️ User profile not found, cannot notify friends');
        return;
      }

      final friendIds = List<String>.from(userResponse['friends'] ?? []);

      debugPrint('🔔 User has ${friendIds.length} friends: $friendIds');

      // Remove duplicates from friends list (shouldn't happen, but safety check)
      final uniqueFriendIds = friendIds.toSet().toList();

      if (uniqueFriendIds.length != friendIds.length) {
        debugPrint(
            '⚠️ Found ${friendIds.length - uniqueFriendIds.length} duplicate friend IDs!');
      }

      if (uniqueFriendIds.isEmpty) {
        debugPrint('⚠️ No friends to notify');
        return;
      }

      debugPrint('🔔 Will notify ${uniqueFriendIds.length} unique friends');

      // Create notification for each friend
      final notifications = uniqueFriendIds.map((friendId) {
        debugPrint('🔔 Creating notification for friend: $friendId');
        return AppNotification(
          id: '',
          userId: friendId, // Friend receives the notification
          fromUserId: userId,
          fromUserName: userName,
          fromUserPhotoUrl: userPhotoUrl,
          type: NotificationType.habitCompleted,
          habitTitle: habitTitle,
          createdAt: DateTime.now(),
        ).toMap();
      }).toList();

      debugPrint(
          '🔔 Inserting ${notifications.length} notifications into database');

      // Batch insert notifications
      await _supabase.from('notifications').insert(notifications);

      debugPrint(
          '✅ Successfully created ${notifications.length} notifications');
    } catch (e) {
      debugPrint('❌ Error notifying friends: $e');
    }
  }

  Future<void> uncompleteHabit(Habit habit) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayStart = today.toIso8601String();
      final todayEnd = today.add(const Duration(days: 1)).toIso8601String();

      // Delete today's completion record
      await _supabase
          .from('habit_completions')
          .delete()
          .eq('habit_id', habit.id)
          .eq('user_id', habit.userId)
          .gte('completed_at', todayStart)
          .lt('completed_at', todayEnd);

      // Get previous completion to update last_completed_date
      final previousCompletions = await _supabase
          .from('habit_completions')
          .select()
          .eq('habit_id', habit.id)
          .eq('user_id', habit.userId)
          .lt('completed_at', todayStart)
          .order('completed_at', ascending: false)
          .limit(1);

      DateTime? newLastCompletedDate;
      if (previousCompletions.isNotEmpty) {
        newLastCompletedDate =
            DateTime.parse(previousCompletions[0]['completed_at']);
      }

      final updatedHabit = habit.copyWith(
        lastCompletedDate: newLastCompletedDate,
        currentStreak: habit.currentStreak > 0 ? habit.currentStreak - 1 : 0,
        totalCompletions:
            habit.totalCompletions > 0 ? habit.totalCompletions - 1 : 0,
      );

      // Update database
      await _supabase.from('habits').update({
        'last_completed_date': newLastCompletedDate?.toIso8601String(),
        'current_streak': updatedHabit.currentStreak,
        'total_completions': updatedHabit.totalCompletions,
      }).eq('id', habit.id);

      // Update local state immediately for instant UI feedback
      final updatedHabits = state.habits.map((h) {
        return h.id == habit.id ? updatedHabit : h;
      }).toList();

      state = state.copyWith(habits: updatedHabits);

      // Update user's streak stats
      try {
        await _updateUserStreakStats(habit.userId);
      } catch (e) {
        debugPrint('Error updating user streak stats: $e');
      }

      // Reload to ensure data consistency
      await loadHabits(habit.userId);
    } catch (e) {
      debugPrint('Error uncompleting habit: $e');
    }
  }

  Future<List<HabitCompletion>> getHabitCompletions(String habitId) async {
    try {
      final response = await _supabase
          .from('habit_completions')
          .select()
          .eq('habit_id', habitId)
          .order('completed_at', ascending: false);

      return (response as List)
          .map((data) => HabitCompletion.fromSupabaseMap(data))
          .toList();
    } catch (e) {
      debugPrint('Error loading completions: $e');
      return [];
    }
  }

  bool isHabitCompletedToday(Habit habit) {
    // Find the current habit from the list to get latest state
    final currentHabit = state.habits.firstWhere(
      (h) => h.id == habit.id,
      orElse: () => habit,
    );

    if (currentHabit.lastCompletedDate == null) return false;

    final today = DateTime.now();
    final lastCompleted = currentHabit.lastCompletedDate!;

    return today.year == lastCompleted.year &&
        today.month == lastCompleted.month &&
        today.day == lastCompleted.day;
  }

  List<Habit> getTodaysHabits() {
    final today = DateTime.now().weekday - 1; // 0 = Monday
    return state.habits.where((habit) {
      if (habit.frequency == HabitFrequency.daily) return true;
      if (habit.frequency == HabitFrequency.weekly) return today == 0; // Monday
      if (habit.frequency == HabitFrequency.custom) {
        return habit.customDays.contains(today);
      }
      return false;
    }).toList();
  }
}

// Provider
final habitProvider =
    NotifierProvider<HabitNotifier, HabitState>(HabitNotifier.new);
