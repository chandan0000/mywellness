/// Unit Tests for Login Use Case
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:opensocialapp/core/errors/failures.dart';
import 'package:opensocialapp/features/auth/domain/entities/user_entity.dart';
import 'package:opensocialapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:opensocialapp/features/auth/domain/usecases/login_usecase.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  final testUser = UserEntity(
    id: '1',
    fullName: 'Test User',
    email: testEmail,
    createdAt: DateTime(2024, 1, 1),
  );
  final testAuthResult = AuthResult(user: testUser, token: 'test_token');

  group('LoginUseCase', () {
    test('should return AuthResult when login is successful', () async {
      // Arrange
      when(mockRepository.login(any))
          .thenAnswer((_) async => Right(testAuthResult));

      // Act
      final result = await useCase(
        const LoginParams(email: testEmail, password: testPassword),
      );

      // Assert
      expect(result, Right(testAuthResult));
      verify(mockRepository.login(
        const LoginParams(email: testEmail, password: testPassword),
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when login fails', () async {
      // Arrange
      const failure = AuthFailure(message: 'Invalid credentials');
      when(mockRepository.login(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        const LoginParams(email: testEmail, password: testPassword),
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when no internet', () async {
      // Arrange
      const failure = NetworkFailure();
      when(mockRepository.login(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        const LoginParams(email: testEmail, password: testPassword),
      );

      // Assert
      expect(result, const Left(failure));
    });
  });
}
