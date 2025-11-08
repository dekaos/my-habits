class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory Message.fromSupabaseMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['sender_id'] ?? '',
      receiverId: map['receiver_id'] ?? '',
      content: map['content'] ?? '',
      isRead: map['is_read'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'is_read': isRead,
      // Don't send created_at - let database set it with DEFAULT NOW()
      // This ensures consistent server-side timestamps
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
