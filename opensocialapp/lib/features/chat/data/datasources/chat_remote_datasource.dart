/// Chat Remote Data Source
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations({int page = 1, int pageSize = 20});
  Future<List<MessageModel>> getMessages(String conversationId, {int page = 1, int pageSize = 50});
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    required String type,
    String? mediaUrl,
    String? replyToId,
  });
  Future<void> markMessagesAsRead(String conversationId, List<String> messageIds);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiService apiService;

  ChatRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<ConversationModel>> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await apiService.get(
      ApiConstants.conversations,
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    if (response.statusCode == 200 && response.data != null) {
      final detail = response.data['detail'] ?? response.data;
      final list = detail['conversations'] as List? ?? [];
      return list.map((c) => ConversationModel.fromJson(c)).toList();
    }

    throw Exception('Failed to load conversations');
  }

  @override
  Future<List<MessageModel>> getMessages(
    String conversationId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await apiService.get(
      ApiConstants.conversationMessages(conversationId),
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    if (response.statusCode == 200 && response.data != null) {
      final detail = response.data['detail'] ?? response.data;
      final list = detail['messages'] as List? ?? [];
      return list.map((m) => MessageModel.fromJson(m)).toList();
    }

    throw Exception('Failed to load messages');
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    required String type,
    String? mediaUrl,
    String? replyToId,
  }) async {
    final response = await apiService.post(
      ApiConstants.conversationMessages(conversationId),
      data: {
        'content': content,
        'type': type,
        if (mediaUrl != null) 'media_url': mediaUrl,
        if (replyToId != null) 'reply_to_id': replyToId,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final detail = response.data['detail'] ?? response.data;
      return MessageModel.fromJson(detail);
    }

    throw Exception('Failed to send message');
  }

  @override
  Future<void> markMessagesAsRead(
    String conversationId,
    List<String> messageIds,
  ) async {
    await apiService.post(
      ApiConstants.markMessagesRead(conversationId),
      data: {'message_ids': messageIds},
    );
  }
}
