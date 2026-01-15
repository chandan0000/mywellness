/// Load Conversations Use Case
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

class LoadConversationsParams {
  final int page;
  final int pageSize;

  const LoadConversationsParams({this.page = 1, this.pageSize = 20});
}

class LoadConversationsUseCase
    implements UseCase<List<ConversationEntity>, LoadConversationsParams> {
  final ChatRepository repository;

  LoadConversationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ConversationEntity>>> call(
      LoadConversationsParams params) {
    return repository.loadConversations(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}
