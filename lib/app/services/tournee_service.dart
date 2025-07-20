import 'package:dio/dio.dart';
import 'package:erp_mobile/app/services/api_service.dart';
import 'package:get/get.dart';
import '../models/tournee.dart';
import '../models/vendeur.dart';


class TourneeService extends GetxService {
   final ApiService _apiService = Get.find<ApiService>();
  
  // Récupérer vendeur par userId
Future<Vendeur> getVendeurByUserId(int userId) async {
  try {
    print('=== DEBUG JWT ===');
    print('UserId: $userId');
    print('Headers Dio: ${_apiService.dio.options.headers}');
    
    final response = await _apiService.dio.get('/api/vendeur/user/$userId');
    
    print('Vendeur trouvé: ${response.data}');
    return Vendeur.fromJson(response.data);
    
  } on DioException catch (e) {
    print('Erreur Dio: ${e.response?.statusCode}');
    print('Response data: ${e.response?.data}');
    
    if (e.response?.statusCode == 403) {
      throw Exception('Accès refusé : permissions insuffisantes');
    } else if (e.response?.statusCode == 404) {
      throw Exception('Utilisateur non autorisé : pas de profil vendeur');
    } else {
      throw Exception('Erreur serveur lors de la récupération du vendeur');
    }
  } catch (e) {
    print('Erreur générale: $e');
    throw Exception('Erreur inattendue: $e');
  }
  // ✅ Plus besoin de return ici car tous les chemins throw ou return
}
  
  // Récupérer tournée du jour pour un vendeur
  Future<Tournee?> getTourneeToday(int vendeurId) async {
  try {
    print('Récupération tournée du jour pour vendeur: $vendeurId');
    
    final response = await _apiService.dio.get('/api/tournee/vendeur/$vendeurId/today');
    
    print('Réponse tournées: ${response.data}');
    
    final List<dynamic> tourneesJson = response.data;
    
    if (tourneesJson.isEmpty) {
      print('Aucune tournée aujourd\'hui');
      return null;
    }
    
    final tournee = Tournee.fromJson(tourneesJson.first);
    print('Tournée du jour trouvée: ${tournee.id}');
    
    return tournee;
    
  } on DioException catch (e) {
    print('Erreur récupération tournée: ${e.response?.statusCode}');
    throw Exception('Erreur lors de la récupération de la tournée');
  } catch (e) {
    print('Erreur générale tournée: $e');
    throw Exception('Erreur inattendue: $e');
  }
}

/// ✅ Marquer un client comme visité/non visité
Future<void> markCustomerAsVisited(int clientTourneeId, bool visite) async {
  try {
    print('📝 Marquage client $clientTourneeId comme ${visite ? "visité" : "non visité"}');
    
    final response = await _apiService.dio.put(
      '/api/tournee/client/$clientTourneeId/visite',
      queryParameters: {'visite': visite},
    );
    
    print('✅ Client marqué avec succès');
    print('Response status: ${response.statusCode}');
    
  } on DioException catch (e) {
    print('❌ Erreur Dio marquage client: ${e.response?.statusCode}');
    print('Response data: ${e.response?.data}');
    
    if (e.response?.statusCode == 404) {
      throw Exception('Client de tournée introuvable');
    } else if (e.response?.statusCode == 403) {
      throw Exception('Accès refusé pour modifier ce client');
    } else if (e.response?.statusCode == 400) {
      throw Exception('Données invalides pour le marquage');
    } else {
      throw Exception('Erreur serveur lors du marquage du client');
    }
  } catch (e) {
    print('❌ Erreur générale marquage: $e');
    throw Exception('Erreur inattendue: $e');
  }
}

}