/// User Repository Interface
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../data/models/models.dart';

/// Abstract repository for user operations
abstract class UserRepository {
  /// Get all users (for starting new conversations)
  Future<Either<Failure, List<User>>> getUsers();
  
  /// Get a specific user by ID
  Future<Either<Failure, User>> getUserById(String userId);
  
  /// Search users by query
  Future<Either<Failure, List<User>>> searchUsers(String query);
  
  /// Get current user profile
  Future<Either<Failure, User>> getCurrentUser();
}
