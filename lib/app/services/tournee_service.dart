import 'package:get/get.dart';
import '../models/tournee.dart';
import '../models/vendeur.dart';
import '../exceptions/app_exceptions.dart';
import 'api_service.dart';

class TourneeService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // ========================================
  // VENDEUR
  // ========================================

  /// Récupérer vendeur par userId
  Future<Vendeur> getVendeurByUserId(int userId) async {
    final response = await _apiService.dio.get('/api/vendeur/user/$userId');
    return Vendeur.fromJson(response.data);
  }

  // ========================================
  // TOURNÉE
  // ========================================

  /// Récupérer tournée du jour pour un vendeur
  Future<Tournee?> getTourneeToday(int vendeurId) async {
    final response = await _apiService.dio.get('/api/tournee/vendeur/$vendeurId/today');
    
    final List<dynamic> tourneesJson = response.data;
    
    if (tourneesJson.isEmpty) {
      return null;
    }
    
    return Tournee.fromJson(tourneesJson.first);
  }

  /// Clôturer une tournée (affectation-aware)
  Future<void> clotureTournee(int tourneeId, int vendeurId) async {
    await _apiService.dio.post(
      '/api/tournee/$tourneeId/cloture',
      queryParameters: {
        'vendeurId': vendeurId,
      },
    );
  }

  // ========================================
  // GESTION DES VISITES
  // ========================================

  /// Check-in client (crée une nouvelle visite et fait le check-in)
  /// Endpoint: POST /api/tournee/client/{clientTourneeId}/checkin?vendeurId={id}
  Future<Map<String, dynamic>> checkinCustomer(
    int clientTourneeId,
    int vendeurId, {
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiService.dio.post(
      '/api/tournee/client/$clientTourneeId/checkin',
      queryParameters: {
        'vendeurId': vendeurId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    
    return response.data;
  }

  /// Check-out avec commande (sur une visite existante)
  /// Endpoint: POST /api/tournee/visite/{visiteId}/checkout-with-order
  Future<void> checkoutVisiteWithOrder(
    int visiteId, {
    double? latitude,
    double? longitude,
  }) async {
    await _apiService.dio.post(
      '/api/tournee/visite/$visiteId/checkout-with-order',
      queryParameters: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
  }

  /// Check-out sans vente (avec motif)
  /// Endpoint: POST /api/tournee/visite/{visiteId}/checkout-without-order
  Future<void> checkoutVisiteWithoutOrder(
    int visiteId,
    String motif,
    String? note, {
    double? latitude,
    double? longitude,
  }) async {
    await _apiService.dio.post(
      '/api/tournee/visite/$visiteId/checkout-without-order',
      data: {
        'motif': motif,
        if (note != null) 'note': note,
      },
      queryParameters: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
  }

  /// Obtenir le statut d'une visite
  /// Endpoint: GET /api/tournee/visite/{visiteId}/status
  Future<Map<String, dynamic>> getVisitStatus(int visiteId) async {
    final response = await _apiService.dio.get('/api/tournee/visite/$visiteId/status');
    return response.data;
  }
}
