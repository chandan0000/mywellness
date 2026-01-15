/// Chat Repository Interface - Domain Layer
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

/// Parameters for loading messages
class LoadMessagesParams {
  final String conversationId;
  final int page;
  final int pageSize;

  const LoadMessagesParams({
    required this.conversationId,
    this.page = 1,
    this.pageSize = 50,
  });
}

/// Parameters for sending a message
class SendMessageParams {
  final String conversationId;
  final String content;
  final MessageType type;
  final String? mediaUrl;
  final String? replyToId;

  const SendMessageParams({
    required this.conversationId,
    required this.content,
    this.type = MessageType.text,
    this.mediaUrl,
    this.replyToId,
  });
}

/// Abstract repository interface
abstract class ChatRepository {
  /// Load conversations with pagination
  Future<Either<Failure, List<ConversationEntity>>> loadConversations({
    int page = 1,
    int pageSize = 20,
  });

  /// Load messages for a conversation
  Future<Either<Failure, List<MessageEntity>>> loadMessages(LoadMessagesParams params);

  /// Send a message
  Future<Either<Failure, MessageEntity>> sendMessage(SendMessageParams params, String currentUserId);

  /// Mark messages as read
  Future<Either<Failure, void>> markMessagesAsRead(String conversationId, List<String> messageIds);

  /// Get cached conversations
  Future<List<ConversationEntity>> getCachedConversations();

  /// Get cached messages
  Future<List<MessageEntity>> getCachedMessages(String conversationId);

  /// Join conversation room (for real-time)
  void joinConversation(String conversationId);

  /// Leave conversation room
  void leaveConversation(String conversationId);

  /// Send typing indicator
  void sendTyping(String conversationId, bool isTyping);

  /// Stream of new messages (from socket)
  Stream<MessageEntity> get messageStream;

  /// Stream of typing indicators
  Stream<Map<String, dynamic>> get typingStream;
}
