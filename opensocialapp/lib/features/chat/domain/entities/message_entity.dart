/// Message Entity - Domain Layer
library;

import 'package:equatable/equatable.dart';

enum MessageType { text, image, video, audio, file, location }
enum MessageStatus { sending, sent, delivered, read, failed }

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String? senderId;
  final MessageType type;
  final String content;
  final String? mediaUrl;
  final String? replyToId;
  final MessageStatus status;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final String? localId;
  final bool isSynced;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    this.senderId,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.replyToId,
    required this.status,
    this.isEdited = false,
    this.isDeleted = false,
    required this.createdAt,
    this.localId,
    this.isSynced = true,
  });

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        type,
        content,
        mediaUrl,
        replyToId,
        status,
        isEdited,
        isDeleted,
        createdAt,
        localId,
        isSynced,
      ];

  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    MessageType? type,
    String? content,
    String? mediaUrl,
    String? replyToId,
    MessageStatus? status,
    bool? isEdited,
    bool? isDeleted,
    DateTime? createdAt,
    String? localId,
    bool? isSynced,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      replyToId: replyToId ?? this.replyToId,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      localId: localId ?? this.localId,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
