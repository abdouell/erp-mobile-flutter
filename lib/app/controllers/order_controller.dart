import 'package:erp_mobile/app/controllers/tournee_controller.dart';
import 'package:erp_mobile/app/services/location_service.dart';
import 'package:erp_mobile/app/services/tournee_service.dart';
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
      
      currentOrder.value = _orderService.createNewOrder(
        userId: user.id,
        customerId: client.customerId,
      );
      
      // Vider le panier précédent
      clearCart();
      
      // Charger les données produits
      await _loadInitialData();
      

    } catch (e) {
      _handleError('Erreur initialisation commande', e);
    }
  }
  
  /// 📦 CHARGEMENT DONNÉES INITIALES
  Future<void> _loadInitialData() async {
      // ✅ Charger les produits d'abord (filtrés selon vendeur)
      await _loadProducts();
      
      // ✅ Puis extraire les catégories des produits chargés
      await _loadCategories();
  }
  
/// 📦 CHARGER PRODUITS - AVEC TARIFICATION CLIENT
Future<void> _loadProducts() async {
  try {
    isLoadingProducts.value = true;
    hasError.value = false;
    
    // Vérifier qu'on a un client sélectionné
    if (selectedClient.value == null) {
      throw Exception('Aucun client sélectionné');
    }
    
    final customerId = selectedClient.value!.customerId;

    // ✅ RÉCUPÉRER LE VENDEUR pour savoir si filtrage par emplacement nécessaire
    final tourneeController = Get.find<TourneeController>();
    final vendeur = tourneeController.vendeur.value;
    
    if (vendeur == null) {
      throw Exception('Informations vendeur non disponibles');
    }
    
    print('👤 Vendeur récupéré: ${vendeur.nomComplet} - Type: ${vendeur.typeVendeur}');
    
    List<Product> products;
    
    // ✅ LOGIQUE CONDITIONNELLE SELON TYPE VENDEUR
    if (vendeur.isConventionnel && vendeur.hasEmplacement) {
      // Vendeur CONVENTIONNEL → Produits en stock avec tarification client
      print('🚚 Vendeur CONVENTIONNEL détecté - Chargement stock emplacement ${vendeur.emplacementCode}');
      
      // Récupérer produits avec stock
      final stockProducts = await _productService.getProductsByEmplacement(vendeur.emplacementCode!);
      
      // Récupérer tarification client
      final pricedProducts = await _productService.getProductsForCustomer(customerId);
      
      // Fusionner : garder seulement les produits en stock, avec leur prix client
      products = stockProducts.map((stockProduct) {
        // Chercher le même produit dans la liste avec tarification
        final pricedProduct = pricedProducts.firstWhereOrNull(
          (p) => p.productCode == stockProduct.productCode
        );
        
        // Si trouvé avec tarification, utiliser celui-là mais garder le stock
        if (pricedProduct != null) {
          return Product(
            id: pricedProduct.id,
            productCode: pricedProduct.productCode,
            description: pricedProduct.description,
            rank: pricedProduct.rank,
            companyCode: pricedProduct.companyCode,
            productPageCode: pricedProduct.productPageCode,
            productCategoryCode: pricedProduct.productCategoryCode,
            productTypeCode: pricedProduct.productTypeCode,
            supplierCode: pricedProduct.supplierCode,
            salesPrice: pricedProduct.salesPrice,
            // ✅ Prix client et remise
            customerPrice: pricedProduct.customerPrice,
            discountPercent: pricedProduct.discountPercent,
            hasPriceList: pricedProduct.hasPriceList,
            vatCode: pricedProduct.vatCode,
            hold: pricedProduct.hold,
            rangeCode: pricedProduct.rangeCode,
            familyCode: pricedProduct.familyCode,
            brand: pricedProduct.brand,
            activityCode: pricedProduct.activityCode,
            managementUnit: pricedProduct.managementUnit,
            stockMin: pricedProduct.stockMin,
            // ✅ Info stock du produit d'origine
            quantiteEnStock: stockProduct.quantiteEnStock,
            longDescription: pricedProduct.longDescription,
            barcode: pricedProduct.barcode,
            page: pricedProduct.page,
            fournisseur: pricedProduct.fournisseur,
            discount: pricedProduct.discount,
            salesPacking: pricedProduct.salesPacking,
            weight: pricedProduct.weight,
            volume: pricedProduct.volume,
            weightManaged: pricedProduct.weightManaged,
            weightPrecision: pricedProduct.weightPrecision,
            photo: pricedProduct.photo,
            freeProduct: pricedProduct.freeProduct,
            colisageCarton: pricedProduct.colisageCarton,
          );
        }
        
        // Sinon, utiliser le produit en stock tel quel
        return stockProduct;
      }).toList();
      
      print('✅ ${products.length} produits en stock avec tarification client');
      
    } else {
      // Vendeur PREVENTE ou LIVREUR → Tous les produits avec tarification client
      print('📋 Vendeur ${vendeur.typeVendeur} - Chargement de tous les produits avec tarification');
      products = await _productService.getProductsForCustomer(customerId);
      print('✅ ${products.length} produits chargés avec tarification client');
    }
    
    allProducts.value = products;
    filteredProducts.value = products;
    
    // Compter les produits avec remise
    final withDiscount = products.where((p) => p.hasDiscount).length;
    print('💰 Produits avec remise client: $withDiscount');
    print('✅ Produits chargés avec succès');
    
  } catch (e) {
    print('❌ Erreur chargement produits: $e');
    _handleError('Erreur chargement produits', e);
  } finally {
    isLoadingProducts.value = false;
  }
}

