import 'package:dio/dio.dart';
import 'token_service.dart';
import 'auth_http_client.dart';
import '../exceptions/auth_exception.dart';
import '../core/constants/api_constants.dart';

class AuthInterceptor {
  final TokenService _tokenService = TokenService();
  final AuthHttpClient _httpClient = AuthHttpClient();
  
  /// Execute request with automatic retry on 401
  Future<Response> executeWithAuth(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Try to refresh token
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry original request with new token
          return await request();
        } else {
          // Refresh failed → clear tokens and throw exception
          await _tokenService.clearTokens();
          throw AuthException('Session expired, please login again');
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Refresh access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _httpClient.post(
        ApiConstants.REFRESH,
        data: {'refreshToken': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        
        await _tokenService.saveTokens(accessToken, newRefreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Execute multiple requests with same auth context
  Future<List<Response>> executeMultipleWithAuth(
    List<Future<Response> Function()> requests,
  ) async {
    final results = <Response>[];
    
    for (final request in requests) {
      try {
        final response = await executeWithAuth(request);
        results.add(response);
      } catch (e) {
        // If one request fails, continue with others
        // You can modify this behavior based on your needs
        continue;
      }
    }
    
    return results;
  }
}
