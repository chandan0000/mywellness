/// Base UseCase Abstract Class
library;

import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base use case that all use cases extend
/// [Type] is the return type
/// [Params] is the input parameters type
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this when the use case doesn't need any parameters
class NoParams {
  const NoParams();
}
