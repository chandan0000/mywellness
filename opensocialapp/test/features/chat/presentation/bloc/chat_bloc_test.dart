/// Chat Bloc Unit Tests
library;

import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:opensocialapp/core/errors/failures.dart';
import 'package:opensocialapp/core/services/socket_service.dart';
import 'package:opensocialapp/features/chat/domain/entities/conversation_entity.dart';
import 'package:opensocialapp/features/chat/domain/entities/message_entity.dart';
import 'package:opensocialapp/features/chat/domain/usecases/load_conversations_usecase.dart';
import 'package:opensocialapp/features/chat/domain/usecases/load_messages_usecase.dart';
import 'package:opensocialapp/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:opensocialapp/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:opensocialapp/features/chat/presentation/bloc/chat_event.dart';
import 'package:opensocialapp/features/chat/presentation/bloc/chat_state.dart';

import 'chat_bloc_test.mocks.dart';

@GenerateMocks([
  LoadConversationsUseCase,
  LoadMessagesUseCase,
  SendMessageUseCase,
  SocketService,
])
void main() {
  late ChatBloc bloc;
  late MockLoadConversationsUseCase mockLoadConversationsUseCase;
  late MockLoadMessagesUseCase mockLoadMessagesUseCase;
  late MockSendMessageUseCase mockSendMessageUseCase;
  late MockSocketService mockSocketService;

  final testConversation = ConversationEntity(
    id: '1',
    type: ConversationType.individual,
    createdAt: DateTime.now(),
  );

  final testMessages = [
    MessageEntity(
      id: '1',
      conversationId: '1',
      senderId: 'user1',
      type: MessageType.text,
      content: 'Hello',
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
    ),
  ];

  setUp(() {
    mockLoadConversationsUseCase = MockLoadConversationsUseCase();
    mockLoadMessagesUseCase = MockLoadMessagesUseCase();
    mockSendMessageUseCase = MockSendMessageUseCase();
    mockSocketService = MockSocketService();

    // Setup socket service mocks
    when(mockSocketService.messageStream)
        .thenAnswer((_) => const Stream.empty());
    when(mockSocketService.typingStream)
        .thenAnswer((_) => const Stream.empty());
    when(mockSocketService.readReceiptStream)
        .thenAnswer((_) => const Stream.empty());
    when(mockSocketService.joinConversation(any)).thenReturn(null);
    when(mockSocketService.leaveConversation(any)).thenReturn(null);

    bloc = ChatBloc(
      loadConversationsUseCase: mockLoadConversationsUseCase,
      loadMessagesUseCase: mockLoadMessagesUseCase,
      sendMessageUseCase: mockSendMessageUseCase,
      socketService: mockSocketService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ChatBloc', () {
    test('initial state is ChatInitial', () {
      expect(bloc.state, const ChatInitial());
    });

    blocTest<ChatBloc, ChatState>(
      'emits [ChatLoading, ChatConversationsLoaded] when load conversations succeeds',
      build: () {
        when(mockLoadConversationsUseCase(any))
            .thenAnswer((_) async => Right([testConversation]));
        return bloc;
      },
      act: (bloc) => bloc.add(const ChatLoadConversations()),
      expect: () => [
        const ChatLoading(),
        isA<ChatConversationsLoaded>(),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits [ChatLoading, ChatError] when load conversations fails',
      build: () {
        when(mockLoadConversationsUseCase(any)).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const ChatLoadConversations()),
      expect: () => [
        const ChatLoading(),
        const ChatError('Server error'),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'joins socket room when loading messages',
      build: () {
        when(mockLoadMessagesUseCase(any))
            .thenAnswer((_) async => Right(testMessages));
        return bloc;
      },
      act: (bloc) => bloc.add(ChatLoadMessages(conversation: testConversation)),
      verify: (_) {
        verify(mockSocketService.joinConversation('1')).called(1);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'emits [ChatLoading, ChatMessagesLoaded] when load messages succeeds',
      build: () {
        when(mockLoadMessagesUseCase(any))
            .thenAnswer((_) async => Right(testMessages));
        return bloc;
      },
      act: (bloc) => bloc.add(ChatLoadMessages(conversation: testConversation)),
      expect: () => [
        const ChatLoading(),
        isA<ChatMessagesLoaded>(),
      ],
    );
  });
}
