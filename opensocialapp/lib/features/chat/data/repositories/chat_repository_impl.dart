/// Chat Repository Implementation - Data Layer
library;

import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/socket_service.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SocketService socketService;

  final _messageController = StreamController<MessageEntity>.broadcast();

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.socketService,
  }) {
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    socketService.messageStream.listen((data) {
      if (data['message'] != null) {
        final message = MessageModel.fromJson(data['message']);
        _messageController.add(message);
      }
    });
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>> loadConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final conversations = await remoteDataSource.getConversations(
          page: page,
          pageSize: pageSize,
        );
        await localDataSource.cacheConversations(conversations);
        return Right(conversations);
      } else {
        final cached = await localDataSource.getCachedConversations();
        return Right(cached);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> loadMessages(
      LoadMessagesParams params) async {
    try {
      if (await networkInfo.isConnected) {
        final messages = await remoteDataSource.getMessages(
          params.conversationId,
          page: params.page,
          pageSize: params.pageSize,
        );
        await localDataSource.cacheMessages(messages);
        return Right(messages);
      } else {
        final cached =
            await localDataSource.getCachedMessages(params.conversationId);
        return Right(cached);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
    SendMessageParams params,
    String currentUserId,
  ) async {
    try {
      // Create optimistic message
      final localId = DateTime.now().millisecondsSinceEpoch.toString();
      final optimisticMessage = MessageModel(
        id: localId,
        conversationId: params.conversationId,
        senderId: currentUserId,
        type: params.type,
        content: params.content,
        mediaUrl: params.mediaUrl,
        replyToId: params.replyToId,
        status: MessageStatus.sending,
        createdAt: DateTime.now(),
        localId: localId,
        isSynced: false,
      );

      // Cache optimistically
      await localDataSource.cacheMessage(optimisticMessage);

      // Send to server
      final serverMessage = await remoteDataSource.sendMessage(
        conversationId: params.conversationId,
        content: params.content,
        type: params.type.name,
        mediaUrl: params.mediaUrl,
        replyToId: params.replyToId,
      );

      // Send via socket for real-time
      socketService.sendMessage(
        conversationId: params.conversationId,
        message: serverMessage.toJson(),
        participantIds: [], // Will be handled by backend
      );

      return Right(serverMessage);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(
    String conversationId,
    List<String> messageIds,
  ) async {
    try {
      await remoteDataSource.markMessagesAsRead(conversationId, messageIds);
      socketService.sendReadReceipt(conversationId, messageIds);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<List<ConversationEntity>> getCachedConversations() async {
    return localDataSource.getCachedConversations();
  }

  @override
  Future<List<MessageEntity>> getCachedMessages(String conversationId) async {
    return localDataSource.getCachedMessages(conversationId);
  }

  @override
  void joinConversation(String conversationId) {
    socketService.joinConversation(conversationId);
  }

  @override
  void leaveConversation(String conversationId) {
    socketService.leaveConversation(conversationId);
  }

  @override
  void sendTyping(String conversationId, bool isTyping) {
    socketService.sendTyping(conversationId, isTyping);
  }

  @override
  Stream<MessageEntity> get messageStream => _messageController.stream;

  @override
  Stream<Map<String, dynamic>> get typingStream => socketService.typingStream;
}
