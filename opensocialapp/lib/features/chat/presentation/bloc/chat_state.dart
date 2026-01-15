/// Chat States - Presentation Layer
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Loading state
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Conversations loaded
class ChatConversationsLoaded extends ChatState {
  final List<ConversationEntity> conversations;
  final bool hasMore;

  const ChatConversationsLoaded({
    required this.conversations,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [conversations, hasMore];
}

/// Messages loaded
class ChatMessagesLoaded extends ChatState {
  final ConversationEntity conversation;
  final List<MessageEntity> messages;
  final bool hasMore;
  final bool isLoadingMore;
  final Map<String, bool> typingUsers;

  const ChatMessagesLoaded({
    required this.conversation,
    required this.messages,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.typingUsers = const {},
  });

  @override
  List<Object?> get props => [
        conversation,
        messages,
        hasMore,
        isLoadingMore,
        typingUsers,
      ];

  ChatMessagesLoaded copyWith({
    ConversationEntity? conversation,
    List<MessageEntity>? messages,
    bool? hasMore,
    bool? isLoadingMore,
    Map<String, bool>? typingUsers,
  }) {
    return ChatMessagesLoaded(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      typingUsers: typingUsers ?? this.typingUsers,
    );
  }
}

/// Error state
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
