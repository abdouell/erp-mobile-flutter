import 'package:dio/dio.dart';
import 'dart:convert';
import '../core/constants/api_constants.dart';

/// Simple HTTP client for authentication operations (no circular dependencies)
class AuthHttpClient {
  late Dio _dio;
  
  AuthHttpClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.BASE_URL,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptor to log requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('DEBUG Dio Request: ${options.method} ${options.uri}');
        print('DEBUG Dio Headers: ${options.headers}');
        print('DEBUG Dio Data: ${options.data}');
        print('DEBUG Dio Data Type: ${options.data.runtimeType}');
        
        // If data is a Map, log each key-value pair
        if (options.data is Map) {
          final map = options.data as Map;
          map.forEach((key, value) {
            print('DEBUG Dio Data[$key]: "$value" (${value.runtimeType})');
          });
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('DEBUG Dio Response: ${response.statusCode}');
        print('DEBUG Dio Response Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('DEBUG Dio Error: ${error.message}');
        print('DEBUG Dio Error Response: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }
  
  /// POST request without authentication
  Future<Response> post(String path, {dynamic data}) async {
    print('DEBUG: AuthHttpClient POST to: $path');
    print('DEBUG: AuthHttpClient data: $data');
    print('DEBUG: AuthHttpClient data type: ${data.runtimeType}');
    
    // Explicitly encode to JSON string to ensure proper serialization
    final jsonString = jsonEncode(data);
    print('DEBUG: JSON encoded string: $jsonString');
    
    final response = await _dio.post(path, data: data);
    
    print('DEBUG: AuthHttpClient response status: ${response.statusCode}');
    print('DEBUG: AuthHttpClient response data: ${response.data}');
    
    return response;
  }
  
  /// GET request without authentication
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }
}
