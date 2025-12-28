import 'package:get/get.dart';
import '../models/tournee.dart';
import '../models/vendeur.dart';
import '../models/visit_status_response.dart';
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
  /// Retourne: VisitStatusResponse avec le visiteId créé
  Future<VisitStatusResponse> checkinCustomer(
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
    
    return VisitStatusResponse.fromJson(response.data);
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
  Future<VisitStatusResponse> getVisitStatus(int visiteId) async {
    final response = await _apiService.dio.get('/api/tournee/visite/$visiteId/status');
    return VisitStatusResponse.fromJson(response.data);
  }

  // ========================================
  // MÉTHODES UTILITAIRES
  // ========================================

  /// Vérifier si le client peut démarrer une nouvelle visite
  /// Un client peut toujours démarrer une nouvelle visite si aucune n'est en cours
  bool canStartVisit(ClientTournee client) {
    // Pas de visite en cours = peut démarrer
    return !client.hasVisitInProgress;
  }

  /// Vérifier si le client peut terminer sa visite en cours
  bool canEndVisit(ClientTournee client) {
    return client.isInProgress;
  }

  /// Calculer les statistiques d'une tournée (basées sur les clients)
  Map<String, int> calculateTourneeStats(List<ClientTournee> clients) {
    return {
      'total': clients.length,
      'nonVisite': clients.where((c) => c.statutVisite == StatutVisite.NON_VISITE).length,
      'enCours': clients.where((c) => c.statutVisite == StatutVisite.VISITE_EN_COURS).length,
      'termine': clients.where((c) => c.statutVisite == StatutVisite.VISITE_TERMINEE).length,
      'commande': clients.where((c) => c.statutVisite == StatutVisite.COMMANDE_CREEE).length,
    };
  }

  /// Calculer les statistiques détaillées (incluant toutes les visites)
  Map<String, dynamic> calculateDetailedStats(List<ClientTournee> clients) {
    final totalVisites = clients.fold(0, (sum, c) => sum + c.visitCount);
    final totalCommandes = clients.fold(0, (sum, c) => sum + c.orderCount);
    
    return {
      'totalClients': clients.length,
      'totalVisites': totalVisites,
      'totalCommandes': totalCommandes,
      'clientsVisites': clients.where((c) => c.isVisited).length,
      'clientsEnCours': clients.where((c) => c.isInProgress).length,
      'clientsTermines': clients.where((c) => c.isCompleted).length,
      'clientsAvecCommande': clients.where((c) => c.hasOrderCreated).length,
    };
  }

  /// Obtenir le pourcentage de progression (clients visités)
  double calculateProgressionPercentage(List<ClientTournee> clients) {
    if (clients.isEmpty) return 0.0;
    
    final visited = clients.where((c) => c.isVisited).length;
    return (visited / clients.length) * 100.0;
  }

  /// Obtenir le taux de conversion (clients avec commande / clients visités)
  double calculateConversionRate(List<ClientTournee> clients) {
    final visited = clients.where((c) => c.isVisited).length;
    if (visited == 0) return 0.0;
    
    final withOrder = clients.where((c) => c.hasOrderCreated).length;
    return (withOrder / visited) * 100.0;
  }
}