/// 📂 CHARGER CATÉGORIES - À PARTIR DES PRODUITS FILTRÉS
Future<void> _loadCategories() async {
  try {
    print('📂 Extraction des catégories des produits chargés...');
    
    // ✅ Extraire les catégories UNIQUEMENT des produits filtrés (allProducts)
    final categorySet = allProducts
        .map((product) => product.productCategoryCode)
        .toSet(); // Utiliser Set pour éliminer les doublons
    
    final categoryList = categorySet.toList();
    categoryList.sort(); // Tri alphabétique
    
    categories.value = categoryList;
    
    print('✅ ${categoryList.length} catégories extraites des ${allProducts.length} produits');
    
  } catch (e) {
    print('⚠️ Erreur extraction catégories: $e');
    // Non bloquant, on continue sans catégories
    categories.value = [];
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
  
/// 🛒 AJOUTER AU PANIER - AVEC VALIDATION STOCK
void addToCart(Product product, {int quantity = 1}) {
  try {
    print('🛒 Ajout panier: ${product.displayName} x$quantity');
    
    if (!product.isAvailable) {
      Get.snackbar('Produit indisponible', '${product.displayName} n\'est pas disponible');
      return;
    }
    
    // ✅ NOUVEAU : Vérifier le stock avant d'ajouter
    final existingItem = cartItems.firstWhereOrNull((item) => item.productId == product.id);
    final currentQuantityInCart = existingItem?.quantity ?? 0;
    final newTotalQuantity = currentQuantityInCart + quantity;
    
    // Vérifier si stock suffisant
    if (!_isStockAvailable(product, newTotalQuantity)) {
      final maxAvailable = _getMaxAvailableQuantity(product);
      final canStillAdd = maxAvailable - currentQuantityInCart;
      
      if (canStillAdd <= 0) {
        Get.snackbar(
          'Stock insuffisant',
          product.isOutOfStock 
            ? '${product.displayName} est en rupture de stock'
            : 'Stock maximum atteint (${product.stockDisponible} disponibles)',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Stock limité',
          'Vous pouvez ajouter maximum $canStillAdd unité(s) de plus\n(Stock disponible: ${product.stockDisponible})',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
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
  
/// ✅ VALIDER COMMANDE - AVEC CHECKOUT AUTOMATIQUE
Future<void> validateOrder() async {
  try {
    print('📄 === VALIDATION COMMANDE ===');
    
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
    print('📄 Début validation...');

    // Récupérer la géolocalisation
    final locationService = Get.find<LocationService>();
    final position = await locationService.getCurrentPosition();
    
    double? latitude = position?.latitude;
    double? longitude = position?.longitude;
    

    // Créer la commande finale avec le commentaire
    final finalOrder = currentOrder.value!.copyWith(
      orderDetails: cartItems.toList(),
      totalAmount: cartTotal.value,
      status: OrderStatus.VALIDATED,
      comment: orderComment?.trim().isEmpty == true ? null : orderComment?.trim(),
      latitude: latitude,
      longitude: longitude,
    );
    
    print('💾 Commande à valider: $finalOrder');
    print('💬 Commentaire: "${finalOrder.comment}"');
    
    // 1. SAUVEGARDE DE LA COMMANDE
    Order savedOrder = await _orderService.saveOrder(
      finalOrder, 
      clientTourneeId: selectedClient.value?.id
    );
    
    print('✅ Sauvegarde serveur réussie: $savedOrder');
    
    // 2. MISE À JOUR DE L'ÉTAT LOCAL
    currentOrder.value = savedOrder;
    print('✅ Commande locale mise à jour avec ID: ${savedOrder.id}');
    
    // 3. VIDER LE PANIER
    print('🗑️ Vidage du panier après succès...');
    clearCart();
    
    // 4. MESSAGE DE SUCCÈS
    Get.snackbar(
      'Commande validée ! 🎉',
      'Commande #${savedOrder.id} validée avec succès',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
      duration: Duration(seconds: 3),
    );
    
    // 5. NAVIGATION VERS CONFIRMATION
    print('🧭 Navigation vers confirmation...');
    
    // ✅ FERMER LE BOTTOM SHEET AVANT LA NAVIGATION
    if (Get.isBottomSheetOpen == true) {
      Get.back(); // Fermer le bottom sheet du panier
    }
    
    Get.toNamed('/order-confirmation', arguments: {
      'order': savedOrder,
      'client': selectedClient.value,
    });

    // ✅ NOUVEAU : Rafraîchir le TourneeController
    final tourneeController = Get.find<TourneeController>();
    await tourneeController.refresh();
    
    print('✅ === FIN VALIDATION COMMANDE ===');
    
  } catch (e) {
  print('❌ Erreur validation: $e');
  
  // Le service gère déjà l'extraction du message serveur
  final errorMessage = e.toString().replaceAll('Exception: ', '');
  
  Get.snackbar(
    'Erreur de validation',
    errorMessage,
    backgroundColor: Colors.red.shade600,
    colorText: Colors.white,
    icon: Icon(Icons.error_outline, color: Colors.white),
    duration: Duration(seconds: 5),
    snackPosition: SnackPosition.TOP,
    margin: EdgeInsets.all(16),
    borderRadius: 8,
  );
  
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

  /// 📦 HELPER : Vérifier si la quantité demandée est disponible en stock
bool _isStockAvailable(Product product, int requestedQuantity) {
  // Si pas d'info de stock (vendeur PREVENTE/LIVREUR), toujours disponible
  if (!product.hasStockInfo) {
    return true;
  }
  
  // Pour vendeur CONVENTIONNEL avec info stock
  return requestedQuantity <= product.stockDisponible;
}

/// 📦 HELPER : Obtenir la quantité maximale disponible
int _getMaxAvailableQuantity(Product product) {
  if (!product.hasStockInfo) {
    return 999; // Pas de limite pour PREVENTE/LIVREUR
  }
  return product.stockDisponible;
}
  
}
