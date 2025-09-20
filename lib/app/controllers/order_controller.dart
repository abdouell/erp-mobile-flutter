import 'package:erp_mobile/app/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/client_tournee.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';
import 'auth_controller.dart';

class OrderController extends GetxController {
  // Services
  final ProductService _productService = Get.find<ProductService>();
  final OrderService _orderService = Get.find<OrderService>();
  final AuthController _authController = Get.find<AuthController>();
  
  // États réactifs - LOADING
  final isLoadingProducts = false.obs;
  final isSavingOrder = false.obs;
  final isValidatingOrder = false.obs;
  
  // États réactifs - ERREURS
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // États réactifs - DONNÉES
  final allProducts = <Product>[].obs;
  final filteredProducts = <Product>[].obs;
  final categories = <String>[].obs;
  final selectedCategory = Rxn<String>();
  final searchQuery = ''.obs;
  
  // États réactifs - COMMANDE COURANTE
  final currentOrder = Rxn<Order>();
  final selectedClient = Rxn<ClientTournee>();
  
  // États réactifs - PANIER
  final cartItems = <OrderItem>[].obs;
  final cartTotal = 0.0.obs;
  final cartItemCount = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Écouter les changements de recherche pour filtrer en temps réel
    debounce(searchQuery, _performSearch, time: Duration(milliseconds: 300));
    
    // Écouter les changements de catégorie
    ever(selectedCategory, _filterByCategory);
    
