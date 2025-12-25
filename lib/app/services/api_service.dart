import 'package:dio/dio.dart';
import 'package:get/get.dart';
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
  
  print('=== MAIN API SERVICE CONFIG ===');
  print('Response Type: ${_dio.options.responseType}');
  print('Base URL: ${_dio.options.baseUrl}');
  
  // ✅ AJOUTEZ ICI l'intercepteur JWT
  _dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Récupérer le token depuis GetStorage
      final storage = GetStorage();
      final token = storage.read('auth_token');  // ← Même clé que dans AuthController
      
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        print('❌ Pas de token JWT trouvé dans le storage !');
      }
      
      handler.next(options);
    },
    onError: (error, handler) {
      print('=== RESPONSE ERROR ===');
      print('Status: ${error.response?.statusCode}');
      print('Data: ${error.response?.data}');
      handler.next(error);
    },
  ));
  
  print('ApiService initialized with base URL: ${ApiConstants.BASE_URL}');
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
    print('=== LOGIN ERROR DEBUG ===');
    print('Status Code: ${e.response?.statusCode}');
    print('Response Data: ${e.response?.data}');
    print('Error Type: ${e.type}');
    
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
    print('Unexpected error: $e');
    rethrow;
  }
}
}
