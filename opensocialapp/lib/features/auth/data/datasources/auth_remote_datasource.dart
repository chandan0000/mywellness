/// Auth Remote Data Source
/// 
/// Handles API calls for authentication.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthRemoteResult> login(String email, String password);
  Future<AuthRemoteResult> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });
  Future<UserModel> updateProfile({String? fullName, String? profileUrl});
}

class AuthRemoteResult {
  final UserModel user;
  final String token;

  AuthRemoteResult({required this.user, required this.token});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<AuthRemoteResult> login(String email, String password) async {
    final response = await apiService.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      final detail = data['detail'] ?? data;
      
      final token = detail['access_token'] as String;
      final user = UserModel(
        id: detail['user_id']?.toString() ?? '',
        fullName: detail['full_name'] ?? '',
        email: detail['email'] ?? email,
        createdAt: DateTime.now(),
      );

      return AuthRemoteResult(user: user, token: token);
    }

    throw Exception(response.data?['detail'] ?? 'Login failed');
  }

  @override
  Future<AuthRemoteResult> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await apiService.post(
      ApiConstants.register,
      data: {
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Auto-login after registration
      return login(email, password);
    }

    throw Exception(response.data?['detail'] ?? 'Registration failed');
  }

  @override
  Future<UserModel> updateProfile({String? fullName, String? profileUrl}) async {
    final response = await apiService.patch(
      ApiConstants.updateProfile,
      data: {
        if (fullName != null) 'full_name': fullName,
        if (profileUrl != null) 'profile_url': profileUrl,
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data['detail'] ?? response.data);
    }

    throw Exception('Failed to update profile');
  }
}
