/// Dependency Injection Container
/// 
/// Registers all services, repositories, use cases, and blocs.
library;

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../core/network/network_info.dart';
import '../core/services/api_service.dart';
import '../core/services/socket_service.dart';
import '../core/services/database_service.dart';

// Auth Feature
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/check_auth_usecase.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

// Chat Feature
import '../features/chat/data/datasources/chat_local_datasource.dart';
import '../features/chat/data/datasources/chat_remote_datasource.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/domain/usecases/load_conversations_usecase.dart';
import '../features/chat/domain/usecases/load_messages_usecase.dart';
import '../features/chat/domain/usecases/send_message_usecase.dart';
import '../features/chat/presentation/bloc/chat_bloc.dart';

// Users Feature
import '../features/users/data/datasources/user_remote_datasource.dart';
import '../features/users/data/repositories/user_repository_impl.dart';
import '../features/users/domain/repositories/user_repository.dart';
import '../features/users/domain/usecases/get_users_usecase.dart';
import '../features/users/presentation/cubit/users_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => ApiService.instance);
  sl.registerLazySingleton(() => SocketService.instance);
  sl.registerLazySingleton(() => DatabaseService());

  //! Features - Auth
  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiService: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthUseCase: sl(),
    ),
  );

  //! Features - Chat
  // Data sources
  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(databaseService: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(apiService: sl()),
  );

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      socketService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoadConversationsUseCase(sl()));
  sl.registerLazySingleton(() => LoadMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => ChatBloc(
      loadConversationsUseCase: sl(),
      loadMessagesUseCase: sl(),
      sendMessageUseCase: sl(),
      socketService: sl(),
    ),
  );

  //! Features - Users
  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(apiService: sl()),
  );

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => UsersCubit(getUsersUseCase: sl()),
  );
}

