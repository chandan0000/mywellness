/// Conversation Model - Data Layer
library;

import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import 'message_model.dart';
import 'participant_model.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.type,
    super.name,
    super.avatarUrl,
    super.participants,
    super.lastMessage,
    super.lastMessageAt,
    super.unreadCount,
    super.isMuted,
    required super.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] == 'group'
          ? ConversationType.group
          : ConversationType.individual,
      name: json['name'],
      avatarUrl: json['avatar_url'],
      participants: (json['participants'] as List?)
              ?.map((p) => ParticipantModel.fromJson(p))
              .toList() ??
          [],
      lastMessage: json['last_message'] != null
          ? (json['last_message'] is Map
              ? MessageModel.fromJson(json['last_message'])
              : null)
          : null,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      isMuted: json['is_muted'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'avatar_url': avatarUrl,
      'last_message': lastMessage != null
          ? (lastMessage as MessageModel).toJson()
          : null,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
      'is_muted': isMuted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