    // Recalculer le total à chaque changement du panier
    ever(cartItems, (_) => _updateCartTotals());
  }
  
  /// 🚀 INITIALISATION - Appelée depuis la vue
  Future<void> initializeOrder(ClientTournee client) async {
    try {
      print('=== INITIALISATION COMMANDE ===');
      print('Client: ${client.customerName} (ID: ${client.customerId})');
      
      // Vérifications de sécurité
      if (client.customerId <= 0) {
        throw Exception('Client invalide: ID manquant');
      }
      
      selectedClient.value = client;
      
      // Créer nouvelle commande
      final user = _authController.user.value;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      print('📝 Création commande pour user ${user.id} et client ${client.customerId}');
      
      currentOrder.value = _orderService.createNewOrder(
        userId: user.id,
        customerId: client.customerId,
      );
      
      // Vider le panier précédent
      clearCart();
      
      // Charger les données produits
      await _loadInitialData();
      
      print('✅ Commande initialisée pour client ${client.customerName}');
      
    } catch (e) {
      print('❌ Erreur initialisation commande: $e');
      _handleError('Erreur initialisation commande', e);
    }
  }
  
  /// 📦 CHARGEMENT DONNÉES INITIALES
  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadProducts(),
      _loadCategories(),
    ]);
  }
  
  /// 📦 CHARGER PRODUITS
  Future<void> _loadProducts() async {
    try {
      isLoadingProducts.value = true;
      hasError.value = false;
      
      final products = await _productService.getAllProducts();
      allProducts.value = products;
      filteredProducts.value = products;
      
      print('✅ ${products.length} produits chargés');
      
    } catch (e) {
      _handleError('Erreur chargement produits', e);
    } finally {
      isLoadingProducts.value = false;
    }
  }
  
  /// 📂 CHARGER CATÉGORIES
  Future<void> _loadCategories() async {
    try {
      final categoryList = await _productService.getAvailableCategories();
      categories.value = categoryList;
      
      print('✅ ${categoryList.length} catégories chargées');
      
    } catch (e) {
      print('⚠️ Erreur chargement catégories: $e');
      // Non bloquant, on continue sans catégories
    }
  }
  
  /// 🔍 RECHERCHE PRODUITS
  void _performSearch(String query) {
    print('🔍 Recherche: "$query"');
    
    if (query.isEmpty && selectedCategory.value == null) {
      // Aucun filtre -> tous les produits
      filteredProducts.value = allProducts;
    } else {
      // Appliquer filtres combinés
      var filtered = allProducts.where((product) {
        final matchesSearch = query.isEmpty || product.matchesSearch(query);
        final matchesCategory = selectedCategory.value == null || 
                               product.productCategoryCode == selectedCategory.value;
        return matchesSearch && matchesCategory;
      }).toList();
      
      filteredProducts.value = filtered;
    }
    
    print('📝 Résultats filtrés: ${filteredProducts.length}');
  }
  
  /// 📂 FILTRER PAR CATÉGORIE
  void _filterByCategory(String? category) {
    print('📂 Filtre catégorie: $category');
    _performSearch(searchQuery.value); // Re-appliquer la recherche avec le nouveau filtre
  }
  
  /// 🛒 AJOUTER AU PANIER
  void addToCart(Product product, {int quantity = 1}) {
    try {
      print('🛒 Ajout panier: ${product.displayName} x$quantity');
      
      if (!product.isAvailable) {
        Get.snackbar('Produit indisponible', '${product.displayName} n\'est pas disponible');
        return;
      }
      
      final existingIndex = cartItems.indexWhere((item) => item.productId == product.id);
      
      if (existingIndex >= 0) {
        // Produit existe -> augmenter quantité
        final existingItem = cartItems[existingIndex];
        final newQuantity = existingItem.quantity + quantity;
        cartItems[existingIndex] = existingItem.updateQuantity(newQuantity);
        
        Get.snackbar(
          'Quantité mise à jour',
          '${product.displayName}: ${existingItem.quantity} → $newQuantity',
          duration: Duration(seconds: 1),
        );
      } else {
        // Nouveau produit
        final newItem = OrderItem.fromProduct(product, quantity);
        cartItems.add(newItem);
        
        Get.snackbar(
          'Produit ajouté',
          '${product.displayName} x$quantity',
          duration: Duration(seconds: 1),
        );
      }
      
      print('✅ Panier: ${cartItems.length} articles, total: ${cartTotal.value}€');
      
    } catch (e) {
      _handleError('Erreur ajout panier', e);
    }
  }
  
  /// 🛒 METTRE À JOUR QUANTITÉ
  void updateCartItemQuantity(int productId, int newQuantity) {
    try {
      if (newQuantity <= 0) {
        removeFromCart(productId);
        return;
      }
      
      final index = cartItems.indexWhere((item) => item.productId == productId);
      if (index >= 0) {
        cartItems[index] = cartItems[index].updateQuantity(newQuantity);
        print('✅ Quantité mise à jour: produit $productId → $newQuantity');
      }
      
    } catch (e) {
      _handleError('Erreur mise à jour quantité', e);
    }
  }
  
  /// 🛒 SUPPRIMER DU PANIER
  void removeFromCart(int productId) {
    try {
      final removedItem = cartItems.firstWhereOrNull((item) => item.productId == productId);
      cartItems.removeWhere((item) => item.productId == productId);
      
      if (removedItem != null) {
        Get.snackbar(
          'Produit retiré',
          removedItem.productName,
          duration: Duration(seconds: 1),
        );
        print('✅ Produit retiré: ${removedItem.productName}');
      }
      
    } catch (e) {
      _handleError('Erreur suppression panier', e);
    }
  }
  
  
  /// 🛒 CALCUL TOTAUX PANIER
  void _updateCartTotals() {
    cartItemCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
    cartTotal.value = cartItems.fold(0.0, (sum, item) => sum + item.subtotalAfterDiscount);
  }
  
  /// 💾 SAUVEGARDER COMMANDE (BROUILLON)
  Future<void> saveOrderAsDraft() async {
    try {
      if (!_canSaveOrder()) return;
      
      isSavingOrder.value = true;
      
      // Mettre à jour la commande avec les items du panier
      final updatedOrder = currentOrder.value!.copyWith(
        orderDetails: cartItems.toList(),
        totalAmount: cartTotal.value,
      );
      
      await _orderService.saveOrder(updatedOrder);
      
      Get.snackbar(
        'Brouillon sauvegardé',
        'Commande sauvegardée avec succès',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
      
      print('✅ Commande sauvegardée en brouillon');
      
    } catch (e) {
      _handleError('Erreur sauvegarde', e);
    } finally {
      isSavingOrder.value = false;
    }
  }
  
/// ✅ VALIDER COMMANDE
Future<void> validateOrder() async {
  try {
    print('🔄 === VALIDATION COMMANDE ===');
    
    if (!_canValidateOrder()) {
      print('❌ Validation impossible');
      return;
    }
    
    // Dialogue de validation avec commentaire
    final validationResult = await _showValidationDialogWithComment();
    if (validationResult == null || !validationResult['confirmed']) {
      print('❌ Validation annulée par l\'utilisateur');
      return;
    }
    
    final String? orderComment = validationResult['comment'];
    
    isValidatingOrder.value = true;
    print('🔄 Début validation...');

    // ✅ NOUVEAU : Récupérer la géolocalisation
    print('📍 Récupération position GPS...');
    final locationService = Get.find<LocationService>();
    final position = await locationService.getCurrentPosition();
    
    double? latitude = position?.latitude;
    double? longitude = position?.longitude;
    
    if (position == null) {
      print('⚠️ Impossible de récupérer la position GPS, continuation sans géolocalisation');
    } else {
      print('✅ Position GPS récupérée: $latitude, $longitude');
    }
    
    // Créer la commande finale avec le commentaire
    final finalOrder = currentOrder.value!.copyWith(
      orderDetails: cartItems.toList(),
      totalAmount: cartTotal.value,
      status: OrderStatus.VALIDATED,
      comment: orderComment?.trim().isEmpty == true ? null : orderComment?.trim(),
      latitude: latitude,    // ✅ NOUVEAU
      longitude: longitude,  // ✅ NOUVEAU
    );
    
    print('💾 Commande à valider: $finalOrder');
    print('💬 Commentaire: "${finalOrder.comment}"');
    
    // CHANGEMENT: Appel direct sans try/catch interne
    Order savedOrder = await _orderService.saveOrder(
      finalOrder, 
      clientTourneeId: selectedClient.value?.id
    );
    
    print('✅ Sauvegarde serveur réussie: $savedOrder');
    
    // SEULEMENT EN CAS DE SUCCÈS: mettre à jour la commande locale
    currentOrder.value = savedOrder;
    print('✅ Commande locale mise à jour avec ID: ${savedOrder.id}');
    
    // SEULEMENT EN CAS DE SUCCÈS: vider le panier
    print('🗑️ Vidage du panier après succès...');
    clearCart();
    
    // SEULEMENT EN CAS DE SUCCÈS: message de succès
    Get.snackbar(
      'Commande validée ! 🎉',
      'Commande #${savedOrder.id} validée avec succès',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
      duration: Duration(seconds: 3),
    );
    
    // SEULEMENT EN CAS DE SUCCÈS: navigation
    print('🧭 Navigation vers confirmation...');
    Get.toNamed('/order-confirmation', arguments: {
      'order': savedOrder,
      'client': selectedClient.value,
    });
    
    print('✅ === FIN VALIDATION COMMANDE ===');
    
  } catch (e) {
    print('❌ Erreur validation: $e');
    
    // CHANGEMENT: Messages d'erreur détaillés selon le type
    String errorTitle;
    String errorMessage;
    
    if (e.toString().contains('serveur a retourné une réponse vide')) {
      errorTitle = 'Erreur de sauvegarde';
      errorMessage = 'Le serveur n\'a pas confirmé la sauvegarde. Vos données sont conservées, vous pouvez réessayer.';
    } else if (e.toString().contains('Données de commande invalides')) {
      errorTitle = 'Données invalides';
      errorMessage = 'Les informations de la commande sont incorrectes. Vérifiez votre saisie et réessayez.';
    } else if (e.toString().contains('Erreur serveur interne') || e.toString().contains('Code: 500')) {
      errorTitle = 'Problème serveur';
      errorMessage = 'Le serveur rencontre un problème technique. Votre commande est conservée, réessayez dans quelques minutes.';
    } else if (e.toString().contains('temporairement indisponible') || e.toString().contains('Code: 503')) {
      errorTitle = 'Service indisponible';
      errorMessage = 'Le service est temporairement indisponible. Votre commande est conservée, réessayez plus tard.';
    } else if (e.toString().contains('Accès refusé') || e.toString().contains('Code: 403')) {
      errorTitle = 'Accès refusé';
      errorMessage = 'Vous n\'avez pas les permissions nécessaires. Contactez votre administrateur.';
    } else if (e.toString().contains('communication') || e.toString().contains('network')) {
      errorTitle = 'Problème de connexion';
      errorMessage = 'Impossible de contacter le serveur. Vérifiez votre connexion internet et réessayez.';
    } else {
      errorTitle = 'Erreur de validation';
      errorMessage = 'Une erreur s\'est produite. Votre commande est conservée, vous pouvez réessayer.';
    }
    
    // CHANGEMENT: Snackbar d'erreur plus visible
    Get.snackbar(
      errorTitle,
      errorMessage,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      icon: Icon(Icons.error_outline, color: Colors.white),
      duration: Duration(seconds: 6),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      shouldIconPulse: true,
    );
    
    // IMPORTANT: NE PAS vider le panier en cas d'erreur
    // L'utilisateur garde sa commande et peut réessayer
    
  } finally {
    isValidatingOrder.value = false;
  }
}

/// 💬 DIALOGUE VALIDATION AVEC COMMENTAIRE
Future<Map<String, dynamic>?> _showValidationDialogWithComment() async {
  final TextEditingController commentController = TextEditingController();
  
  return await Get.dialog<Map<String, dynamic>>(
    AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green),
          SizedBox(width: 8),
          Text('Valider la commande'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Récapitulatif de la commande
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Récapitulatif',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Client: ${selectedClient.value?.customerName}'),
                  Text('Produits: ${cartItems.length}'),
                  Text('Articles: ${cartItemCount.value}'),
                  Text('Total: ${cartTotal.value.toStringAsFixed(2)} €'),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // ✅ Section commentaire
            Text(
              'Commentaire (optionnel)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: commentController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Ajouter un commentaire à cette commande...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            
            SizedBox(height: 8),
            
            // ✅ Message de confirmation
            Text(
              'Confirmer la validation de cette commande ?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Bouton Annuler
        TextButton(
          onPressed: () {
            commentController.dispose();
            Get.back(result: {'confirmed': false});
          },
          child: Text('Annuler'),
        ),
        
        // Bouton Valider
        ElevatedButton.icon(
          onPressed: () {
            final comment = commentController.text.trim();
            commentController.dispose();
            Get.back(result: {
              'confirmed': true,
              'comment': comment,
            });
          },
          icon: Icon(Icons.check),
          label: Text('Valider'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}

/// 🛒 VIDER LE PANIER - Version améliorée
void clearCart() {
  print('🗑️ === VIDAGE PANIER ===');
  print('Avant: ${cartItems.length} articles, ${cartTotal.value}€');
  
  cartItems.clear();
  cartTotal.value = 0.0;
  cartItemCount.value = 0;
  
  cartItems.refresh();
  cartTotal.refresh();
  cartItemCount.refresh();
  
  print('Après: ${cartItems.length} articles, ${cartTotal.value}€');
  print('✅ === PANIER VIDÉ ===');
}

  /// 🧹 NETTOYAGE
  void clearOrder() {
    currentOrder.value = null;
    selectedClient.value = null;
    clearCart();
    searchQuery.value = '';
    selectedCategory.value = null;
    filteredProducts.value = allProducts;
    hasError.value = false;
    
    print('🧹 Session commande nettoyée');
  }
  
  /// 🔄 REFRESH DONNÉES
  Future<void> refresh() async {
    _productService.clearCache();
    await _loadInitialData();
  }
  
  /// 📂 CHANGER CATÉGORIE
  void selectCategory(String? category) {
    selectedCategory.value = category;
  }
  
  /// 🔍 METTRE À JOUR RECHERCHE
  void updateSearch(String query) {
    searchQuery.value = query;
  }
  
  /// 🛒 HELPERS PANIER
  int getProductQuantityInCart(int productId) {
    final item = cartItems.firstWhereOrNull((item) => item.productId == productId);
    return item?.quantity ?? 0;
  }
  
  /// ✅ VALIDATIONS
  bool _canSaveOrder() {
    if (currentOrder.value == null) {
      Get.snackbar('Erreur', 'Aucune commande en cours');
      return false;
    }
    
    if (cartItems.isEmpty) {
      Get.snackbar('Panier vide', 'Ajoutez des produits avant de sauvegarder');
      return false;
    }
    
    return true;
  }
  
  bool _canValidateOrder() {
  if (currentOrder.value == null) {
    Get.snackbar('Erreur', 'Aucune commande en cours');
    return false;
  }
  
  if (cartItems.isEmpty) {
    Get.snackbar('Panier vide', 'Ajoutez des produits avant de valider');
    return false;
  }
  
  return true;
}
  
  
  
  /// ❌ GESTION ERREURS
  void _handleError(String title, dynamic error) {
    hasError.value = true;
    errorMessage.value = error.toString().replaceAll('Exception: ', '');
    
    Get.snackbar(
      title,
      errorMessage.value,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: Duration(seconds: 3),
    );
    
    print('❌ $title: $error');
  }
  
}