import 'package:dio/dio.dart';
import 'token_service.dart';
import 'auth_http_client.dart';
import '../models/auth_response.dart';
import '../models/user_dto.dart';
import '../exceptions/auth_exception.dart';
import '../core/constants/api_constants.dart';

class AuthService {
  final AuthHttpClient _httpClient = AuthHttpClient();
  final TokenService _tokenService = TokenService();
  late Dio _apiClient;
  
  AuthService() {
    _apiClient = Dio();
    _apiClient.options.baseUrl = ApiConstants.BASE_URL;
    _apiClient.options.connectTimeout = Duration(seconds: 30);
    _apiClient.options.receiveTimeout = Duration(seconds: 30);
    _apiClient.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  
  /// Login with email and password
  Future<UserDto> login(String email, String password) async {
    try {
      // Debug logging
      print('DEBUG: Attempting login with email: "$email"');
      print('DEBUG: Email is null: ${email == null}');
      print('DEBUG: Email is empty: ${email.isEmpty}');
      
      // Ensure email is never null
      final cleanEmail = email.trim();
      if (cleanEmail.isEmpty) {
        throw AuthException('Email/Username cannot be empty');
      }
      
      // Create login data - backend expects 'email' field but uses it as username
      final loginData = <String, String>{
        'email': cleanEmail,
        'password': password,
      };
      
      print('DEBUG: Login data map: $loginData');
      print('DEBUG: Login data keys: ${loginData.keys.toList()}');
      print('DEBUG: Login data values: ${loginData.values.toList()}');
      
      final response = await _httpClient.post(ApiConstants.LOGIN, data: loginData);
      
      print('DEBUG: Login response status: ${response.statusCode}');
      print('DEBUG: Login response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        
        // Save tokens securely
        await _tokenService.saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken,
        );
        
        // Return user data for UI (not persisted)
        return authResponse.user;
      } else {
        throw InvalidCredentialsException();
      }
    } on DioException catch (e) {
      print('DEBUG: DioException during login: ${e.message}');
      print('DEBUG: Response data: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw InvalidCredentialsException();
      } else {
        throw NetworkException(e.message ?? 'Unknown network error');
      }
    } catch (e) {
      print('DEBUG: General exception during login: ${e.toString()}');
      throw AuthException('Login failed: ${e.toString()}');
    }
  }
  
  /// Logout user (best effort + local cleanup)
  Future<void> logout() async {
    try {
      // Best effort: try to call backend logout
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.post('/api/auth/logout', data: {
          'refreshToken': refreshToken,
        });
      }
    } catch (e) {
      // Ignore backend logout errors - always clear local data
    } finally {
      // Always clear local tokens
      await _tokenService.clearTokens();
    }
  }
  
  /// Logout from all devices
  Future<void> logoutAll() async {
    try {
      await _apiClient.post('/api/auth/logout-all');
    } catch (e) {
      // Ignore errors - still clear local data
    } finally {
      await _tokenService.clearTokens();
    }
  }
  
  /// Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _apiClient.put('/api/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      
      if (response.statusCode != 200) {
        throw AuthException('Failed to change password');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw AuthException('Current password is incorrect');
      } else {
        throw NetworkException(e.message ?? 'Unknown network error');
      }
    } catch (e) {
      throw AuthException('Password change failed: ${e.toString()}');
    }
  }
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _tokenService.hasTokens();
  }
  
  /// Get current user info (from stored tokens)
  Future<UserDto?> getCurrentUser() async {
    // For MVP, we don't persist user data
    // This would need to be fetched from backend if needed
    return null;
  }
}
