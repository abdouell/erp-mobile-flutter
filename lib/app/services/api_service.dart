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
    final data = {'username': username, 'password': password};
    final response = await _dio.post('/api/user/login', data: data);
    
    return LoginResponse.fromJson(response.data);
    
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      // Le 401 sera maintenant en Map aussi
      throw 'Identifiants invalides';
    } else {
      throw 'Erreur serveur: ${e.response?.statusCode}';
    }
  }
}

}
