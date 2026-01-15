/// Auth Local Data Source
/// 
/// Handles local storage for authentication (SharedPreferences).
library;

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthData(UserModel user, String token);
  Future<CachedAuthData?> getCachedAuth();
  Future<void> clearAuthData();
  Future<void> updateCachedUser(UserModel user);
}

class CachedAuthData {
  final UserModel user;
  final String token;

  CachedAuthData({required this.user, required this.token});
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheAuthData(UserModel user, String token) async {
    await sharedPreferences.setString(StorageKeys.accessToken, token);
    await sharedPreferences.setString(StorageKeys.userId, user.id);
    await sharedPreferences.setString(StorageKeys.userName, user.fullName);
    await sharedPreferences.setString(StorageKeys.userEmail, user.email);
    if (user.profileUrl != null) {
      await sharedPreferences.setString(StorageKeys.userAvatar, user.profileUrl!);
    }
  }

  @override
  Future<CachedAuthData?> getCachedAuth() async {
    final token = sharedPreferences.getString(StorageKeys.accessToken);
    final userId = sharedPreferences.getString(StorageKeys.userId);

    if (token == null || userId == null) return null;

    final user = UserModel(
      id: userId,
      fullName: sharedPreferences.getString(StorageKeys.userName) ?? '',
      email: sharedPreferences.getString(StorageKeys.userEmail) ?? '',
      profileUrl: sharedPreferences.getString(StorageKeys.userAvatar),
      createdAt: DateTime.now(),
    );

    return CachedAuthData(user: user, token: token);
  }

  @override
  Future<void> clearAuthData() async {
    await sharedPreferences.remove(StorageKeys.accessToken);
    await sharedPreferences.remove(StorageKeys.userId);
    await sharedPreferences.remove(StorageKeys.userName);
    await sharedPreferences.remove(StorageKeys.userEmail);
    await sharedPreferences.remove(StorageKeys.userAvatar);
  }

  @override
  Future<void> updateCachedUser(UserModel user) async {
    await sharedPreferences.setString(StorageKeys.userName, user.fullName);
    if (user.profileUrl != null) {
      await sharedPreferences.setString(StorageKeys.userAvatar, user.profileUrl!);
    }
  }
}
