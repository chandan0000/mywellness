/// Auth Repository Implementation - Data Layer
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AuthResult>> login(LoginParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.login(params.email, params.password);
      
      // Cache auth data
      await localDataSource.cacheAuthData(result.user, result.token);
      
      // Set token in API service
      await ApiService.instance.setToken(result.token);
      
      // Connect socket
      SocketService.instance.connect(result.user.id);

      return Right(AuthResult(user: result.user, token: result.token));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> register(RegisterParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.register(
        fullName: params.fullName,
        email: params.email,
        phoneNumber: params.phoneNumber,
        password: params.password,
      );
      
      // Cache auth data
      await localDataSource.cacheAuthData(result.user, result.token);
      
      // Set token in API service
      await ApiService.instance.setToken(result.token);
      
      // Connect socket
      SocketService.instance.connect(result.user.id);

      return Right(AuthResult(user: result.user, token: result.token));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Disconnect socket
      SocketService.instance.disconnect();
      
      // Clear API token
      await ApiService.instance.clearToken();
      
      // Clear local auth data
      await localDataSource.clearAuthData();

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult?>> checkAuth() async {
    try {
      final cached = await localDataSource.getCachedAuth();
      
      if (cached == null) {
        return const Right(null);
      }

      // Set token in API service
      await ApiService.instance.setToken(cached.token);
      
      // Connect socket
      SocketService.instance.connect(cached.user.id);

      return Right(AuthResult(user: cached.user, token: cached.token));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? profileUrl,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.updateProfile(
        fullName: fullName,
        profileUrl: profileUrl,
      );
      
      await localDataSource.updateCachedUser(user);

      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
