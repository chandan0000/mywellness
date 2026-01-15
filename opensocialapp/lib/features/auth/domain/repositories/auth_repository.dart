/// Auth Repository Interface - Domain Layer
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Parameters for login
class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

/// Parameters for registration
class RegisterParams {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });
}

/// Authentication result containing user and token
class AuthResult {
  final UserEntity user;
  final String token;

  const AuthResult({required this.user, required this.token});
}

/// Abstract repository interface - implemented in data layer
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, AuthResult>> login(LoginParams params);

  /// Register a new user
  Future<Either<Failure, AuthResult>> register(RegisterParams params);

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Check if user is authenticated
  Future<Either<Failure, AuthResult?>> checkAuth();

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? profileUrl,
  });
}
