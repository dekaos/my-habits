import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/activity.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../utils/performance_utils.dart';

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

      // Fetch habits ordered by icon (category) and current_streak descending
      final response = await _supabase
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('icon', ascending: true)
          .order('current_streak', ascending: false);

      final habits = await PerformanceUtils.parseJsonList<Habit>(
        jsonList: response as List,
        parser: Habit.fromSupabaseMap,
        threshold: 30,
      );

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
      try {
        await NotificationService().cancelHabitNotification(habitId);
      } catch (e) {
        debugPrint('Error cancelling notification: $e');
      }

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

      int newStreak = habit.currentStreak;
      final lastCompleted = habit.lastCompletedDate;
      bool isFirstCompletionToday = false;

      if (lastCompleted == null) {
        newStreak = 1;
        isFirstCompletionToday = true;
      } else {
        final lastDate = DateTime(
          lastCompleted.year,
          lastCompleted.month,
          lastCompleted.day,
        );
        final difference = today.difference(lastDate).inDays;

        if (difference == 1) {
          newStreak += 1;
          isFirstCompletionToday = true;
        } else if (difference == 0) {
          isFirstCompletionToday = false;
        } else {
          newStreak = 1;
          isFirstCompletionToday = true;
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

      final updatedHabits = state.habits.map((h) {
        return h.id == habit.id ? updatedHabit : h;
      }).toList();

      state = state.copyWith(habits: updatedHabits);

      if (isFirstCompletionToday) {
        try {
          await _createHabitActivity(habit, updatedHabit);
        } catch (e) {
          debugPrint('Error creating activity: $e');
        }
      }

      _updateUserStreakStats(habit.userId).catchError((e) {
        debugPrint('Error updating user streak stats: $e');
      });
    } catch (e) {
      debugPrint('Error completing habit: $e');
    }
  }

  Future<void> _updateUserStreakStats(String userId) async {
    try {
      final habitsResponse =
          await _supabase.from('habits').select().eq('user_id', userId);

      final habits = (habitsResponse as List)
          .map((data) => Habit.fromSupabaseMap(data))
          .toList();

      final totalStreaks = habits.where((h) => h.currentStreak > 0).length;

      final longestStreak = habits.isEmpty
          ? 0
          : habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);

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

      if (habit.isPublic) {
        await _notifyFriendsAboutCompletion(
            habit.userId, userName, habit.title, userPhotoUrl);
      }

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

      final todayCompletionsResponse = await _supabase
          .from('habit_completions')
          .select()
          .eq('habit_id', habit.id)
          .eq('user_id', habit.userId)
          .gte('completed_at', todayStart)
          .lt('completed_at', todayEnd);

      final completionsToDelete = (todayCompletionsResponse as List).length;

      await _supabase
          .from('habit_completions')
          .delete()
          .eq('habit_id', habit.id)
          .eq('user_id', habit.userId)
          .gte('completed_at', todayStart)
          .lt('completed_at', todayEnd);

      final optimisticHabit = habit.copyWith(
        clearLastCompletedDate: true,
        currentStreak: habit.currentStreak > 0 ? habit.currentStreak - 1 : 0,
        totalCompletions: habit.totalCompletions > completionsToDelete
            ? habit.totalCompletions - completionsToDelete
            : 0,
      );

      final optimisticHabits = state.habits.map((h) {
        return h.id == habit.id ? optimisticHabit : h;
      }).toList();

      state = state.copyWith(habits: optimisticHabits);

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

      await _supabase.from('habits').update({
        'last_completed_date': newLastCompletedDate?.toIso8601String(),
        'current_streak': optimisticHabit.currentStreak,
        'total_completions': optimisticHabit.totalCompletions,
      }).eq('id', habit.id);

      final finalHabit = optimisticHabit.copyWith(
        lastCompletedDate: newLastCompletedDate,
      );

      final finalHabits = state.habits.map((h) {
        return h.id == habit.id ? finalHabit : h;
      }).toList();

      state = state.copyWith(habits: finalHabits);

      _updateUserStreakStats(habit.userId).catchError((e) {
        debugPrint('Error updating user streak stats: $e');
      });
    } catch (e) {
      debugPrint('Error uncompleting habit: $e');
      // TODO: Consider rolling back optimistic update on error
    }
  }

  Future<List<HabitCompletion>> getHabitCompletions(String habitId) async {
    try {
      final response = await _supabase
          .from('habit_completions')
          .select()
          .eq('habit_id', habitId)
          .order('completed_at', ascending: false);

      return await PerformanceUtils.parseJsonList<HabitCompletion>(
        jsonList: response as List,
        parser: HabitCompletion.fromSupabaseMap,
        threshold: 100,
      );
    } catch (e) {
      debugPrint('Error loading completions: $e');
      return [];
    }
  }

  Future<List<HabitCompletion>> getAllUserCompletions(String userId) async {
    try {
      final response = await _supabase
          .from('habit_completions')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false);

      return await PerformanceUtils.parseJsonList<HabitCompletion>(
        jsonList: response as List,
        parser: HabitCompletion.fromSupabaseMap,
        threshold: 100,
      );
    } catch (e) {
      debugPrint('Error loading all user completions: $e');
      return [];
    }
  }

  Future<int> getTodayCompletionCount(String habitId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('habit_completions')
          .select()
          .eq('habit_id', habitId)
          .gte('completed_at', startOfDay.toIso8601String())
          .lt('completed_at', endOfDay.toIso8601String());

      return (response as List).length;
    } catch (e) {
      debugPrint('Error getting today completion count: $e');
      return 0;
    }
  }

  bool isHabitCompletedToday(Habit habit) {
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
    final today = DateTime.now().weekday - 1; // 0 = Monday, 6 = Sunday
    return state.habits.where((habit) {
      if (habit.frequency == HabitFrequency.daily) return true;

      if (habit.frequency == HabitFrequency.weekly) {
        final createdWeekday =
            habit.createdAt.weekday - 1; // 0-based (0=Mon, 6=Sun)
        return today == createdWeekday;
      }

      if (habit.frequency == HabitFrequency.custom) {
        return habit.customDays.contains(today);
      }

      return false;
    }).toList();
  }

  /// Group habits by category (icon name) for today's habits
  Map<String, List<Habit>> getTodaysHabitsByCategory() {
    final todaysHabits = getTodaysHabits();
    return _groupHabitsByCategory(todaysHabits);
  }

  /// Group habits by category (icon name) for all habits
  Map<String, List<Habit>> getAllHabitsByCategory() {
    return _groupHabitsByCategory(state.habits);
  }

  /// Group a specific list of habits by category (public method)
  Map<String, List<Habit>> groupHabitsByCategory(List<Habit> habits) {
    return _groupHabitsByCategory(habits);
  }

  /// Get categories ordered by max streak (descending) then alphabetically
  List<String> getCategoriesOrderedByStreak(Map<String, List<Habit>> grouped) {
    final categories = grouped.keys.toList();

    // Calculate max streak for each category
    final categoryStreaks = <String, int>{};
    for (final category in categories) {
      final habits = grouped[category]!;
      final maxStreak = habits.isEmpty
          ? 0
          : habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
      categoryStreaks[category] = maxStreak;
    }

    // Sort: first by max streak (descending), then alphabetically
    categories.sort((a, b) {
      final streakA = categoryStreaks[a]!;
      final streakB = categoryStreaks[b]!;

      if (streakA != streakB) {
        return streakB.compareTo(streakA); // Descending order
      }

      return a.compareTo(b); // Alphabetical order
    });

    return categories;
  }

  /// Helper method to group habits by category
  Map<String, List<Habit>> _groupHabitsByCategory(List<Habit> habits) {
    final grouped = <String, List<Habit>>{};

    for (final habit in habits) {
      final category = habit.icon ?? 'other';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(habit);
    }

    return grouped;
  }
}

final habitProvider =
    NotifierProvider<HabitNotifier, HabitState>(HabitNotifier.new);
