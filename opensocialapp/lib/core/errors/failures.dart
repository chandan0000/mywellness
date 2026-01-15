/// Core Failure Classes for Clean Error Handling
library;

import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server failures (API errors)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Cache failures (local database errors)
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Network failures (no internet)
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}
