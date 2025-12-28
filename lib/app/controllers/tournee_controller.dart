import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/tournee.dart';
import '../models/vendeur.dart';
import '../models/user.dart';
import '../services/tournee_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../exceptions/app_exceptions.dart';

class TourneeController extends GetxController {
  // Services
  final TourneeService _tourneeService = Get.find<TourneeService>();
  final AuthController _authController = Get.find<AuthController>();
  
  // États réactifs
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // Données
  final vendeur = Rxn<Vendeur>();
  final tourneeToday = Rxn<Tournee>();
  
  @override
  void onInit() {
    super.onInit();
   
    // ✅ Attendre que l'utilisateur soit authentifié
    ever(_authController.isAuthenticated, (authenticated) {
      if (authenticated) {
        loadTourneeData();
      }
    });
    
    // ✅ Si déjà authentifié au démarrage
    if (_authController.isAuthenticated.value) {
      Future.delayed(Duration(milliseconds: 300), () {
        loadTourneeData();
      });
    }
  }
  
  // ========================================
  // CHARGEMENT DES DONNÉES
  // ========================================
  
  /// Charger les données de tournée
  Future<void> loadTourneeData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // 1. Récupérer user connecté
      final User? currentUser = _authController.user.value;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      // 2. Récupérer vendeur par userId
      final Vendeur vendeurData = await _tourneeService.getVendeurByUserId(currentUser.id);
      vendeur.value = vendeurData;
      
      // 3. Récupérer tournée du jour
      final Tournee? tournee = await _tourneeService.getTourneeToday(vendeurData.id);
      tourneeToday.value = null; // Force un changement
      tourneeToday.value = tournee; // Réassignation
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue: ${e.toString().replaceAll('Exception: ', '')}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Rafraîchir les données
  Future<void> refresh() async {
    await loadTourneeData();
  }
  
  // ========================================
  // NAVIGATION
  // ========================================
  
  /// Naviguer vers la liste des clients
  void goToClients() {
    if (tourneeToday.value != null) {

      // ✅ Navigation avec données de la tournée
      Get.toNamed('/clients', arguments: {
        'tournee': tourneeToday.value,
        'vendeur': vendeur.value,
      });
    } else {
      Get.snackbar('Erreur', 'Aucune tournée sélectionnée');
    }
  }

  // ========================================
  // MÉTHODES MÉTIER POUR LA GESTION DES VISITES
  // ========================================

  /// Check-in client : démarrer une nouvelle visite pour un client
  /// Crée une nouvelle visite en base et fait le check-in
  /// Retourne le visiteId créé via VisitStatusResponse
  Future<void> checkinClient(int clientTourneeId) async {
    try {
      // Récupérer position GPS avec gestion d'erreur plateforme
      double? latitude;
      double? longitude;
      
      try {
        final locationService = Get.find<LocationService>();
        final position = await locationService.getCurrentPosition();
        latitude = position?.latitude;
        longitude = position?.longitude;
      } catch (e) {
        // Continue without GPS coordinates for unsupported platforms
        latitude = null;
        longitude = null;
      }
      
      // Appel API - crée une nouvelle visite et fait le check-in
      final response = await _tourneeService.checkinCustomer(
        clientTourneeId,
        vendeur.value!.id,
        latitude: latitude,
        longitude: longitude,
      );
      
      // Recharger automatiquement la tournée pour avoir les données à jour
      await refresh();
      
    } catch (e) {
      rethrow;
    }
  }

  /// Checkout avec commande : terminer une visite avec création de commande
  /// ⚠️ CHANGEMENT: Prend maintenant un visiteId au lieu de clientTourneeId
  Future<void> checkoutWithOrder(int visiteId) async {
    try {
      // Récupérer position GPS avec gestion d'erreur plateforme
      double? latitude;
      double? longitude;
      
      try {
        final locationService = Get.find<LocationService>();
        final position = await locationService.getCurrentPosition();
        latitude = position?.latitude;
        longitude = position?.longitude;
      } catch (e) {
        // Continue without GPS coordinates for unsupported platforms
        latitude = null;
        longitude = null;
      }
      
      // Appel API
      await _tourneeService.checkoutVisiteWithOrder(
        visiteId,
        latitude: latitude,
        longitude: longitude,
      );
      
      // Recharger automatiquement la tournée
      await refresh();
      
    } catch (e) {
      rethrow;
    }
  }

  /// Checkout sans commande : terminer une visite sans vente (avec motif)
  /// ⚠️ CHANGEMENT: Prend maintenant un visiteId au lieu de clientTourneeId
  Future<void> checkoutWithoutOrder(
    int visiteId,
    String motif,
    String? note,
  ) async {
    try {
      // Récupérer position GPS avec gestion d'erreur plateforme
      double? latitude;
      double? longitude;
      
      try {
        final locationService = Get.find<LocationService>();
        final position = await locationService.getCurrentPosition();
        latitude = position?.latitude;
        longitude = position?.longitude;
      } catch (e) {
        // Continue without GPS coordinates for unsupported platforms
        latitude = null;
        longitude = null;
      }
      
      // Appel API
      await _tourneeService.checkoutVisiteWithoutOrder(
        visiteId,
        motif,
        note,
        latitude: latitude,
        longitude: longitude,
      );
      
      // Recharger automatiquement la tournée
      await refresh();
      
    } catch (e) {
      rethrow;
    }
  }

  /// Clôturer la tournée
  Future<void> cloturerTournee(int tourneeId) async {
    try {
      if (vendeur.value == null) {
        throw Exception('Vendeur introuvable dans le contexte');
      }
      final int vendeurId = vendeur.value!.id;
      
      // Appel API
      await _tourneeService.clotureTournee(tourneeId, vendeurId);
      
      // Recharger automatiquement la tournée
      await refresh();
      
    } catch (e) {
      rethrow;
    }
  }

  // ========================================
  // MÉTHODES UTILITAIRES
  // ========================================

  /// Obtenir les statistiques de la tournée
  Map<String, dynamic> getTourneeStats() {
    if (tourneeToday.value == null) return {};
    
    final tournee = tourneeToday.value!;
    
    return {
      'nombreClients': tournee.nombreClients,
      'clientsVisites': tournee.clientsVisites,
      'clientsNonVisites': tournee.clientsNonVisites,
      'clientsEnCours': tournee.clientsEnCours,
      'clientsTermines': tournee.clientsTermines,
      'nombreTotalVisites': tournee.nombreTotalVisites,
      'nombreCommandes': tournee.nombreCommandes,
      'progressionPourcentage': tournee.progressionPourcentage,
      'tauxConversion': tournee.tauxConversion,
      'peutEtreCloturee': tournee.peutEtreCloturee,
    };
  }

  /// Vérifier si un client peut démarrer une visite
  bool canStartVisit(int clientTourneeId) {
    if (tourneeToday.value == null) return false;
    
    final client = tourneeToday.value!.clients
        .firstWhereOrNull((c) => c.id == clientTourneeId);
    
    if (client == null) return false;
    
    return _tourneeService.canStartVisit(client);
  }

  /// Vérifier si un client peut terminer sa visite
  bool canEndVisit(int clientTourneeId) {
    if (tourneeToday.value == null) return false;
    
    final client = tourneeToday.value!.clients
        .firstWhereOrNull((c) => c.id == clientTourneeId);
    
    if (client == null) return false;
    
    return _tourneeService.canEndVisit(client);
  }
}
