/// User Repository Implementation
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../data/models/models.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

/// Implementation of UserRepository
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<User>>> getUsers() async {
    try {
      final users = await remoteDataSource.getUsers();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(String userId) async {
    try {
      final user = await remoteDataSource.getUserById(userId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure( message: "Something went wrong", statusCode: 500));
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers(String query) async {
    try {
      final users = await remoteDataSource.searchUsers(query);
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(  message: "Something went wrong", statusCode: 500));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure( message: "Something went wrong", statusCode: 500));
    }
  }
}
