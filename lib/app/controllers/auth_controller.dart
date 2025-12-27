import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user.dart';
import '../models/login_response.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  // Services
  final ApiService _apiService = Get.find<ApiService>();
  final _storage = GetStorage();
  
  // États réactifs
  final isLoading = false.obs;
  final isAuthenticated = false.obs;
  final user = Rxn<User>();
  
  // Champs du formulaire
  final username = ''.obs;
  final password = ''.obs;
  
  // Clés de stockage
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  
  @override
  void onInit() {
    super.onInit();
    _checkSavedAuth();
  }
  
  // Vérifier si utilisateur déjà connecté
  void _checkSavedAuth() {
    final token = _storage.read(_tokenKey);
    final userData = _storage.read(_userKey);
    
    if (token != null && userData != null) {
      try {
        user.value = User.fromJson(userData);
        isAuthenticated.value = true;
      } catch (e) {
        _clearAuth();
      }
    }
  }
  
  // Méthode de connexion
  Future<void> login() async {
  if (username.value.isEmpty || password.value.isEmpty) {
    Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
    return;
  }
  
  isLoading.value = true;
  
  try {

    final LoginResponse response = await _apiService.login(
      username.value.trim(),
      password.value,
    );
    
    // Succès
    await _storage.write(_tokenKey, response.token);
    await _storage.write(_userKey, response.user.toJson());
    
    user.value = response.user;
    isAuthenticated.value = true;

    Get.snackbar(
      'Connexion réussie',
      'Bienvenue ${response.user.displayName}',
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );

    Get.offAllNamed('/tournee');
    
  } catch (e) {
    // ✅ Affichage direct du message d'erreur
    Get.snackbar(
      'Erreur de connexion',
      e.toString(),  // Message direct sans "Exception: "
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: Duration(seconds: 3),
    );
    
  } finally {
    isLoading.value = false;
  }
}
  
  // Déconnexion
  Future<void> logout() async {
    await _clearAuth();
    Get.snackbar(
      'Déconnexion',
      'À bientôt !',
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
     Get.offAllNamed('/');
  }
  
  // Nettoyer authentification
  Future<void> _clearAuth() async {
    await _storage.remove(_tokenKey);
    await _storage.remove(_userKey);
    user.value = null;
    isAuthenticated.value = false;
    username.value = '';
    password.value = '';
  }
  
  // Récupérer token pour API calls futurs
  String? get token => _storage.read(_tokenKey);
}
