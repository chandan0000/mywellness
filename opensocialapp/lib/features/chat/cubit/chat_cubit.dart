/// Chat Cubit for managing chat state (No Local DB)
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/models.dart';

// ===== Chat State =====

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<Conversation> conversations;
  final bool hasMore;

  const ConversationsLoaded({
    required this.conversations,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [conversations, hasMore];
}

class MessagesLoaded extends ChatState {
  final Conversation conversation;
  final List<Message> messages;
  final bool hasMore;
  final bool isLoadingMore;

  const MessagesLoaded({
    required this.conversation,
    required this.messages,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [conversation, messages, hasMore, isLoadingMore];

  MessagesLoaded copyWith({
    Conversation? conversation,
    List<Message>? messages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MessagesLoaded(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

// ===== Chat Cubit =====

class ChatCubit extends Cubit<ChatState> {
  final ApiService _apiService;
  final SocketService _socketService;
  final String _currentUserId;
  
  List<Conversation> _conversations = [];
  List<Message> _messages = [];
  Conversation? _currentConversation;

  ChatCubit({
    required String currentUserId,
    ApiService? apiService,
    SocketService? socketService,
  })  : _currentUserId = currentUserId,
        _apiService = apiService ?? ApiService.instance,
        _socketService = socketService ?? SocketService.instance,
        super(ChatInitial()) {
    _setupSocketListeners();
  }

  String get currentUserId => _currentUserId;
  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;

  // ===== Socket Event Listeners =====

  void _setupSocketListeners() {
    _socketService.messageStream.listen(_handleNewMessage);
    _socketService.typingStream.listen(_handleTyping);
    _socketService.readReceiptStream.listen(_handleReadReceipt);
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    final eventType = data['type'];
    
    // Handle sent confirmation (our own message was confirmed)
    if (eventType == 'sent_confirmation') {
      final messageId = data['message_id'];
      if (messageId != null && _currentConversation != null) {
        // Update message status to confirm it was sent
        _messages = _messages.map((m) {
          if (m.id == messageId) {
            return m.copyWith(status: MessageStatus.sent, isSynced: true);
          }
          return m;
        }).toList();
        
        emit(MessagesLoaded(
          conversation: _currentConversation!,
          messages: _messages,
        ));
      }
      return;
    }
    
    // Handle new message from other users
    if (eventType == 'notification' || data['message'] != null) {
      final messageData = data['message'] as Map<String, dynamic>?;
      if (messageData == null) return;
      
      final message = Message.fromJson(messageData);
      
      // Don't add our own messages again (we already added them optimistically)
      if (message.senderId == _currentUserId) return;
      
      // Add to current messages if in the same conversation
      if (_currentConversation?.id == message.conversationId) {
        // Check if message already exists
        final exists = _messages.any((m) => m.id == message.id);
        if (!exists) {
          _messages = [..._messages, message];
          emit(MessagesLoaded(
            conversation: _currentConversation!,
            messages: _messages,
          ));
          
          // Mark as delivered
          _socketService.sendDeliveryConfirmation(
            message.conversationId,
            [message.id],
          );
        }
      }
      
      // Update conversation list
      _updateConversationWithMessage(message);
    }
  }

  void _handleTyping(Map<String, dynamic> data) {
    // Handle typing indicator updates
  }

  void _handleReadReceipt(Map<String, dynamic> data) {
    final messageIds = (data['message_ids'] as List?)?.cast<String>() ?? [];
    if (messageIds.isEmpty) return;
    
    // Update message statuses
    _messages = _messages.map((m) {
      if (messageIds.contains(m.id)) {
        return m.copyWith(status: MessageStatus.read);
      }
      return m;
    }).toList();
    
    if (_currentConversation != null) {
      emit(MessagesLoaded(
        conversation: _currentConversation!,
        messages: _messages,
      ));
    }
  }

  void _updateConversationWithMessage(Message message) {
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
      
      if (state is! MessagesLoaded) {
        emit(ConversationsLoaded(conversations: _conversations));
      }
    }
  }

  // ===== Conversation Operations =====

  Future<void> loadConversations({int page = 1}) async {
    emit(ChatLoading());

    try {
      // Fetch from API directly (no local DB)
      final response = await _apiService.get(
        ApiConstants.conversations,
        queryParameters: {'page': page, 'page_size': 20},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final detail = data['detail'] ?? data;
        
        if (detail['conversations'] != null) {
          final conversationsList = (detail['conversations'] as List)
              .map((c) => Conversation.fromJson(c))
              .toList();
          
          _conversations = conversationsList;
          
          emit(ConversationsLoaded(
            conversations: _conversations,
            hasMore: detail['has_more'] ?? false,
          ));
        } else {
          // Empty conversations
          _conversations = [];
          emit(ConversationsLoaded(conversations: _conversations));
        }
      } else {
        emit(ChatError('Failed to load conversations'));
      }
    } catch (e) {
      emit(ChatError('Failed to load conversations: $e'));
    }
  }

  Future<void> createConversation({
    required List<String> participantIds,
    String? name,
    ConversationType type = ConversationType.individual,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.conversations,
        data: {
          'type': type.name,
          'participant_ids': participantIds,
          if (name != null) 'name': name,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await loadConversations();
      }
    } catch (e) {
      emit(ChatError('Failed to create conversation: $e'));
    }
  }

  // ===== Message Operations =====

  Future<void> loadMessages(Conversation conversation, {int page = 1}) async {
    _currentConversation = conversation;
    
    if (page == 1) {
      emit(ChatLoading());
    } else if (state is MessagesLoaded) {
      emit((state as MessagesLoaded).copyWith(isLoadingMore: true));
    }

    try {
      // Join socket room
      _socketService.joinConversation(conversation.id);
      
      // Fetch from API directly (no local DB)
      final response = await _apiService.get(
        ApiConstants.conversationMessages(conversation.id),
        queryParameters: {'page': page, 'page_size': 50},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final detail = data['detail'] ?? data;
        
        if (detail['messages'] != null) {
          final messagesList = (detail['messages'] as List)
              .map((m) => Message.fromJson(m))
              .toList();
          
          if (page == 1) {
            _messages = messagesList;
          } else {
            _messages = [...messagesList, ..._messages];
          }
          
          emit(MessagesLoaded(
            conversation: conversation,
            messages: _messages,
            hasMore: detail['has_more'] ?? false,
          ));
        } else {
          _messages = [];
          emit(MessagesLoaded(
            conversation: conversation,
            messages: _messages,
          ));
        }
      } else {
        emit(ChatError('Failed to load messages'));
      }
    } catch (e) {
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  Future<void> sendMessage({
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? replyToId,
  }) async {
    if (_currentConversation == null) return;

    try {
      // Create optimistic message with a local ID
      final localId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();
      
      final messageData = {
        'id': localId,
        'conversation_id': _currentConversation!.id,
        'sender_id': _currentUserId,
        'type': type.name,
        'content': content,
        'media_url': mediaUrl,
        'reply_to_id': replyToId,
        'status': 'sent',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'is_edited': false,
        'is_deleted': false,
      };
      
      final optimisticMessage = Message.fromJson(messageData);

      // Add to messages immediately for UI (optimistic update)
      _messages = [..._messages, optimisticMessage];
      emit(MessagesLoaded(
        conversation: _currentConversation!,
        messages: _messages,
      ));

      // Get participant IDs from conversation
      final participantIds = _currentConversation!.participants
          .map((p) => p.userId)
          .where((id) => id != _currentUserId)
          .toList();

      // Send via Socket.IO only (no REST API)
      _socketService.sendMessage(
        conversationId: _currentConversation!.id,
        message: messageData,
        participantIds: participantIds,
      );
      
      // The socket will respond with 'message_sent' event which is handled
      // in _handleNewMessage to confirm the message was sent
      
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  Future<void> markMessagesAsRead(List<String> messageIds) async {
    if (_currentConversation == null || messageIds.isEmpty) return;

    try {
      await _apiService.post(
        '${ApiConstants.conversationMessages(_currentConversation!.id)}/read',
        data: {'message_ids': messageIds},
      );
      
      _socketService.sendReadReceipt(_currentConversation!.id, messageIds);
      
      // Update local conversation unread count
      final index = _conversations.indexWhere(
        (c) => c.id == _currentConversation!.id,
      );
      if (index != -1) {
        final updated = _conversations[index].copyWith(unreadCount: 0);
        _conversations[index] = updated;
      }
    } catch (e) {
      // Silent fail for read receipts
    }
  }

  void sendTypingIndicator() {
    if (_currentConversation != null) {
      _socketService.sendTyping(_currentConversation!.id, true);
    }
  }

  /// Alias for leaveConversation for backward compatibility
  void leaveCurrentConversation() {
    leaveConversation();
  }

  /// Typing with explicit status
  void sendTyping(bool isTyping) {
    if (_currentConversation != null) {
      _socketService.sendTyping(_currentConversation!.id, isTyping);
    }
  }

  void leaveConversation() {
    if (_currentConversation != null) {
      _socketService.leaveConversation(_currentConversation!.id);
      _currentConversation = null;
      _messages = [];
    }
    
    if (_conversations.isNotEmpty) {
      emit(ConversationsLoaded(conversations: _conversations));
    } else {
      emit(ChatInitial());
    }
  }

  @override
  Future<void> close() {
    if (_currentConversation != null) {
      _socketService.leaveConversation(_currentConversation!.id);
    }
    return super.close();
  }
}
