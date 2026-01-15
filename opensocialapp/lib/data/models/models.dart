/// Data models for the chat application
library;

import 'package:equatable/equatable.dart';

// ===== Enums =====

enum ConversationType { individual, group }

enum MessageType { text, image, video, audio, file, system }

enum MessageStatus { sent, delivered, read }

enum CallType { audio, video }

enum CallStatus { initiated, ringing, ongoing, ended, missed, rejected }

// ===== User Model =====

class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profileUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profileUrl,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      profileUrl: json['profile_url'] ?? json['profileUrl'],
      isOnline: json['is_online'] ?? json['isOnline'] ?? false,
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen']) 
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'phone_number': phoneNumber,
    'profile_url': profileUrl,
    'is_online': isOnline ? 1 : 0,
    'last_seen': lastSeen?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profileUrl,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileUrl: profileUrl ?? this.profileUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, fullName, email, isOnline];
}

// ===== Participant Model =====

class Participant extends Equatable {
  final String id;
  final String conversationId;
  final String userId;
  final bool isAdmin;
  final bool isMuted;
  final int unreadCount;
  final DateTime? lastReadAt;
  final DateTime joinedAt;
  // User info
  final String? userName;
  final String? userEmail;
  final String? userAvatar;
  final bool isOnline;

  const Participant({
    required this.id,
    required this.conversationId,
    required this.userId,
    this.isAdmin = false,
    this.isMuted = false,
    this.unreadCount = 0,
    this.lastReadAt,
    required this.joinedAt,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.isOnline = false,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      isAdmin: json['is_admin'] ?? false,
      isMuted: json['is_muted'] ?? false,
      unreadCount: json['unread_count'] ?? 0,
      lastReadAt: json['last_read_at'] != null 
          ? DateTime.parse(json['last_read_at']) 
          : null,
      joinedAt: DateTime.parse(json['joined_at'] ?? DateTime.now().toIso8601String()),
      userName: json['user_name'] ?? json['full_name'],
      userEmail: json['user_email'] ?? json['email'],
      userAvatar: json['user_avatar'] ?? json['profile_url'],
      isOnline: json['is_online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'user_id': userId,
    'is_admin': isAdmin ? 1 : 0,
    'is_muted': isMuted ? 1 : 0,
    'unread_count': unreadCount,
    'last_read_at': lastReadAt?.toIso8601String(),
    'joined_at': joinedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, conversationId, userId];
}

// ===== Message Model =====

class Message extends Equatable {
  final String id;
  final String conversationId;
  final String? senderId;
  final MessageType type;
  final String content;
  final String? mediaUrl;
  final String? mediaThumbnailUrl;
  final String? replyToId;
  final MessageStatus status;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Sender info
  final String? senderName;
  final String? senderAvatar;
  // Local fields
  final String? localId;
  final bool isSynced;

  const Message({
    required this.id,
    required this.conversationId,
    this.senderId,
    this.type = MessageType.text,
    required this.content,
    this.mediaUrl,
    this.mediaThumbnailUrl,
    this.replyToId,
    this.status = MessageStatus.sent,
    this.isEdited = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.senderName,
    this.senderAvatar,
    this.localId,
    this.isSynced = true,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString(),
      type: MessageType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      content: json['content'] ?? '',
      mediaUrl: json['media_url'],
      mediaThumbnailUrl: json['media_thumbnail_url'],
      replyToId: json['reply_to_id']?.toString(),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      isEdited: json['is_edited'] == 1 || json['is_edited'] == true,
      isDeleted: json['is_deleted'] == 1 || json['is_deleted'] == true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
      localId: json['local_id'],
      isSynced: json['is_synced'] == 1 || json['is_synced'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'sender_id': senderId,
    'type': type.name,
    'content': content,
    'media_url': mediaUrl,
    'media_thumbnail_url': mediaThumbnailUrl,
    'reply_to_id': replyToId,
    'status': status.name,
    'is_edited': isEdited ? 1 : 0,
    'is_deleted': isDeleted ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'local_id': localId,
    'is_synced': isSynced ? 1 : 0,
  };

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    MessageType? type,
    String? content,
    String? mediaUrl,
    String? mediaThumbnailUrl,
    String? replyToId,
    MessageStatus? status,
    bool? isEdited,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? senderName,
    String? senderAvatar,
    String? localId,
    bool? isSynced,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaThumbnailUrl: mediaThumbnailUrl ?? this.mediaThumbnailUrl,
      replyToId: replyToId ?? this.replyToId,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      localId: localId ?? this.localId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [id, conversationId, content, createdAt];
}

// ===== Conversation Model =====

class Conversation extends Equatable {
  final String id;
  final ConversationType type;
  final String? name;
  final String? avatarUrl;
  final String createdBy;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Participant> participants;
  final Message? lastMessage;
  final int unreadCount;
  final bool isMuted;

  const Conversation({
    required this.id,
    this.type = ConversationType.individual,
    this.name,
    this.avatarUrl,
    required this.createdBy,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    this.participants = const [],
    this.lastMessage,
    this.unreadCount = 0,
    this.isMuted = false,
  });

  /// Get display name for the conversation
  String getDisplayName(String currentUserId) {
    if (type == ConversationType.group) {
      return name ?? 'Group Chat';
    }
    // For individual chats, show the other person's name
    final otherParticipant = participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.isNotEmpty ? participants.first : Participant(
        id: '',
        conversationId: '',
        userId: '',
        joinedAt: DateTime.now(),
      ),
    );
    return otherParticipant.userName ?? 'Unknown';
  }

  /// Get avatar for the conversation
  String? getAvatarUrl(String currentUserId) {
    if (type == ConversationType.group) {
      return avatarUrl;
    }
    final otherParticipant = participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.isNotEmpty ? participants.first : Participant(
        id: '',
        conversationId: '',
        userId: '',
        joinedAt: DateTime.now(),
      ),
    );
    return otherParticipant.userAvatar;
  }

  /// Get the other user in a 1-on-1 conversation
  Participant? getOtherParticipant(String currentUserId) {
    if (type == ConversationType.group || participants.isEmpty) return null;
    return participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.first,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      type: ConversationType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'individual'),
        orElse: () => ConversationType.individual,
      ),
      name: json['name'],
      avatarUrl: json['avatar_url'],
      createdBy: json['created_by']?.toString() ?? '',
      lastMessageAt: json['last_message_at'] != null 
          ? DateTime.parse(json['last_message_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      participants: (json['participants'] as List<dynamic>?)
          ?.map((p) => Participant.fromJson(p))
          .toList() ?? [],
      lastMessage: json['last_message'] != null 
          ? Message.fromJson(json['last_message']) 
          : null,
      unreadCount: json['unread_count'] ?? 0,
      isMuted: json['is_muted'] == 1 || json['is_muted'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'avatar_url': avatarUrl,
    'created_by': createdBy,
    'last_message_at': lastMessageAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'unread_count': unreadCount,
    'is_muted': isMuted ? 1 : 0,
  };

  Conversation copyWith({
    String? id,
    ConversationType? type,
    String? name,
    String? avatarUrl,
    String? createdBy,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Participant>? participants,
    Message? lastMessage,
    int? unreadCount,
    bool? isMuted,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  List<Object?> get props => [id, type, name, lastMessageAt];
}

// ===== Call Session Model =====

class CallSession extends Equatable {
  final String id;
  final String conversationId;
  final String callerId;
  final String calleeId;
  final CallType type;
  final CallStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final DateTime createdAt;
  // User info
  final String? callerName;
  final String? callerAvatar;
  final String? calleeName;
  final String? calleeAvatar;

  const CallSession({
    required this.id,
    required this.conversationId,
    required this.callerId,
    required this.calleeId,
    required this.type,
    this.status = CallStatus.initiated,
    this.startedAt,
    this.endedAt,
    this.durationSeconds,
    required this.createdAt,
    this.callerName,
    this.callerAvatar,
    this.calleeName,
    this.calleeAvatar,
  });

  factory CallSession.fromJson(Map<String, dynamic> json) {
    return CallSession(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      callerId: json['caller_id']?.toString() ?? '',
      calleeId: json['callee_id']?.toString() ?? '',
      type: CallType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'audio'),
        orElse: () => CallType.audio,
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'initiated'),
        orElse: () => CallStatus.initiated,
      ),
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at']) 
          : null,
      endedAt: json['ended_at'] != null 
          ? DateTime.parse(json['ended_at']) 
          : null,
      durationSeconds: json['duration_seconds'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      callerName: json['caller_name'],
      callerAvatar: json['caller_avatar'],
      calleeName: json['callee_name'],
      calleeAvatar: json['callee_avatar'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'caller_id': callerId,
    'callee_id': calleeId,
    'type': type.name,
    'status': status.name,
    'started_at': startedAt?.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'duration_seconds': durationSeconds,
    'created_at': createdAt.toIso8601String(),
  };

  CallSession copyWith({
    String? id,
    String? conversationId,
    String? callerId,
    String? calleeId,
    CallType? type,
    CallStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    DateTime? createdAt,
    String? callerName,
    String? callerAvatar,
    String? calleeName,
    String? calleeAvatar,
  }) {
    return CallSession(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      callerId: callerId ?? this.callerId,
      calleeId: calleeId ?? this.calleeId,
      type: type ?? this.type,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
      callerName: callerName ?? this.callerName,
      callerAvatar: callerAvatar ?? this.callerAvatar,
      calleeName: calleeName ?? this.calleeName,
      calleeAvatar: calleeAvatar ?? this.calleeAvatar,
    );
  }

  @override
  List<Object?> get props => [id, callerId, calleeId, type, status];
}
