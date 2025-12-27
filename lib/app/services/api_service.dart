import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/login_response.dart';
import '../../core/constants/api_constants.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class ApiService extends GetxService {
  late Dio _dio;
  Dio get dio => _dio;  
  
@override
void onInit() {
  super.onInit();
  
  _dio = Dio();
  _dio.options.baseUrl = ApiConstants.BASE_URL;
  _dio.options.connectTimeout = Duration(seconds: 30);
  _dio.options.receiveTimeout = Duration(seconds: 30);
  _dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json, text/plain', // Accept both JSON and plain text
  };
  
  // ✅ AJOUTEZ ICI l'intercepteur JWT
  _dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Récupérer le token depuis GetStorage
      final storage = GetStorage();
      final token = storage.read('auth_token');  // ← Même clé que dans AuthController
      
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      
      handler.next(options);
    },
    onError: (error, handler) {
      // Global error handling for all API calls
      _handleApiError(error);
      handler.next(error);
    },
  ));
}

void _handleApiError(DioException error) {
  String message = 'Une erreur est survenue';
  
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    message = 'Délai d\'attente dépassé';
  } else if (error.type == DioExceptionType.connectionError) {
    message = 'Problème de connexion';
  } else if (error.type == DioExceptionType.badResponse) {
    final statusCode = error.response?.statusCode;
    
    switch (statusCode) {
      case 400:
      case 422:
        message = 'Données invalides';
        break;
      case 401:
        message = 'Session expirée';
        _logoutAndRedirect();
        break;
      case 403:
        message = 'Accès non autorisé';
        break;
      case 404:
        message = 'Ressource non trouvée';
        break;
      case 500:
      case 502:
      case 503:
        message = 'Erreur serveur';
        break;
      default:
        message = 'Erreur serveur: $statusCode';
    }
  }
  
  // Show user-friendly message
  Get.snackbar(
    'Erreur',
    message,
    backgroundColor: Colors.red,
    colorText: Colors.white,
    duration: Duration(seconds: 3),
  );
}

void _logoutAndRedirect() {
  final storage = GetStorage();
  storage.remove('auth_token');
  storage.remove('user');
  Get.offAllNamed('/');
}
  
 Future<LoginResponse> login(String username, String password) async {
  try {
    final data = {
      'username': username,
      'password': password,
      'app': 'MOBILE'
    };
    
    // Create separate Dio instance just for login to handle plain text error responses
    final loginDio = Dio();
    loginDio.options.baseUrl = ApiConstants.BASE_URL;
    loginDio.options.connectTimeout = Duration(seconds: 30);
    loginDio.options.receiveTimeout = Duration(seconds: 30);
    loginDio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/plain',
    };
    loginDio.options.responseType = ResponseType.plain; // Only for login
    
    final response = await loginDio.post('/api/user/login', data: data);
    
    // Parse response manually
    String responseData = response.data.toString();
    
    if (responseData.contains('Invalid credentials')) {
      // This is an error response as plain text
      throw 'Identifiants invalides';
    } else if (responseData.contains('"token"')) {
      // This is a success response as JSON - parse it
      final jsonData = jsonDecode(responseData);
      return LoginResponse.fromJson(jsonData);
    } else {
      throw 'Erreur serveur: $responseData';
    }

  } on DioException catch (e) {
    // Handle login errors
    
    // Handle plain text error responses from backend
    if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
      // Backend returns plain text: "Invalid credentials"
      throw 'Identifiants invalides';
    } else if (e.response != null) {
      throw 'Erreur serveur: ${e.response?.statusCode}';
    } else {
      throw 'Erreur de connexion: Impossible de contacter le serveur';
    }
  } catch (e) {
    rethrow;
  }
}
}
