/// Get Users Use Case
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../data/models/models.dart';
import '../repositories/user_repository.dart';

/// Use case for fetching all users
class GetUsersUseCase implements UseCase<List<User>, NoParams> {
  final UserRepository repository;

  GetUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(NoParams params) async {
    return await repository.getUsers();
  }
}
