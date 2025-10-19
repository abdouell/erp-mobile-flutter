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
  
  // Charger les données de tournée
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
      tourneeToday.value = tournee;
      
      if (tournee != null) {
        print('Tournée du jour: ${tournee.id} - ${tournee.statut}');
      } else {
        print('Pas de tournée aujourd\'hui');
      }
      
    } catch (e) {
      print('Erreur chargement tournée: $e');
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      
    } finally {
      isLoading.value = false;
    }
  }
  
  // Rafraîchir les données
  Future<void> refresh() async {
    await loadTourneeData();
  }
  
// Naviguer vers la liste des clients
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

/// Check-in client : démarrer une visite
Future<void> checkinClient(int clientTourneeId) async {
  try {
    // Récupérer position
    final locationService = Get.find<LocationService>();
    final position = await locationService.getCurrentPosition();
    
    // Appel API
    await _tourneeService.checkinCustomer(
      clientTourneeId,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );
    
    // Recharger automatiquement la tournée
    await refresh();
    
  } catch (e) {
    print('Erreur check-in: $e');
    rethrow;
  }
}

/// Checkout sans commande : terminer une visite sans commande
Future<void> checkoutWithoutOrder(
  int clientTourneeId,
  String motif,
  String? note,
) async {
  try {
    // Récupérer position
    final locationService = Get.find<LocationService>();
    final position = await locationService.getCurrentPosition();
    
    // Appel API
    await _tourneeService.checkoutCustomerWithoutOrder(
      clientTourneeId,
      motif,
      note,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );
    
    // Recharger automatiquement la tournée
    await refresh();
    
  } catch (e) {
    print('Erreur checkout sans commande: $e');
    rethrow;
  }
}

/// Clôturer la tournée
Future<void> cloturerTournee(int tourneeId) async {
  try {
    // Appel API
    await _tourneeService.clotureTournee(tourneeId);
    
    // Recharger automatiquement la tournée
    await refresh();
    
  } catch (e) {
    print('Erreur clôture tournée: $e');
    rethrow;
  }
}

}