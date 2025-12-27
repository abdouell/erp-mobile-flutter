import 'package:dio/dio.dart';
import 'package:erp_mobile/app/models/checkin_request.dart';
import 'package:erp_mobile/app/models/statut_visite.dart';
import 'package:get/get.dart';
import '../models/tournee.dart';
import '../models/vendeur.dart';
import '../models/client_tournee.dart';
import '../models/requests/checkout_request.dart';
import '../models/requests/visit_status_response.dart';
import 'api_service.dart';

class TourneeService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // ========================================
  // VENDEUR
  // ========================================

  /// Récupérer vendeur par userId
  Future<Vendeur> getVendeurByUserId(int userId) async {
    try {

      final response = await _apiService.dio.get('/api/vendeur/user/$userId');
      
      return Vendeur.fromJson(response.data);
      
    } on DioException catch (e) {
      
      if (e.response?.statusCode == 403) {
        throw Exception('Accès refusé : permissions insuffisantes');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Utilisateur non autorisé : pas de profil vendeur');
      } else {
        throw Exception('Erreur serveur lors de la récupération du vendeur');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // ========================================
  // TOURNÉE
  // ========================================

  /// Récupérer tournée du jour pour un vendeur
  Future<Tournee?> getTourneeToday(int vendeurId) async {
    try {

      final response = await _apiService.dio.get('/api/tournee/vendeur/$vendeurId/today');
      
      final List<dynamic> tourneesJson = response.data;
      
      if (tourneesJson.isEmpty) {
        return null;
      }
      
      final tournee = Tournee.fromJson(tourneesJson.first);

      return tournee;
      
    } on DioException catch (e) {
      throw Exception('Erreur lors de la récupération de la tournée');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Clôturer une tournée (affectation-aware)
  Future<void> clotureTournee(int tourneeId, int vendeurId) async {
    try {

      final response = await _apiService.dio.post(
        '/api/tournee/$tourneeId/cloture',
        queryParameters: {
          'vendeurId': vendeurId,
        },
      );
      
      return;
      
    } on DioException catch (e) {
      
      if (e.response?.statusCode == 404) {
        throw Exception('Tournée introuvable');
      } else if (e.response?.statusCode == 400) {
        // Gérer les erreurs métier
        final errorCode = e.response?.data['code'];
        if (errorCode == 'CLIENTS_IN_PROGRESS') {
          throw Exception('Des clients sont encore en cours de visite');
        } else if (errorCode == 'TOURNEE_ALREADY_CLOSED') {
          throw Exception('La tournée est déjà terminée');
        } else {
          throw Exception('Impossible de clôturer la tournée');
        }
      } else {
        throw Exception('Erreur serveur lors de la clôture');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // ========================================
  // GESTION DES VISITES
  // ========================================

  /// ✅ Check-in client (crée une nouvelle visite et fait le check-in)
  /// Endpoint: POST /api/tournee/client/{clientTourneeId}/checkin?vendeurId={id}
  /// Retourne: VisitStatusResponse avec le visiteId créé
  Future<VisitStatusResponse> checkinCustomer(
    int clientTourneeId,
    int vendeurId, 
    {double? latitude, double? longitude}
  ) async {
    try {
      
      final request = CheckinRequest(
        latitude: latitude,
        longitude: longitude,
        clientTimestamp: DateTime.now().toIso8601String(),
      );
      
      final response = await _apiService.dio.post(
        '/api/tournee/client/$clientTourneeId/checkin',
        queryParameters: {
          'vendeurId': vendeurId,
        },
        data: request.toJson(),
      );
      
      return VisitStatusResponse.fromJson(response.data);
      
    } on DioException catch (e) {
      
      if (e.response?.statusCode == 404) {
        throw Exception('Client de tournée introuvable');
      } else if (e.response?.statusCode == 400) {
        final code = e.response?.data is Map<String, dynamic>
            ? (e.response?.data['code'] as String?)
            : null;
        if (code == 'VENDEUR_ID_REQUIRED') {
          throw Exception('Identifiant vendeur manquant');
        } else if (code == 'AFFECTATION_NOT_FOUND') {
          throw Exception('Aucune affectation pour ce vendeur sur cette tournée aujourd\'hui');
        }
        throw Exception('Impossible de démarrer la visite dans l\'état actuel');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Accès refusé pour ce client');
      } else {
        throw Exception('Erreur serveur lors du check-in');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// ✅ Check-out avec commande (sur une visite existante)
  /// ⚠️ CHANGEMENT: Prend maintenant un visiteId au lieu de clientTourneeId
  /// Endpoint: POST /api/tournee/visite/{visiteId}/checkout-order
  Future<VisitStatusResponse> checkoutVisiteWithOrder(
    int visiteId,
    {double? latitude, double? longitude}
  ) async {
    try {
      
      final request = CheckoutRequest.withOrder(
        latitude: latitude,
        longitude: longitude,
      );
      
      final response = await _apiService.dio.post(
        '/api/tournee/visite/$visiteId/checkout-order',
        data: request.toJson(),
      );
      
      return VisitStatusResponse.fromJson(response.data);
      
    } on DioException catch (e) {
      
      if (e.response?.statusCode == 404) {
        throw Exception('Visite introuvable');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Impossible de terminer la visite dans l\'état actuel');
      } else {
        throw Exception('Erreur serveur lors du check-out');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// ✅ Check-out sans vente (avec motif)
  /// ⚠️ CHANGEMENT: Prend maintenant un visiteId au lieu de clientTourneeId
  /// Endpoint: POST /api/tournee/visite/{visiteId}/checkout-no-sale
  Future<VisitStatusResponse> checkoutVisiteWithoutOrder(
    int visiteId, 
    String motif, 
    String? note,
    {double? latitude, double? longitude}
  ) async {
    try {
      
      final request = CheckoutRequest.withoutSale(
        latitude: latitude,
        longitude: longitude,
        motif: motif,
        note: note,
      );
      
      final response = await _apiService.dio.post(
        '/api/tournee/visite/$visiteId/checkout-no-sale',
        data: request.toJson(),
      );
      
      return VisitStatusResponse.fromJson(response.data);
      
    } on DioException catch (e) {
      
      if (e.response?.statusCode == 404) {
        throw Exception('Visite introuvable');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Données invalides pour la clôture');
      } else {
        throw Exception('Erreur serveur lors de la clôture de visite');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// ✅ Obtenir le statut d'une visite
  /// ⚠️ CHANGEMENT: Prend maintenant un visiteId au lieu de clientTourneeId
  /// Endpoint: GET /api/tournee/visite/{visiteId}/status
  Future<VisitStatusResponse> getVisitStatus(int visiteId) async {
    try {
      
      final response = await _apiService.dio.get(
        '/api/tournee/visite/$visiteId/status',
      );
      
      return VisitStatusResponse.fromJson(response.data);
      
    } on DioException catch (e) {
      throw Exception('Erreur lors de la récupération du statut');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
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
