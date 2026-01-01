import 'package:dio/dio.dart';
import 'token_service.dart';
import 'auth_interceptor.dart';
import '../core/constants/api_constants.dart';

class ApiClient {
  late Dio _dio;
  final TokenService _tokenService = TokenService();
  final AuthInterceptor _authInterceptor = AuthInterceptor();
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.BASE_URL, // Use existing constant
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }
  
  /// Get headers with authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  /// Make GET request with automatic retry on 401
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _authInterceptor.executeWithAuth(() async {
      final headers = await _getHeaders();
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
      );
    });
  }
  
  /// Make POST request with automatic retry on 401
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _authInterceptor.executeWithAuth(() async {
      final headers = await _getHeaders();
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
      );
    });
  }
  
  /// Make PUT request with automatic retry on 401
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _authInterceptor.executeWithAuth(() async {
      final headers = await _getHeaders();
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
      );
    });
  }
  
  /// Make DELETE request with automatic retry on 401
  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _authInterceptor.executeWithAuth(() async {
      final headers = await _getHeaders();
      return await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
      );
    });
  }
  
  /// Get raw Dio instance for custom requests (without auth interceptor)
  Dio get dio => _dio;
}
