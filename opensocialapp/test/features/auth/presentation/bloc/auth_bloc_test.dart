/// Auth Bloc Unit Tests
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:opensocialapp/core/errors/failures.dart';
import 'package:opensocialapp/core/usecases/usecase.dart';
import 'package:opensocialapp/features/auth/domain/entities/user_entity.dart';
import 'package:opensocialapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:opensocialapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:opensocialapp/features/auth/domain/usecases/register_usecase.dart';
import 'package:opensocialapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:opensocialapp/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:opensocialapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:opensocialapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:opensocialapp/features/auth/presentation/bloc/auth_state.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  LoginUseCase,
  RegisterUseCase,
  LogoutUseCase,
  CheckAuthUseCase,
])
void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockCheckAuthUseCase mockCheckAuthUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockCheckAuthUseCase = MockCheckAuthUseCase();

    bloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      checkAuthUseCase: mockCheckAuthUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testUser = UserEntity(
    id: '1',
    fullName: 'Test User',
    email: 'test@example.com',
    createdAt: DateTime(2024, 1, 1),
  );
  final testAuthResult = AuthResult(user: testUser, token: 'test_token');

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(bloc.state, const AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(mockLoginUseCase(any))
            .thenAnswer((_) async => Right(testAuthResult));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'test@example.com',
          password: 'password',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: testUser, token: 'test_token'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockLoginUseCase(any)).thenAnswer(
          (_) async => const Left(AuthFailure(message: 'Invalid credentials')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'test@example.com',
          password: 'wrong',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Invalid credentials'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when logout succeeds',
      build: () {
        when(mockLogoutUseCase(any))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthUnauthenticated(message: 'Logged out successfully'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when checkAuth finds session',
      build: () {
        when(mockCheckAuthUseCase(any))
            .thenAnswer((_) async => Right(testAuthResult));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: testUser, token: 'test_token'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no session found',
      build: () {
        when(mockCheckAuthUseCase(any))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}
