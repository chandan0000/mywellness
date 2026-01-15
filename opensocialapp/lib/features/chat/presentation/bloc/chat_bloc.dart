/// Chat Bloc - Presentation Layer
library;

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/socket_service.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/load_conversations_usecase.dart';
import '../../domain/usecases/load_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final LoadConversationsUseCase loadConversationsUseCase;
  final LoadMessagesUseCase loadMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final SocketService socketService;

  String? _currentUserId;
  ConversationEntity? _currentConversation;
  List<ConversationEntity> _conversations = [];
  List<MessageEntity> _messages = [];

  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;

  ChatBloc({
    required this.loadConversationsUseCase,
    required this.loadMessagesUseCase,
    required this.sendMessageUseCase,
    required this.socketService,
  }) : super(const ChatInitial()) {
    on<ChatLoadConversations>(_onLoadConversations);
    on<ChatLoadMessages>(_onLoadMessages);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatMessageReceived>(_onMessageReceived);
    on<ChatMarkMessagesRead>(_onMarkMessagesRead);
    on<ChatSendTyping>(_onSendTyping);
    on<ChatTypingReceived>(_onTypingReceived);
    on<ChatLeaveConversation>(_onLeaveConversation);

    // Subscribe to real-time socket streams
    _initSocketListeners();
  }

  void _initSocketListeners() {
    // Listen for incoming messages
    _messageSubscription = socketService.messageStream.listen((data) {
      if (data['message'] != null) {
        final messageData = data['message'] as Map<String, dynamic>;
        // Import and use MessageModel here
        add(ChatMessageReceived(_parseMessage(messageData)));
      }
    });

    // Listen for typing indicators
    _typingSubscription = socketService.typingStream.listen((data) {
      final conversationId = data['conversation_id']?.toString() ?? '';
      final userId = data['user_id']?.toString() ?? '';
      final isTyping = data['is_typing'] == true;
      add(ChatTypingReceived(
        conversationId: conversationId,
        userId: userId,
        isTyping: isTyping,
      ));
    });

    // Listen for read receipts
    socketService.readReceiptStream.listen((data) {
      final messageIds = (data['message_ids'] as List?)?.cast<String>() ?? [];
      if (messageIds.isNotEmpty && state is ChatMessagesLoaded) {
        _updateMessageStatuses(messageIds);
      }
    });
  }

  MessageEntity _parseMessage(Map<String, dynamic> json) {
    return MessageEntity(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString(),
      type: _parseMessageType(json['type']),
      content: json['content'] ?? '',
      mediaUrl: json['media_url'],
      status: MessageStatus.sent,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image': return MessageType.image;
      case 'video': return MessageType.video;
      case 'audio': return MessageType.audio;
      default: return MessageType.text;
    }
  }

  void _updateMessageStatuses(List<String> messageIds) {
    _messages = _messages.map((m) {
      if (messageIds.contains(m.id)) {
        return m.copyWith(status: MessageStatus.read);
      }
      return m;
    }).toList();
    
    if (_currentConversation != null) {
      emit(ChatMessagesLoaded(
        conversation: _currentConversation!,
        messages: _messages,
      ));
    }
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> _onLoadConversations(
    ChatLoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    final result = await loadConversationsUseCase(
      LoadConversationsParams(page: event.page),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (conversations) {
        _conversations = conversations;
        emit(ChatConversationsLoaded(
          conversations: conversations,
          hasMore: conversations.length >= 20,
        ));
      },
    );
  }

  Future<void> _onLoadMessages(
    ChatLoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    _currentConversation = event.conversation;

    if (event.page == 1) {
      emit(const ChatLoading());
    } else if (state is ChatMessagesLoaded) {
      emit((state as ChatMessagesLoaded).copyWith(isLoadingMore: true));
    }

    // Join socket room
    socketService.joinConversation(event.conversation.id);

    final result = await loadMessagesUseCase(
      LoadMessagesParams(
        conversationId: event.conversation.id,
        page: event.page,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) {
        if (event.page == 1) {
          _messages = messages;
        } else {
          _messages = [...messages, ..._messages];
        }
        emit(ChatMessagesLoaded(
          conversation: event.conversation,
          messages: _messages,
          hasMore: messages.length >= 50,
        ));
      },
    );
  }

  Future<void> _onSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentConversation == null || _currentUserId == null) return;

    final params = SendMessageUseCaseParams(
      messageParams: SendMessageParams(
        conversationId: _currentConversation!.id,
        content: event.content,
        type: event.type,
        mediaUrl: event.mediaUrl,
        replyToId: event.replyToId,
      ),
      currentUserId: _currentUserId!,
    );

    final result = await sendMessageUseCase(params);

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (message) {
        _messages = [..._messages, message];
        emit(ChatMessagesLoaded(
          conversation: _currentConversation!,
          messages: _messages,
        ));
      },
    );
  }

  void _onMessageReceived(
    ChatMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    if (_currentConversation?.id == event.message.conversationId) {
      _messages = [..._messages, event.message];
      emit(ChatMessagesLoaded(
        conversation: _currentConversation!,
        messages: _messages,
      ));
    }

    // Update conversation list
    _updateConversationWithMessage(event.message);
    if (state is! ChatMessagesLoaded) {
      emit(ChatConversationsLoaded(conversations: _conversations));
    }
  }

  void _onMarkMessagesRead(
    ChatMarkMessagesRead event,
    Emitter<ChatState> emit,
  ) {
    if (_currentConversation != null) {
      socketService.sendReadReceipt(_currentConversation!.id, event.messageIds);
    }
  }

  void _onSendTyping(
    ChatSendTyping event,
    Emitter<ChatState> emit,
  ) {
    if (_currentConversation != null) {
      socketService.sendTyping(_currentConversation!.id, event.isTyping);
    }
  }

  void _onTypingReceived(
    ChatTypingReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;
      final typingUsers = Map<String, bool>.from(currentState.typingUsers);
      typingUsers[event.userId] = event.isTyping;
      emit(currentState.copyWith(typingUsers: typingUsers));
    }
  }

  void _onLeaveConversation(
    ChatLeaveConversation event,
    Emitter<ChatState> emit,
  ) {
    if (_currentConversation != null) {
      socketService.leaveConversation(_currentConversation!.id);
      _currentConversation = null;
      _messages = [];
    }
  }

  void _updateConversationWithMessage(MessageEntity message) {
    final index = _conversations.indexWhere(
      (c) => c.id == message.conversationId,
    );

    if (index != -1) {
      final conversation = _conversations[index];
      final updated = conversation.copyWith(
        lastMessage: message,
        lastMessageAt: message.createdAt,
        unreadCount: message.senderId != _currentUserId
            ? conversation.unreadCount + 1
            : conversation.unreadCount,
      );

      _conversations = [
        updated,
        ..._conversations.where((c) => c.id != message.conversationId),
      ];
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    if (_currentConversation != null) {
      socketService.leaveConversation(_currentConversation!.id);
    }
    return super.close();
  }
}
