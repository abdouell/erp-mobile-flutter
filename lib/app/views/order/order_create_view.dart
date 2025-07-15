import 'package:erp_mobile/app/models/order_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_controller.dart';
import '../../models/product.dart';
import '../../models/client_tournee.dart';

class OrderCreateView extends GetView<OrderController> {
  @override
  Widget build(BuildContext context) {
    // ✅ Récupérer le client avec protection null
    final Map<String, dynamic> args = Get.arguments ?? {};
    final ClientTournee? client = args['client'];
    
    // ✅ Vérification de sécurité
    if (client == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Erreur'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Client non trouvé',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Impossible de créer une commande sans client',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Initialiser la commande une seule fois
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<OrderController>()) {
        print('❌ OrderController non trouvé !');
        return;
      }
      
      try {
        controller.initializeOrder(client);
      } catch (e) {
        print('❌ Erreur initialisation commande: $e');
        Get.snackbar(
          'Erreur',
          'Impossible d\'initialiser la commande: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildCartFAB(),
    );
  }
  
  /// 📱 APP BAR avec info client et panier
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nouvelle commande',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (controller.selectedClient.value != null)
            Text(
              controller.selectedClient.value!.customerName,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
        ],
      )),
      backgroundColor: Theme.of(Get.context!).primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        // Bouton refresh produits
        IconButton(
          onPressed: () => controller.refresh(),
          icon: Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Actualiser les produits',
        ),
        
        // Badge panier dans l'AppBar
        Obx(() => Stack(
          children: [
            IconButton(
              onPressed: () => _showCartBottomSheet(),
              icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
            ),
            if (controller.cartItemCount.value > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Text(
                    '${controller.cartItemCount.value}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        )),
        SizedBox(width: 8),
      ],
    );
  }
  
  /// 📱 BODY PRINCIPAL
  Widget _buildBody() {
    return Obx(() {
      // État loading
      if (controller.isLoadingProducts.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement des produits...'),
            ],
          ),
        );
      }
      
      // État erreur
      if (controller.hasError.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Erreur',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.refresh(),
                        icon: Icon(Icons.refresh),
                        label: Text('Actualiser'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        child: Text('Retour'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
      
      // Interface principale
      return Column(
        children: [
          // Barre de recherche et filtres
          _buildSearchAndFilters(),
          
          // Liste des produits
          Expanded(child: _buildProductsList()),
        ],
      );
    });
  }
  
  /// 🔍 BARRE DE RECHERCHE ET FILTRES
  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            onChanged: (value) => controller.updateSearch(value),
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          
          SizedBox(height: 12),
          
          // Filtres par catégorie
          _buildCategoryTabs(),
        ],
      ),
    );
  }
  
  /// 📂 TABS CATÉGORIES
  Widget _buildCategoryTabs() {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return SizedBox.shrink();
      }
      
      return Container(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // Bouton "Toutes"
            _buildCategoryChip('Toutes', null),
            SizedBox(width: 8),
            
            // Boutons catégories
            ...controller.categories.map((category) {
              return Padding(
                padding: EdgeInsets.only(right: 8),
                child: _buildCategoryChip(category, category),
              );
            }).toList(),
          ],
        ),
      );
    });
  }
  
  /// 🏷️ CHIP CATÉGORIE
  Widget _buildCategoryChip(String label, String? categoryValue) {
    return Obx(() {
      final isSelected = controller.selectedCategory.value == categoryValue;
      
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          controller.selectCategory(selected ? categoryValue : null);
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: Theme.of(Get.context!).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(Get.context!).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(Get.context!).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      );
    });
  }
  
  /// 📦 LISTE DES PRODUITS
  Widget _buildProductsList() {
    return Obx(() {
      final products = controller.filteredProducts;
      
      if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text(
                'Aucun produit trouvé',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Essayez de modifier votre recherche',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => controller.refresh(),
                icon: Icon(Icons.refresh),
                label: Text('Actualiser'),
              ),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () => controller.refresh(),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        ),
      );
    });
  }
  
  /// 🛍️ CARD PRODUIT
  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Image produit
            _buildProductImage(product),
            
            SizedBox(width: 12),
            
            // Info produit
            Expanded(child: _buildProductInfo(product)),
            
            SizedBox(width: 8),
            
            // Actions panier
            _buildProductActions(product),
          ],
        ),
      ),
    );
  }
  
  /// 🖼️ IMAGE PRODUIT
  Widget _buildProductImage(Product product) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: product.hasPhoto
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                product.photo!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildProductPlaceholder();
                },
              ),
            )
          : _buildProductPlaceholder(),
    );
  }
  
  /// 📦 PLACEHOLDER IMAGE
  Widget _buildProductPlaceholder() {
    return Icon(
      Icons.inventory_2_outlined,
      size: 32,
      color: Colors.grey.shade400,
    );
  }
  
  /// ℹ️ INFO PRODUIT
  Widget _buildProductInfo(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom produit
        Text(
          product.displayName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: 4),
        
        // Code produit
        Text(
          'Ref: ${product.productCode}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        
        SizedBox(height: 4),
        
        // Prix
        Text(
          product.formattedPrice,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(Get.context!).primaryColor,
          ),
        ),
        
        // Statut disponibilité
        if (!product.isAvailable) ...[
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Indisponible',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  /// 🛒 ACTIONS PANIER
  Widget _buildProductActions(Product product) {
    return Obx(() {
      final quantityInCart = controller.getProductQuantityInCart(product.id);
      final isInCart = quantityInCart > 0;
      
      if (!isInCart) {
        // Bouton ajouter
        return ElevatedButton(
          onPressed: product.isAvailable 
              ? () => controller.addToCart(product)
              : null,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(80, 36),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('Ajouter'),
        );
      } else {
        // Contrôles quantité
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(Get.context!).primaryColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bouton -
              InkWell(
                onTap: () => controller.updateCartItemQuantity(
                  product.id, 
                  quantityInCart - 1,
                ),
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.remove, size: 16),
                ),
              ),
              
              // Quantité
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '$quantityInCart',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              
              // Bouton +
              InkWell(
                onTap: () => controller.updateCartItemQuantity(
                  product.id, 
                  quantityInCart + 1,
                ),
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.add, size: 16),
                ),
              ),
            ],
          ),
        );
      }
    });
  }
  
  /// 🛒 FAB PANIER FLOTTANT
 /// 🛒 FAB PANIER FLOTTANT - Version améliorée
