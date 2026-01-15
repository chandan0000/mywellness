/// User Remote Data Source
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../data/models/models.dart';

/// Interface for remote user data operations
abstract class UserRemoteDataSource {
  Future<List<User>> getUsers();
  Future<User> getUserById(String userId);
  Future<List<User>> searchUsers(String query);
  Future<User> getCurrentUser();
}

/// Implementation of UserRemoteDataSource
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiService apiService;

  UserRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<User>> getUsers() async {
    final response = await apiService.get(ApiConstants.users);
    
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      
      // Handle both direct list and wrapped response
      List<dynamic> usersList;
      if (data is List) {
        usersList = data;
      } else if (data['detail'] is List) {
        usersList = data['detail'];
      } else if (data['users'] is List) {
        usersList = data['users'];
      } else {
        usersList = [];
      }
      
      return usersList
          .map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList();
    }
    
    throw Exception('Failed to fetch users');
  }

  @override
  Future<User> getUserById(String userId) async {
    final response = await apiService.get('${ApiConstants.users}/$userId');
    
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      final userData = data['detail'] ?? data;
      return User.fromJson(userData);
    }
    
    throw Exception('Failed to fetch user');
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    final response = await apiService.get(
      ApiConstants.users,
      queryParameters: {'search': query},
    );
    
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      List<dynamic> usersList;
      if (data is List) {
        usersList = data;
      } else if (data['detail'] is List) {
        usersList = data['detail'];
      } else {
        usersList = [];
      }
      
      return usersList
          .map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList();
    }
    
    throw Exception('Failed to search users');
  }

  @override
  Future<User> getCurrentUser() async {
    final response = await apiService.get(ApiConstants.currentUser);
    
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      return User.fromJson(data);
    }
    
    throw Exception('Failed to fetch current user');
  }
}
