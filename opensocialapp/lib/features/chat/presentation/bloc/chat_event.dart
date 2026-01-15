/// Chat Events - Presentation Layer
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Load all conversations
class ChatLoadConversations extends ChatEvent {
  final int page;

  const ChatLoadConversations({this.page = 1});

  @override
  List<Object?> get props => [page];
}

/// Load messages for a conversation
class ChatLoadMessages extends ChatEvent {
  final ConversationEntity conversation;
  final int page;

  const ChatLoadMessages({
    required this.conversation,
    this.page = 1,
  });

  @override
  List<Object?> get props => [conversation, page];
}

/// Send a message
class ChatSendMessage extends ChatEvent {
  final String content;
  final MessageType type;
  final String? mediaUrl;
  final String? replyToId;

  const ChatSendMessage({
    required this.content,
    this.type = MessageType.text,
    this.mediaUrl,
    this.replyToId,
  });

  @override
  List<Object?> get props => [content, type, mediaUrl, replyToId];
}

/// New message received from socket
class ChatMessageReceived extends ChatEvent {
  final MessageEntity message;

  const ChatMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

/// Mark messages as read
class ChatMarkMessagesRead extends ChatEvent {
  final List<String> messageIds;

  const ChatMarkMessagesRead(this.messageIds);

  @override
  List<Object?> get props => [messageIds];
}

/// Send typing indicator
class ChatSendTyping extends ChatEvent {
  final bool isTyping;

  const ChatSendTyping(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}

/// Typing indicator received
class ChatTypingReceived extends ChatEvent {
  final String conversationId;
  final String userId;
  final bool isTyping;

  const ChatTypingReceived({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [conversationId, userId, isTyping];
}

/// Leave current conversation
class ChatLeaveConversation extends ChatEvent {
  const ChatLeaveConversation();
}
