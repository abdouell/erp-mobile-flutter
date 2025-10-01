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

  /// Récupérer vendeur par userId
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
  }
  
  /// Récupérer tournée du jour pour un vendeur
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

  /// Check-in client (début de visite)
  Future<VisitStatusResponse> checkinCustomer(int clientTourneeId, 
                                             {double? latitude, double? longitude}) async {
    try {
      print('🔄 Check-in client $clientTourneeId');
      if (latitude != null && longitude != null) {
        print('📍 Position GPS: $latitude, $longitude');
      }
      
      final request = CheckinRequest(
        latitude: latitude,
        longitude: longitude,
        clientTimestamp: DateTime.now().toIso8601String(),
      );
      
      final response = await _apiService.dio.post(
        '/api/tournee/client/$clientTourneeId/checkin',
        data: request.toJson(),
      );
      
      print('✅ Check-in effectué avec succès');
      return VisitStatusResponse.fromJson(response.data);
      
    } on DioException catch (e) {
      print('❌ Erreur Dio check-in: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Client de tournée introuvable');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Impossible de démarrer la visite dans l\'état actuel');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Accès refusé pour ce client');
      } else {
        throw Exception('Erreur serveur lors du check-in');
      }
    } catch (e) {
      print('❌ Erreur générale check-in: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Check-out avec commande
  Future<VisitStatusResponse> checkoutCustomerWithOrder(int clientTourneeId,
                                                       {double? latitude, double? longitude}) async {
    try {
      print('🛒 Check-out avec commande client $clientTourneeId');
      
      final request = CheckoutRequest.withOrder(
        latitude: latitude,
        longitude: longitude,
      );
      
      final response = await _apiService.dio.post(
        '/api/tournee/client/$clientTourneeId/checkout-order',
        data: request.toJson(),
      );
      
      print('✅ Check-out avec commande effectué');
      return VisitStatusResponse.fromJson(response.data);
      
    } on DioException catch (e) {
      print('❌ Erreur check-out commande: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Client de tournée introuvable');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Impossible de terminer la visite dans l\'état actuel');
      } else {
        throw Exception('Erreur serveur lors du check-out');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Check-out sans vente (avec motif)
  Future<VisitStatusResponse> checkoutCustomerWithoutOrder(int clientTourneeId, 
                                                          String motif, String? note,
                                                          {double? latitude, double? longitude}) async {
    try {
      print('🔄 Check-out sans vente client $clientTourneeId - Motif: $motif');
      
      final request = CheckoutRequest.withoutSale(
        latitude: latitude,
        longitude: longitude,
        motif: motif,
        note: note,
      );
      
      final response = await _apiService.dio.post(
        '/api/tournee/client/$clientTourneeId/checkout-no-sale',
        data: request.toJson(),
      );
      
      print('✅ Check-out sans vente effectué');
      return VisitStatusResponse.fromJson(response.data);
      
    } on DioException catch (e) {
      print('❌ Erreur check-out sans vente: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Client de tournée introuvable');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Données invalides pour la clôture');
      } else {
        throw Exception('Erreur serveur lors de la clôture de visite');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Obtenir le statut de visite d'un client
  Future<VisitStatusResponse> getVisitStatus(int clientTourneeId) async {
    try {
      print('📊 Récupération statut visite client $clientTourneeId');
      
      final response = await _apiService.dio.get(
        '/api/tournee/client/$clientTourneeId/status',
      );
      
      return VisitStatusResponse.fromJson(response.data);
      
    } on DioException catch (e) {
      print('❌ Erreur récupération statut: ${e.response?.statusCode}');
      throw Exception('Erreur lors de la récupération du statut');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Méthodes utilitaires pour la gestion des visites

  /// Vérifier si le client peut démarrer une visite
  bool canStartVisit(ClientTournee client) {
    return client.statutVisite.canTransitionTo(StatutVisite.VISITE_EN_COURS);
  }

  /// Vérifier si le client peut terminer une visite
  bool canEndVisit(ClientTournee client) {
    return client.isInProgress;
  }

  /// Calculer les statistiques d'une tournée
  Map<String, int> calculateTourneeStats(List<ClientTournee> clients) {
    return {
      'total': clients.length,
      'nonVisite': clients.where((c) => c.statutVisite == StatutVisite.NON_VISITE).length,
      'enCours': clients.where((c) => c.statutVisite == StatutVisite.VISITE_EN_COURS).length,
      'termine': clients.where((c) => c.statutVisite == StatutVisite.VISITE_TERMINEE).length,
      'commande': clients.where((c) => c.statutVisite == StatutVisite.COMMANDE_CREEE).length,
    };
  }

  /// Obtenir le pourcentage de progression
  double calculateProgressionPercentage(List<ClientTournee> clients) {
    if (clients.isEmpty) return 0.0;
    
    final visited = clients.where((c) => c.isVisited).length;
    return (visited / clients.length) * 100.0;
  }

  /// Obtenir le taux de conversion (commandes / visites terminées)
  double calculateConversionRate(List<ClientTournee> clients) {
    final completed = clients.where((c) => c.isCompleted).length;
    if (completed == 0) return 0.0;
    
    final withOrder = clients.where((c) => c.statutVisite == StatutVisite.COMMANDE_CREEE).length;
    return (withOrder / completed) * 100.0;
  }
}