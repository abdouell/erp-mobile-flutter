import 'package:erp_mobile/app/controllers/tournee_controller.dart';
import 'package:erp_mobile/app/models/order_item.dart';
import 'package:erp_mobile/app/models/statut_visite.dart';
import 'package:erp_mobile/app/services/location_service.dart';
import 'package:erp_mobile/app/services/tournee_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_controller.dart';
import '../../models/product.dart';
import '../../models/client_tournee.dart';

const List<Map<String, String>> MOTIFS_VISITE = [
  {'code': 'VISITE', 'libelle': 'Visite / Présentation'},
  {'code': 'RELANCE', 'libelle': 'Relance'},
  {'code': 'ABSENT', 'libelle': 'Absent / Fermé'},
  {'code': 'PAS_DE_BESOIN', 'libelle': 'Pas de besoin'},
  {'code': 'AUTRE', 'libelle': 'Autre'},
];

class OrderCreateView extends GetView<OrderController> {
  @override
  Widget build(BuildContext context) {
    // Récupérer le client avec protection null
    final Map<String, dynamic> args = Get.arguments ?? {};
    final ClientTournee? client = args['client'];
    
    // Vérification de sécurité
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
    
    // ✅ NOUVEAU : WillPopScope pour intercepter le bouton retour
    return WillPopScope(
      onWillPop: () async {
        return await _handleBackNavigation(client);
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildCartFAB(),
      ),
    );
  }

  // ✅ NOUVEAU : Gestion de la navigation arrière
Future<bool> _handleBackNavigation(ClientTournee client) async {
  if (client.statutVisite != StatutVisite.VISITE_EN_COURS) return true;
  
  final result = await _showMandatoryClotureDialog(client);
  
  if (result != null && result['confirmed'] == true) {
    try {
      await _performClotureVisite(client, result['motif'], result['note']);
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de clôturer: $e');
      return false;
    }
  }
  
  Get.snackbar('Visite en cours', 'Vous pourrez clôturer cette visite plus tard', backgroundColor: Colors.blue, colorText: Colors.white);
  return false;
}

