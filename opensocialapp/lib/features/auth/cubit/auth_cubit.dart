/// Auth Cubit for managing authentication state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/models.dart';

// ===== Auth State =====

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final String token;

  const AuthAuthenticated({required this.user, required this.token});

  @override
  List<Object?> get props => [user, token];
}

class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ===== Auth Cubit =====

class AuthCubit extends Cubit<AuthState> {
  final ApiService _apiService;
  final SocketService _socketService;
  User? _currentUser;

  AuthCubit({
    ApiService? apiService,
    SocketService? socketService,
  })  : _apiService = apiService ?? ApiService.instance,
        _socketService = socketService ?? SocketService.instance,
        super(AuthInitial());

  User? get currentUser => _currentUser;

  /// Check if user is already authenticated
  Future<void> checkAuth() async {
    emit(AuthLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.accessToken);
      final userId = prefs.getString(StorageKeys.userId);
      final userName = prefs.getString(StorageKeys.userName);
      final userEmail = prefs.getString(StorageKeys.userEmail);

      if (token != null && userId != null) {
        // Restore user session
        await _apiService.setToken(token);
        
        _currentUser = User(
          id: userId,
          fullName: userName ?? '',
          email: userEmail ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Connect to socket
        _socketService.connect(userId);

        emit(AuthAuthenticated(user: _currentUser!, token: token));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to check authentication: $e'));
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        // Check for success response format from backend
        if (data['status'] == 'success' || data['detail'] != null) {
          final detail = data['detail'] ?? data;
          final token = detail['access_token'];
          final userId = detail['user_id']?.toString();
          final userEmail = detail['email'];

          if (token != null && userId != null) {
            // Save to preferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(StorageKeys.accessToken, token);
            await prefs.setString(StorageKeys.userId, userId);
            await prefs.setString(StorageKeys.userEmail, userEmail ?? email);

            // Set token in API service
            await _apiService.setToken(token);

            // Create user object
            _currentUser = User(
              id: userId,
              fullName: detail['full_name'] ?? '',
              email: userEmail ?? email,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            // Connect to socket
            _socketService.connect(userId);

            emit(AuthAuthenticated(user: _currentUser!, token: token));
            return;
          }
        }
        
        emit(const AuthError('Invalid response from server'));
      } else {
        final message = response.data?['detail'] ?? 'Login failed';
        emit(AuthError(message.toString()));
      }
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }

  /// Register new user
  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'full_name': fullName,
          'email': email,
          'phone_number': phoneNumber,
          'password': password,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        
        if (data['status'] == 'success' || data['detail'] != null) {
          // Auto-login after registration
          await login(email, password);
          return;
        }
        
        emit(const AuthError('Registration failed'));
      } else {
        final message = response.data?['detail'] ?? 'Registration failed';
        emit(AuthError(message.toString()));
      }
    } catch (e) {
      emit(AuthError('Registration failed: ${e.toString()}'));
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Disconnect socket
      _socketService.disconnect();

      // Clear API token
      await _apiService.clearToken();

      // Clear preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.accessToken);
      await prefs.remove(StorageKeys.userId);
      await prefs.remove(StorageKeys.userName);
      await prefs.remove(StorageKeys.userEmail);
      await prefs.remove(StorageKeys.userAvatar);

      _currentUser = null;

      emit(const AuthUnauthenticated(message: 'Logged out successfully'));
    } catch (e) {
      emit(AuthError('Logout failed: $e'));
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? profileUrl,
  }) async {
    if (_currentUser == null) return;

    try {
      final response = await _apiService.patch(
        ApiConstants.updateProfile,
        data: {
          if (fullName != null) 'full_name': fullName,
          if (profileUrl != null) 'profile_url': profileUrl,
        },
      );

      if (response.statusCode == 200) {
        _currentUser = _currentUser!.copyWith(
          fullName: fullName ?? _currentUser!.fullName,
          profileUrl: profileUrl ?? _currentUser!.profileUrl,
        );

        // Update stored name
        if (fullName != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(StorageKeys.userName, fullName);
        }

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(StorageKeys.accessToken) ?? '';
        emit(AuthAuthenticated(user: _currentUser!, token: token));
      }
    } catch (e) {
      emit(AuthError('Failed to update profile: $e'));
    }
  }
}
