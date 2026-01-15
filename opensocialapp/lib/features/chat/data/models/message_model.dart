/// Message Model - Data Layer
library;

import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    super.senderId,
    required super.type,
    required super.content,
    super.mediaUrl,
    super.replyToId,
    required super.status,
    super.isEdited,
    super.isDeleted,
    required super.createdAt,
    super.localId,
    super.isSynced,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString(),
      type: _parseMessageType(json['type']),
      content: json['content'] ?? '',
      mediaUrl: json['media_url'],
      replyToId: json['reply_to_id']?.toString(),
      status: _parseMessageStatus(json['status']),
      isEdited: json['is_edited'] == true,
      isDeleted: json['is_deleted'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      localId: json['local_id']?.toString(),
      isSynced: json['is_synced'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'type': type.name,
      'content': content,
      'media_url': mediaUrl,
      'reply_to_id': replyToId,
      'status': status.name,
      'is_edited': isEdited,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'local_id': localId,
      'is_synced': isSynced,
    };
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'file':
        return MessageType.file;
      case 'location':
        return MessageType.location;
      default:
        return MessageType.text;
    }
  }

  static MessageStatus _parseMessageStatus(String? status) {
    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }
}
