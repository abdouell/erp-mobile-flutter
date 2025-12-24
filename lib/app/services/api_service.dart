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
  _dio.options.headers = ApiConstants.HEADERS;
  
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
    final response = await _dio.post('/api/user/login', data: data);
    
    return LoginResponse.fromJson(response.data);
    
  } on DioException catch (e) {
    print('=== LOGIN ERROR DEBUG ===');
    print('Status Code: ${e.response?.statusCode}');
    print('Response Data: ${e.response?.data}');
    print('Error Type: ${e.type}');
    
    if (e.response?.statusCode == 401) {
      // Get error message from backend
      String errorMsg = e.response?.data?.toString() ?? '';
      print('Error Message: $errorMsg');
      
      if (errorMsg.contains('Access denied')) {
        throw 'Vous n\'avez pas accès à l\'application mobile';
      } else {
        throw 'Nom d\'utilisateur ou mot de passe incorrect';
      }
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