  // ✅ NOUVEAU : Dialogue obligatoire de clôture
Future<Map<String, dynamic>?> _showMandatoryClotureDialog(ClientTournee client) async {
  String? selectedMotif;
  final TextEditingController noteController = TextEditingController();
  
  return await Get.dialog<Map<String, dynamic>>(
    AlertDialog(
      // ✅ CONTRAINDRE LA LARGEUR
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(horizontal: 40), // Marges latérales
      content: Container(
        width: Get.width * 0.85, // 85% de la largeur d'écran maximum
        constraints: BoxConstraints(
          maxWidth: 400, // Largeur maximum fixe
        ),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header personnalisé
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Clôture obligatoire',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          noteController.dispose();
                          Get.back(result: {'confirmed': false});
                        },
                        icon: Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                
                // Contenu principal
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message plus compact
                      Text(
                        'Visite en cours pour ${client.customerName}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      Text(
                        'Motif de clôture *',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedMotif,
                            hint: Text('  Sélectionner un motif'),
                            isExpanded: true,
                            items: MOTIFS_VISITE.map((motif) {
                              return DropdownMenuItem<String>(
                                value: motif['code'],
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    motif['libelle']!,
                                    style: TextStyle(fontSize: 14), // Texte plus petit
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedMotif = value;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 12),
                      
                      Text(
                        'Note (optionnel)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        maxLines: 2, // Réduit à 2 lignes
                        maxLength: 100, // Réduit la longueur
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Note...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.all(10), // Padding réduit
                          isDense: true, // Plus compact
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            noteController.dispose();
                            Get.back(result: {'confirmed': false});
                          },
                          child: Text('Reporter'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: selectedMotif == null 
                              ? null 
                              : () {
                                  final note = noteController.text.trim();
                                  noteController.dispose();
                                  Get.back(result: {
                                    'confirmed': true,
                                    'motif': selectedMotif!,
                                    'note': note.isEmpty ? null : note,
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Clôturer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

  // ✅ NOUVEAU : Effectuer la clôture de visite
// Effectuer la clôture de visite via le contrôleur
Future<void> _performClotureVisite(ClientTournee client, String motif, String? note) async {
  try {
    // Afficher loading
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Clôture en cours...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    // Appel au contrôleur (qui gère position + API + refresh)
    final tourneeController = Get.find<TourneeController>();
    await tourneeController.checkoutWithoutOrder(
      client.id!,
      motif,
      note,
    );

    // Fermer loading
    Get.back();

    // Notification de succès
    final motifLibelle = MOTIFS_VISITE.firstWhere((m) => m['code'] == motif)['libelle'];
    Get.snackbar(
      'Visite clôturée',
      '${client.customerName}\nMotif: $motifLibelle',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );

  } catch (e) {
    // Fermer loading
    if (Get.isDialogOpen == true) Get.back();
    
    // Re-lancer l'exception
    rethrow;
  }
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
            if (controller.cartItems.isNotEmpty) 
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
                    '${controller.cartItems.length}',
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
  
  /// 🛒 CARD PRODUIT
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
  
/// ℹ️ INFO PRODUIT - AVEC AFFICHAGE STOCK
/// ℹ️ INFO PRODUIT - VERSION COMPLÈTE
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
      
      SizedBox(height: 6),
      
      // ✅ PRIX AVEC REMISE
      if (product.hasDiscount) ...[
        // Prix client en vert avec badge remise
        Row(
          children: [
            Text(
              product.formattedEffectivePrice,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                product.formattedDiscount,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        // Prix catalogue barré
        Text(
          product.formattedCatalogPrice,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      ] else ...[
        // Prix normal (pas de remise)
        Text(
          product.formattedEffectivePrice,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(Get.context!).primaryColor,
          ),
        ),
      ],
      
      SizedBox(height: 6),
      
      // ✅ STATUTS (Disponibilité + Stock)
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          // Indisponible
          if (!product.isAvailable)
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
          
          // Stock (pour vendeurs conventionnels)
          if (product.hasStockInfo) ...[
            if (product.isOutOfStock)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, size: 12, color: Colors.red.shade700),
                    SizedBox(width: 4),
                    Text(
                      'Rupture de stock',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else if (product.isLowStock)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 12, color: Colors.orange.shade700),
                    SizedBox(width: 4),
                    Text(
                      product.stockLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: Colors.green.shade700),
                    SizedBox(width: 4),
                    Text(
                      product.stockLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    ],
  );
}

/// ✅ NOUVEAU : Badge stock avec couleurs selon disponibilité
Widget _buildStockBadge(Product product) {
  Color backgroundColor;
  Color textColor;
  IconData icon;
  
  if (product.isOutOfStock) {
    // Rupture de stock
    backgroundColor = Colors.red.shade100;
    textColor = Colors.red.shade700;
    icon = Icons.cancel_outlined;
  } else if (product.isLowStock) {
    // Stock faible
    backgroundColor = Colors.orange.shade100;
    textColor = Colors.orange.shade700;
    icon = Icons.warning_amber_outlined;
  } else {
    // Stock normal
    backgroundColor = Colors.green.shade100;
    textColor = Colors.green.shade700;
    icon = Icons.check_circle_outline;
  }
  
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: textColor.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor),
        SizedBox(width: 4),
        Text(
          product.stockLabel,
          style: TextStyle(
            fontSize: 11,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
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
  Widget _buildCartFAB() {
    return Obx(() {
      // Vérification multiple pour s'assurer que le FAB disparaît
      if (controller.cartItemCount.value == 0 || 
          controller.cartItems.isEmpty || 
          controller.cartTotal.value == 0.0) {
        return SizedBox.shrink();
      }
      
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          key: ValueKey('cart-fab-${controller.cartItemCount.value}'),
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
  void _showCartBottomSheet() {
    Get.bottomSheet(
      Obx(() {
        if (controller.cartItems.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header avec bouton fermer
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.grey.shade400),
                      SizedBox(width: 8),
                      Text(
                        'Mon panier',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.close),
                        tooltip: 'Fermer',
                      ),
                    ],
                  ),
                ),
                
                // Panier vide
                Container(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Panier vide',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ajoutez des produits pour créer votre commande',
                        style: TextStyle(color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
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
                      '${controller.cartItems.length} produit(s) • ${controller.cartItemCount.value} article(s)',  
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
              
              // Footer
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
                    
                    // Bouton valider commande
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isValidatingOrder.value
                            ? null
                            : () {
                                controller.validateOrder();
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
      isDismissible: true,
      enableDrag: true,
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