/// Dio HTTP Client Service with Interceptors
/// 
/// Provides a configured Dio instance with:
/// - Token authentication
/// - Request/response logging
/// - Error handling
/// - Automatic token refresh
library;

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  String? _accessToken;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: ApiConstants.defaultHeaders,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Add logging in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (object) => print('[API] $object'),
      ),
    );
  }

  /// Get singleton instance
  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// Initialize with stored token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(StorageKeys.accessToken);
  }

  /// Set access token
  Future<void> setToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.accessToken, token);
  }

  /// Clear access token
  Future<void> clearToken() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.accessToken);
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _accessToken != null;

  /// Request interceptor - Add auth token
  void _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (_accessToken != null) {
      options.headers['Authorization'] = _accessToken;
    }
    handler.next(options);
  }

  /// Response interceptor - Handle success
  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  /// Error interceptor - Handle errors
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 - Unauthorized
    if (error.response?.statusCode == 401) {
      // Token expired or invalid - clear and redirect to login
      await clearToken();
      // The UI layer should handle navigation to login
    }
    
    handler.next(error);
  }

  // ===== HTTP Methods =====

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Upload file
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    void Function(int, int)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      if (additionalData != null) ...additionalData,
    });

    return _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
    );
  }
}

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['status'] == 'success' || json['success'] == true,
      data: json['detail'] != null && fromJsonT != null
          ? fromJsonT(json['detail'])
          : json['detail'],
      message: json['message'],
      statusCode: json['status_code'],
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      error: message,
      statusCode: statusCode,
    );
  }
}