Widget _buildCartFAB() {
  return Obx(() {
    // ✅ Vérification multiple pour s'assurer que le FAB disparaît
    if (controller.cartItemCount.value == 0 || 
        controller.cartItems.isEmpty || 
        controller.cartTotal.value == 0.0) {
      return SizedBox.shrink();
    }
    
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: FloatingActionButton.extended(
        key: ValueKey('cart-fab-${controller.cartItemCount.value}'), // ← Clé pour animation
        onPressed: () => _showCartBottomSheet(),
        icon: Icon(Icons.shopping_cart, color: Colors.white),
        label: Text(
          '${controller.cartTotal.value.toStringAsFixed(2)} €',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(Get.context!).primaryColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  });
}
  
  /// 🛒 BOTTOM SHEET PANIER
  // Dans order_create_view.dart - Bottom sheet simplifié

/// 🛒 BOTTOM SHEET PANIER - Version simplifiée
void _showCartBottomSheet() {
  Get.bottomSheet(
    Obx(() {
      if (controller.cartItems.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isBottomSheetOpen == true) {
            Get.back();
          }
        });
        return Container(
          height: 200,
          child: Center(child: Text('Panier vide')),
        );
      }
      
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Theme.of(Get.context!).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Mon panier',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    '${controller.cartItemCount.value} article(s)',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            
            // Liste articles
            Container(
              constraints: BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return _buildCartItem(item);
                },
              ),
            ),
            
            // Footer avec total et action unique
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  // Total
                  Row(
                    children: [
                      Text(
                        'Total: ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text(
                        '${controller.cartTotal.value.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(Get.context!).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // ✅ UN SEUL BOUTON: Valider commande
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isValidatingOrder.value
                          ? null
                          : () {
                              Get.back(); // Fermer bottom sheet
                              Future.delayed(Duration(milliseconds: 300), () {
                                controller.validateOrder();
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: controller.isValidatingOrder.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Validation...'),
                              ],
                            )
                          : Text('Valider la commande'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }),
    isScrollControlled: true,
  );
}
  
  /// 🛒 ITEM DANS LE PANIER
  Widget _buildCartItem(OrderItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Info produit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.formattedPrice,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          
          // Contrôles quantité
          Row(
            children: [
              IconButton(
                onPressed: () => controller.updateCartItemQuantity(
                  item.productId, 
                  item.quantity - 1,
                ),
                icon: Icon(Icons.remove_circle_outline),
                iconSize: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => controller.updateCartItemQuantity(
                  item.productId, 
                  item.quantity + 1,
                ),
                icon: Icon(Icons.add_circle_outline),
                iconSize: 20,
              ),
            ],
          ),
          
          // Sous-total
          SizedBox(width: 8),
          Text(
            item.formattedSubtotal,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(Get.context!).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}