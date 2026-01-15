/// Send Message Use Case
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCaseParams {
  final SendMessageParams messageParams;
  final String currentUserId;

  const SendMessageUseCaseParams({
    required this.messageParams,
    required this.currentUserId,
  });
}

class SendMessageUseCase
    implements UseCase<MessageEntity, SendMessageUseCaseParams> {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageUseCaseParams params) {
    return repository.sendMessage(params.messageParams, params.currentUserId);
  }
}
