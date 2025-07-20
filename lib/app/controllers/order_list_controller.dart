import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'auth_controller.dart';

class OrdersListController extends GetxController {
  // Services
  final OrderService _orderService = Get.find<OrderService>();
  final AuthController _authController = Get.find<AuthController>();
  
  // États réactifs
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // Données
  final allOrders = <Order>[].obs;
  final filteredOrders = <Order>[].obs;
  
  // Filtres
  final selectedStatus = Rxn<OrderStatus>();
  final searchQuery = ''.obs;
  final sortBy = 'date_desc'.obs; // date_desc, date_asc, total_desc, total_asc
  
  // Statistiques
  final totalOrders = 0.obs;
  final totalAmount = 0.0.obs;
  final draftCount = 0.obs;
  final validatedCount = 0.obs;
  // ✅ MVP: Pas de cancelledCount
  
  @override
  void onInit() {
    super.onInit();
    
    // Écouter les changements pour filtrer en temps réel
    debounce(searchQuery, _performSearch, time: Duration(milliseconds: 300));
    ever(selectedStatus, (_) => _applyFilters());
    ever(sortBy, (_) => _applyFilters());
    
    // Charger les données
    loadOrders();
  }
  
  /// 📊 CHARGER LES COMMANDES
  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      print('=== CHARGEMENT COMMANDES ===');
      
      final user = _authController.user.value;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      print('Chargement commandes pour user: ${user.id}');
      
      final orders = await _orderService.getUserOrders(user.id);
      
      allOrders.value = orders;
      _applyFilters();
      _updateStatistics();
      
      print('✅ ${orders.length} commandes chargées');
      
    } catch (e) {
      print('❌ Erreur chargement commandes: $e');
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 🔍 RECHERCHE ET FILTRES
  void _performSearch(String query) {
    print('🔍 Recherche: "$query"');
    _applyFilters();
  }
  
  void _applyFilters() {
    var filtered = allOrders.where((order) {
      // Filtre par statut
      final matchesStatus = selectedStatus.value == null || 
                           order.status == selectedStatus.value;
      
      // Filtre par recherche (ID, client, montant)
      final matchesSearch = searchQuery.value.isEmpty || 
                           order.id.toString().contains(searchQuery.value) ||
                           order.customerId.toString().contains(searchQuery.value) ||
                           order.totalAmount.toString().contains(searchQuery.value);
      
      return matchesStatus && matchesSearch;
    }).toList();
    
    // Tri
    switch (sortBy.value) {
      case 'date_desc':
        filtered.sort((a, b) => b.createdDate.compareTo(a.createdDate));
        break;
      case 'date_asc':
        filtered.sort((a, b) => a.createdDate.compareTo(b.createdDate));
        break;
      case 'total_desc':
        filtered.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'total_asc':
        filtered.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
    }
    
    filteredOrders.value = filtered;
    print('📝 ${filtered.length} commandes après filtres');
  }
  
  /// 📊 CALCUL STATISTIQUES
  void _updateStatistics() {
    totalOrders.value = allOrders.length;
    totalAmount.value = allOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
    
    draftCount.value = allOrders.where((o) => o.isDraft).length;
    validatedCount.value = allOrders.where((o) => o.isValidated).length;
    // ✅ MVP: Pas de cancelled count
    
    print('📊 Stats: ${totalOrders.value} commandes, ${totalAmount.value}€ total');
  }
  
  /// 🔄 RAFRAÎCHIR
  Future<void> refresh() async {
    await loadOrders();
  }
  
  /// 🎛️ ACTIONS DE FILTRE
  void setStatusFilter(OrderStatus? status) {
    selectedStatus.value = status;
  }
  
  void setSortBy(String sort) {
    sortBy.value = sort;
  }
  
  void updateSearch(String query) {
    searchQuery.value = query;
  }
  
  void clearFilters() {
    selectedStatus.value = null;
    searchQuery.value = '';
    sortBy.value = 'date_desc';
  }
  
  /// 📄 NAVIGATION VERS DÉTAILS - VERSION MVP SIMPLE
  void goToOrderDetails(Order order) {
    print('=== NAVIGATION VERS DÉTAILS ===');
    print('Commande: $order');
    print('ID: ${order.id}');
    
    // ✅ SIMPLE: Navigation avec ID dans l'URL
    if (order.id != null) {
      Get.toNamed('/order-details/${order.id}');
    } else {
      Get.snackbar(
        'Erreur',
        'Cette commande n\'a pas d\'ID valide',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // ✅ ACTIONS SUPPRIMÉES POUR MVP
  // Les commandes validées sont immutables - pas d'annulation possible
  
  /// 📱 HELPERS POUR L'UI
  String get statusFilterText {
    switch (selectedStatus.value) {
      case OrderStatus.DRAFT:
        return 'Brouillons';
      case OrderStatus.VALIDATED:
        return 'Validées';
      case OrderStatus.CANCELLED:
        return 'Annulées'; // Garde pour compatibilité mais non utilisé
      case null:
        return 'Toutes';
    }
  }
  
  String get sortText {
    switch (sortBy.value) {
      case 'date_desc':
        return 'Plus récentes';
      case 'date_asc':
        return 'Plus anciennes';
      case 'total_desc':
        return 'Montant décroissant';
      case 'total_asc':
        return 'Montant croissant';
      default:
        return 'Tri';
    }
  }
  
  bool get hasActiveFilters => 
      selectedStatus.value != null || 
      searchQuery.value.isNotEmpty || 
      sortBy.value != 'date_desc';
}