import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';

class MessagingState {
  final Map<String, List<Message>> conversations;
  final Map<String, int> unreadCounts;
  final bool isLoading;

  MessagingState({
    this.conversations = const {},
    this.unreadCounts = const {},
    this.isLoading = false,
  });

  MessagingState copyWith({
    Map<String, List<Message>>? conversations,
    Map<String, int>? unreadCounts,
    bool? isLoading,
  }) {
    return MessagingState(
      conversations: conversations ?? this.conversations,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MessagingNotifier extends Notifier<MessagingState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _messageChannel;

  @override
  MessagingState build() {
    return MessagingState();
  }

  Future<void> loadConversation(String currentUserId, String friendId) async {
    try {
      debugPrint('💬 Loading conversation with: $friendId');

      final response = await _supabase
          .from('messages')
          .select()
          .or('and(sender_id.eq.$currentUserId,receiver_id.eq.$friendId),and(sender_id.eq.$friendId,receiver_id.eq.$currentUserId)')
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((data) => Message.fromSupabaseMap(data))
          .toList();

      debugPrint('💬 Loaded ${messages.length} messages');

      final updatedConversations =
          Map<String, List<Message>>.from(state.conversations);
      updatedConversations[friendId] = messages;

      final unread = messages
          .where((m) => m.receiverId == currentUserId && !m.isRead)
          .length;

      final updatedUnreadCounts = Map<String, int>.from(state.unreadCounts);
      updatedUnreadCounts[friendId] = unread;

      state = state.copyWith(
        conversations: updatedConversations,
        unreadCounts: updatedUnreadCounts,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading conversation: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> sendMessage(
    String currentUserId,
    String friendId,
    String content,
  ) async {
    try {
      debugPrint('📤 Sending message to: $friendId');

      final message = Message(
        id: '',
        senderId: currentUserId,
        receiverId: friendId,
        content: content,
        createdAt: DateTime.now(),
        isRead: false,
      );

      final response = await _supabase
          .from('messages')
          .insert(message.toSupabaseMap())
          .select()
          .single();

      final sentMessage = Message.fromSupabaseMap(response);

      debugPrint('✅ Message sent: ${sentMessage.id}');

      final updatedConversations =
          Map<String, List<Message>>.from(state.conversations);
      final currentMessages =
          List<Message>.from(updatedConversations[friendId] ?? []);
      currentMessages.add(sentMessage);

      currentMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      updatedConversations[friendId] = currentMessages;

      state = state.copyWith(conversations: updatedConversations);
    } catch (e, stackTrace) {
      debugPrint('❌ Error sending message: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(String currentUserId, String friendId) async {
    try {
      debugPrint('📖 Marking messages as read from: $friendId');

      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('sender_id', friendId)
          .eq('receiver_id', currentUserId)
          .eq('is_read', false);

      final updatedConversations =
          Map<String, List<Message>>.from(state.conversations);
      final messages = updatedConversations[friendId];

      if (messages != null) {
        updatedConversations[friendId] = messages.map((m) {
          if (m.senderId == friendId &&
              m.receiverId == currentUserId &&
              !m.isRead) {
            return m.copyWith(isRead: true);
          }
          return m;
        }).toList();
      }

      final updatedUnreadCounts = Map<String, int>.from(state.unreadCounts);
      updatedUnreadCounts[friendId] = 0;

      state = state.copyWith(
        conversations: updatedConversations,
        unreadCounts: updatedUnreadCounts,
      );

      debugPrint('✅ Messages marked as read');
    } catch (e) {
      debugPrint('❌ Error marking messages as read: $e');
    }
  }

  Future<void> loadUnreadCounts(
      String currentUserId, List<String> friendIds) async {
    try {
      debugPrint('📊 Loading unread counts for ${friendIds.length} friends');
      debugPrint('📊 Current user ID: $currentUserId');
      debugPrint('📊 Friend IDs: $friendIds');

      final Map<String, int> counts = {};

      for (final friendId in friendIds) {
        final response = await _supabase
            .from('messages')
            .select()
            .eq('sender_id', friendId)
            .eq('receiver_id', currentUserId)
            .eq('is_read', false);

        final count = (response as List).length;
        counts[friendId] = count;

        if (count > 0) {
          debugPrint('📊 Friend $friendId has $count unread messages');
        }
      }

      debugPrint('📊 Total unread counts loaded: $counts');
      debugPrint(
          '📊 Total unread: ${counts.values.fold(0, (sum, c) => sum + c)}');

      state = state.copyWith(unreadCounts: counts);

      debugPrint('✅ Unread counts state updated');
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading unread counts: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Subscribe to real-time messages
  void subscribeToMessages(String currentUserId) {
    try {
      // Unsubscribe from any existing channel first
      unsubscribeFromMessages();

      debugPrint(
          '🔔 Subscribing to real-time messages for user: $currentUserId');

      _messageChannel = _supabase
          .channel('messages_$currentUserId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'receiver_id',
              value: currentUserId,
            ),
            callback: (payload) {
              debugPrint('🔔 New message received via realtime!');
              debugPrint('🔔 Payload: ${payload.newRecord}');
              _handleNewMessage(payload.newRecord, currentUserId);
            },
          )
          .subscribe((status, error) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          debugPrint('✅ Successfully subscribed to messages channel');
        } else if (error != null) {
          debugPrint('❌ Error subscribing to messages: $error');
        } else {
          debugPrint('🔄 Subscription status: $status');
        }
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error subscribing to messages: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _handleNewMessage(
      Map<String, dynamic> data, String currentUserId) async {
    try {
      debugPrint('📨 Handling new message: $data');
      final message = Message.fromSupabaseMap(data);
      final friendId = message.senderId;

      debugPrint('📨 Message from: $friendId, content: ${message.content}');

      final updatedConversations =
          Map<String, List<Message>>.from(state.conversations);
      final currentMessages =
          List<Message>.from(updatedConversations[friendId] ?? []);
      currentMessages.add(message);

      currentMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      updatedConversations[friendId] = currentMessages;

      final updatedUnreadCounts = Map<String, int>.from(state.unreadCounts);
      final oldCount = updatedUnreadCounts[friendId] ?? 0;
      updatedUnreadCounts[friendId] = oldCount + 1;

      debugPrint(
          '📨 Unread count for $friendId: $oldCount → ${updatedUnreadCounts[friendId]}');
      debugPrint('📨 Total unread counts: $updatedUnreadCounts');

      state = state.copyWith(
        conversations: updatedConversations,
        unreadCounts: updatedUnreadCounts,
      );

      debugPrint('✅ State updated with new message');
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling new message: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void unsubscribeFromMessages() {
    if (_messageChannel != null) {
      debugPrint('🔕 Unsubscribing from real-time messages');
      _supabase.removeChannel(_messageChannel!);
      _messageChannel = null;
    }
  }

  int getTotalUnreadCount() {
    return state.unreadCounts.values.fold(0, (sum, count) => sum + count);
  }
}

final messagingProvider = NotifierProvider<MessagingNotifier, MessagingState>(
  () => MessagingNotifier(),
);
