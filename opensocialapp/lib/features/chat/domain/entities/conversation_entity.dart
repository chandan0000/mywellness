/// Conversation Entity - Domain Layer
library;

import 'package:equatable/equatable.dart';
import 'message_entity.dart';
import 'participant_entity.dart';

enum ConversationType { individual, group }

class ConversationEntity extends Equatable {
  final String id;
  final ConversationType type;
  final String? name;
  final String? avatarUrl;
  final List<ParticipantEntity> participants;
  final MessageEntity? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isMuted;
  final DateTime createdAt;

  const ConversationEntity({
    required this.id,
    required this.type,
    this.name,
    this.avatarUrl,
    this.participants = const [],
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isMuted = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        name,
        avatarUrl,
        participants,
        lastMessage,
        lastMessageAt,
        unreadCount,
        isMuted,
        createdAt,
      ];

  ConversationEntity copyWith({
    String? id,
    ConversationType? type,
    String? name,
    String? avatarUrl,
    List<ParticipantEntity>? participants,
    MessageEntity? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isMuted,
    DateTime? createdAt,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
