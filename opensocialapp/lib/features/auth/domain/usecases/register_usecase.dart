/// Register Use Case
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<AuthResult, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(RegisterParams params) {
    return repository.register(params);
  }
}
