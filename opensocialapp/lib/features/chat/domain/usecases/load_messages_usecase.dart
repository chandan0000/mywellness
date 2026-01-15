/// Load Messages Use Case
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class LoadMessagesUseCase
    implements UseCase<List<MessageEntity>, LoadMessagesParams> {
  final ChatRepository repository;

  LoadMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MessageEntity>>> call(LoadMessagesParams params) {
    return repository.loadMessages(params);
  }
}
