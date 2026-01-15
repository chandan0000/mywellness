/// Check Auth Use Case
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CheckAuthUseCase implements UseCase<AuthResult?, NoParams> {
  final AuthRepository repository;

  CheckAuthUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResult?>> call(NoParams params) {
    return repository.checkAuth();
  }
}
