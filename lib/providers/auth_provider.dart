import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

// Auth State
class AuthState {
  final User? user;
  final UserProfile? userProfile;
  final bool isLoading;

  AuthState({
    this.user,
    this.userProfile,
    this.isLoading = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    UserProfile? userProfile,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Auth Notifier
class AuthNotifier extends Notifier<AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  AuthState build() {
    // Set up auth state listener
    _supabase.auth.onAuthStateChange.listen((data) {
      _onAuthStateChanged(data.session?.user);
    });

    // Get current user from session
    final currentUser = _supabase.auth.currentSession?.user;

    // If user is authenticated, load their profile asynchronously
    if (currentUser != null) {
      _loadUserProfile(currentUser.id);
      return AuthState(user: currentUser);
    }

    return AuthState();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    state = state.copyWith(user: user, userProfile: null);
    if (user != null) {
      await _loadUserProfile(user.id);
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();

      if (response != null) {
        final userProfile = UserProfile.fromMap(response, userId);
        state = state.copyWith(userProfile: userProfile);
      } else {
        await _createDefaultProfile(userId);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      await _createDefaultProfile(userId);
    }
  }

  Future<void> _createDefaultProfile(String userId) async {
    try {
      final user = state.user ?? _supabase.auth.currentUser;
      if (user == null) return;

      final profile = UserProfile(
        id: userId,
        email: user.email ?? 'user@example.com',
        displayName: user.email?.split('@')[0] ?? 'User',
        joinedAt: DateTime.now(),
      );

      await _supabase.from('users').insert(profile.toInsertMap());
      state = state.copyWith(userProfile: profile);
      debugPrint('Created default profile for user $userId');
    } catch (e) {
      debugPrint('Error creating default profile: $e');
      final user = state.user ?? _supabase.auth.currentUser;
      if (user != null) {
        final tempProfile = UserProfile(
          id: userId,
          email: user.email ?? 'user@example.com',
          displayName: user.email?.split('@')[0] ?? 'User',
          joinedAt: DateTime.now(),
        );
        state = state.copyWith(userProfile: tempProfile);
      }
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        // Create user profile in database
        final profile = UserProfile(
          id: authResponse.user!.id,
          email: email,
          displayName: displayName,
          joinedAt: DateTime.now(),
        );

        try {
          await _supabase.from('users').insert(profile.toInsertMap());
          state = state.copyWith(
            user: authResponse.user,
            userProfile: profile,
            isLoading: false,
          );
        } catch (dbError) {
          debugPrint('Database error (continuing anyway): $dbError');
          state = state.copyWith(
            user: authResponse.user,
            userProfile: profile,
            isLoading: false,
          );
        }
      }

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = AuthState();
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? bio,
  }) async {
    if (state.user == null || state.userProfile == null) return;

    try {
      final Map<String, dynamic> updateData = {};

      if (displayName != null) {
        updateData['display_name'] = displayName;
      }
      if (photoUrl != null) {
        updateData['photo_url'] = photoUrl;
      }
      if (bio != null) {
        updateData['bio'] = bio;
      }

      if (updateData.isNotEmpty) {
        await _supabase
            .from('users')
            .update(updateData)
            .eq('id', state.user!.id);
      }

      final updatedProfile = state.userProfile!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
        bio: bio,
      );

      state = state.copyWith(userProfile: updatedProfile);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }
}

// Provider
final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
