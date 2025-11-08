import 'package:erp_mobile/app/services/location_service.dart';
import 'package:get/get.dart';
import '../models/tournee.dart';
import '../models/vendeur.dart';
import '../models/user.dart';
import '../services/tournee_service.dart';
import 'auth_controller.dart';

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
        print('🔑 Utilisateur authentifié détecté, chargement tournée...');
        loadTourneeData();
      }
    });
    
    // ✅ Si déjà authentifié au démarrage
    if (_authController.isAuthenticated.value) {
      Future.delayed(Duration(milliseconds: 300), () {
        print('🔑 Déjà authentifié, chargement tournée...');
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
      
      print('=== CHARGEMENT TOURNEE DATA ===');
      
      // 1. Récupérer user connecté
      final User? currentUser = _authController.user.value;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      print('User connecté: ${currentUser.id}');
      
      // 2. Récupérer vendeur par userId
      final Vendeur vendeurData = await _tourneeService.getVendeurByUserId(currentUser.id);
      vendeur.value = vendeurData;
      
      print('Vendeur trouvé: ${vendeurData.nomComplet}');
      
      // 3. Récupérer tournée du jour
      final Tournee? tournee = await _tourneeService.getTourneeToday(vendeurData.id);
      tourneeToday.value = null; // Force un changement
      tourneeToday.value = tournee; // Réassignation
      
      if (tournee != null) {
        final statut = tournee.affectationStatut ?? 'PLANIFIEE';
        print('Tournée du jour: ${tournee.id} - $statut');
        print('  → ${tournee.nombreClients} clients');
        print('  → ${tournee.nombreTotalVisites} visites');
        print('  tourneeToday → ${tourneeToday.value?.nombreTotalVisites} visites');
        print('  → ${tournee.nombreCommandes} commandes');

                for (var client in tournee.clients) {
          print('  ┌─ Client ID=${client.id} - ${client.customerName}');
          print('  │  Statut: ${client.statutVisite}');
          print('  │  Nombre de visites: ${client.visites.length}');
          
          if (client.visites.isNotEmpty) {
            for (var i = 0; i < client.visites.length; i++) {
              final visite = client.visites[i];
              print('  │  ├─ Visite ${i + 1}:');
              print('  │  │  id: ${visite.id}');
              print('  │  │  statut: ${visite.statutVisite}');
              print('  │  │  checkin: ${visite.checkinAt}');
              print('  │  │  checkout: ${visite.checkoutAt}');
            }
          } else {
            print('  │  └─ Aucune visite');
          }
          print('  └─');
        }

      } else {
        print('Pas de tournée aujourd\'hui');
      }

        print('=== FINCHARGEMENT TOURNEE DATA ===');
      
    } catch (e) {
      print('Erreur chargement tournée: $e');
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      
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
      print('Navigation vers clients de la tournée: ${tourneeToday.value!.id}');
      
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
      print('🔄 Check-in client $clientTourneeId');
      
      // Récupérer position GPS
      final locationService = Get.find<LocationService>();
      final position = await locationService.getCurrentPosition();
      
      // Appel API - crée une nouvelle visite et fait le check-in
      final response = await _tourneeService.checkinCustomer(
        clientTourneeId,
        vendeur.value!.id,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
      
      print(' Check-in effectué, visiteId: ${response.visiteId}');
      
      // Recharger automatiquement la tournée pour avoir les données à jour
      await refresh();
      
      // DEBUG : Afficher TOUS les clients avec leurs visites
      print(' ========== DEBUG APRÈS REFRESH ==========');
      // 🔍 DEBUG : Afficher TOUS les clients avec leurs visites
      print('🔍 ========== DEBUG APRÈS REFRESH ==========');
      print('  tourneeToday existe: ${tourneeToday.value != null}');
      if (tourneeToday.value != null) {
        print('  Tournée ID: ${tourneeToday.value!.id}');
        print('  Nombre total de clients: ${tourneeToday.value!.clients.length}');
        print('  Nombre total de visites (tournée): ${tourneeToday.value!.nombreTotalVisites}');
        print('');
        print('  📋 DÉTAIL DE CHAQUE CLIENT:');
        
        for (var client in tourneeToday.value!.clients) {
          print('  ┌─ Client ID=${client.id} - ${client.customerName}');
          print('  │  Statut: ${client.statutVisite}');
          print('  │  Nombre de visites: ${client.visites.length}');
          
          if (client.visites.isNotEmpty) {
            for (var i = 0; i < client.visites.length; i++) {
              final visite = client.visites[i];
              print('  │  ├─ Visite ${i + 1}:');
              print('  │  │  id: ${visite.id}');
              print('  │  │  statut: ${visite.statutVisite}');
              print('  │  │  checkin: ${visite.checkinAt}');
              print('  │  │  checkout: ${visite.checkoutAt}');
            }
          } else {
            print('  │  └─ Aucune visite');
          }
          print('  └─');
        }
        
        print('');
        print('  🎯 Client recherché (ID=$clientTourneeId):');
        final targetClient = tourneeToday.value!.clients
            .firstWhereOrNull((c) => c.id == clientTourneeId);
        if (targetClient != null) {
          print('     ✅ TROUVÉ');
          print('     Visites: ${targetClient.visites.length}');
          print('     Statut: ${targetClient.statutVisite}');
        } else {
          print('     ❌ NON TROUVÉ');
        }
      }
      print('🔍 ==========================================');
      
      // ✅ IMPORTANT : Attendre que GetX propage la nouvelle valeur aux observateurs
      await Future.delayed(Duration(milliseconds: 100));
      
    } catch (e) {
      print('❌ Erreur check-in: $e');
      rethrow;
    }
  }

  /// Checkout avec commande : terminer une visite avec création de commande
  /// ⚠️ CHANGEMENT: Prend maintenant un visiteId au lieu de clientTourneeId
  Future<void> checkoutWithOrder(int visiteId) async {
    try {
      print('🛒 Check-out avec commande visite $visiteId');
      
      // Récupérer position GPS
      final locationService = Get.find<LocationService>();
      final position = await locationService.getCurrentPosition();
      
      // Appel API
      await _tourneeService.checkoutVisiteWithOrder(
        visiteId,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
      
      print('✅ Check-out avec commande effectué');
      
      // Recharger automatiquement la tournée
      await refresh();
      
    } catch (e) {
      print('❌ Erreur checkout avec commande: $e');
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
      print('🔄 Check-out sans vente visite $visiteId - Motif: $motif');
      
      // Récupérer position GPS
      final locationService = Get.find<LocationService>();
      final position = await locationService.getCurrentPosition();
      
      // Appel API
      await _tourneeService.checkoutVisiteWithoutOrder(
        visiteId,
        motif,
        note,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
      
      print('✅ Check-out sans vente effectué');
      
      // Recharger automatiquement la tournée
      await refresh();
      
    } catch (e) {
      print('❌ Erreur checkout sans commande: $e');
      rethrow;
    }
  }

  /// Clôturer la tournée
  Future<void> cloturerTournee(int tourneeId) async {
    try {
      print('🔒 Clôture tournée $tourneeId');
      
      // Appel API
      await _tourneeService.clotureTournee(tourneeId, vendeur.value!.id);
      
      print('✅ Tournée clôturée avec succès');
      
      // Recharger automatiquement la tournée
      await refresh();
      
    } catch (e) {
      print('❌ Erreur clôture tournée: $e');
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