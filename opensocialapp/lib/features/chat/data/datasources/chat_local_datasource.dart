/// Chat Local Data Source
library;

import '../../../../core/services/database_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatLocalDataSource {
  Future<List<ConversationModel>> getCachedConversations();
  Future<void> cacheConversations(List<ConversationModel> conversations);
  Future<List<MessageModel>> getCachedMessages(String conversationId);
  Future<void> cacheMessages(List<MessageModel> messages);
  Future<void> cacheMessage(MessageModel message);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final DatabaseService databaseService;

  ChatLocalDataSourceImpl({required this.databaseService});

  @override
  Future<List<ConversationModel>> getCachedConversations() async {
    final data = await databaseService.getConversations();
    return data.map((c) => ConversationModel.fromJson(c)).toList();
  }

  @override
  Future<void> cacheConversations(List<ConversationModel> conversations) async {
    for (final conv in conversations) {
      await databaseService.upsertConversation(conv.toJson());
    }
  }

  @override
  Future<List<MessageModel>> getCachedMessages(String conversationId) async {
    final data = await databaseService.getMessages(conversationId);
    return data.map((m) => MessageModel.fromJson(m)).toList();
  }

  @override
  Future<void> cacheMessages(List<MessageModel> messages) async {
    await databaseService.insertMessages(
      messages.map((m) => m.toJson()).toList(),
    );
  }

  @override
  Future<void> cacheMessage(MessageModel message) async {
    await databaseService.insertMessage(message.toJson());
  }
}
