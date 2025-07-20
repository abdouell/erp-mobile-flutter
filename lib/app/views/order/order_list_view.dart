import 'package:erp_mobile/app/controllers/order_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/order.dart';

class OrdersListView extends GetView<OrdersListController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildNewOrderFAB(),
    );
  }
  
  /// 📱 APP BAR
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Mes commandes'),
      backgroundColor: Theme.of(Get.context!).primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        // Bouton filtres
        IconButton(
          onPressed: () => _showFiltersBottomSheet(),
          icon: Obx(() => Stack(
            children: [
              Icon(Icons.filter_list, color: Colors.white),
              if (controller.hasActiveFilters)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          )),
          tooltip: 'Filtres',
        ),
        
        // Bouton refresh
        IconButton(
          onPressed: () => controller.refresh(),
          icon: Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Actualiser',
        ),
      ],
    );
  }
  
  /// 📱 BODY PRINCIPAL
  Widget _buildBody() {
    return Obx(() {
      // État loading
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement des commandes...'),
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
                ElevatedButton.icon(
                  onPressed: () => controller.refresh(),
                  icon: Icon(Icons.refresh),
                  label: Text('Réessayer'),
                ),
              ],
            ),
          ),
        );
      }
      
      return Column(
        children: [
          // Statistiques en haut
          _buildStatisticsHeader(),
          
          // Barre de recherche
          _buildSearchBar(),
          
          // Liste des commandes
          Expanded(child: _buildOrdersList()),
        ],
      );
    });
  }
  
  /// 📊 HEADER STATISTIQUES
  Widget _buildStatisticsHeader() {
    return Obx(() => Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              '${controller.totalOrders.value}',
              Icons.receipt_long,
              Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Montant',
              '${controller.totalAmount.value.toStringAsFixed(0)}€',
              Icons.euro,
              Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Validées',
              '${controller.validatedCount.value}',
              Icons.check_circle,
              Colors.orange,
            ),
          ),
        ],
      ),
    ));
  }
  
  /// 📈 CARD STATISTIQUE
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🔍 BARRE DE RECHERCHE
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Obx(() => TextField(
        onChanged: (value) => controller.updateSearch(value),
        decoration: InputDecoration(
          hintText: 'Rechercher par numéro, client...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  onPressed: () => controller.updateSearch(''),
                  icon: Icon(Icons.clear, color: Colors.grey),
                )
              : SizedBox.shrink(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      )),
    );
  }
  
  /// 📋 LISTE DES COMMANDES
  Widget _buildOrdersList() {
    return Obx(() {
      final orders = controller.filteredOrders;
      
      if (orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_outlined, size: 64, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text(
                controller.allOrders.isEmpty 
                    ? 'Aucune commande' 
                    : 'Aucune commande trouvée',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                controller.allOrders.isEmpty
                    ? 'Créez votre première commande'
                    : 'Essayez de modifier vos filtres',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              if (controller.hasActiveFilters) ...[
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => controller.clearFilters(),
                  icon: Icon(Icons.clear),
                  label: Text('Effacer les filtres'),
                ),
              ],
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () => controller.refresh(),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(order);
          },
        ),
      );
    });
  }
  
  /// 🧾 CARD COMMANDE
  Widget _buildOrderCard(Order order) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.goToOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec numéro et statut
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Commande #${order.id}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(order),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Infos commande
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Text(
                    order.formattedDate,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Text(
                    'Client #${order.customerId}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Statistiques commande
              Row(
                children: [
                  Icon(Icons.shopping_bag, size: 16, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Text(
                    '${order.itemCount} articles',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.inventory, size: 16, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Text(
                    '${order.totalQuantity} unités',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Total et bouton voir détails
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.formattedTotal,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(Get.context!).primaryColor,
                      ),
                    ),
                  ),
                  
                  // ✅ MVP: Seulement bouton voir détails
                  IconButton(
                    onPressed: () => controller.goToOrderDetails(order),
                    icon: Icon(Icons.arrow_forward_ios, size: 16),
                    tooltip: 'Voir détails',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 🏷️ CHIP STATUT
  Widget _buildStatusChip(Order order) {
    Color color;
    Color textColor;
    switch (order.status) {
      case OrderStatus.DRAFT:
        color = Colors.orange;
        textColor = Colors.orange.shade700;
        break;
      case OrderStatus.VALIDATED:
        color = Colors.green;
        textColor = Colors.green.shade700;
        break;
      case OrderStatus.CANCELLED:
        color = Colors.red;
        textColor = Colors.red.shade700;
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        order.statusDisplay,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor, // ✅ Utilise la variable textColor définie
        ),
      ),
    );
  }
  
  /// 🛒 FAB NOUVELLE COMMANDE
  Widget _buildNewOrderFAB() {
    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed('/clients'), // Aller aux clients pour créer commande
      icon: Icon(Icons.add_shopping_cart, color: Colors.white),
      label: Text(
        'Nouvelle commande',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Theme.of(Get.context!).primaryColor,
    );
  }
  
  /// 🎛️ BOTTOM SHEET FILTRES
  void _showFiltersBottomSheet() {
    Get.bottomSheet(
      Container(
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
                  Icon(Icons.filter_list, color: Theme.of(Get.context!).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Filtres et tri',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  if (controller.hasActiveFilters)
                    TextButton(
                      onPressed: () {
                        controller.clearFilters();
                        Get.back();
                      },
                      child: Text('Effacer tout'),
                    ),
                ],
              ),
            ),
            
            // Filtres
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtre par statut
                  Text(
                    'Statut',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Obx(() => Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('Toutes', null),
                      _buildFilterChip('Brouillons', OrderStatus.DRAFT),
                      _buildFilterChip('Validées', OrderStatus.VALIDATED),
                      // ✅ MVP: Pas de statut "Annulées"
                    ],
                  )),
                  
                  SizedBox(height: 16),
                  
                  // Tri
                  Text(
                    'Trier par',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Obx(() => Column(
                    children: [
                      _buildSortTile('Plus récentes', 'date_desc'),
                      _buildSortTile('Plus anciennes', 'date_asc'),
                      _buildSortTile('Montant décroissant', 'total_desc'),
                      _buildSortTile('Montant croissant', 'total_asc'),
                    ],
                  )),
                ],
              ),
            ),
            
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  /// 🏷️ CHIP FILTRE
  Widget _buildFilterChip(String label, OrderStatus? status) {
    return Obx(() {
      final isSelected = controller.selectedStatus.value == status;
      
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          controller.setStatusFilter(selected ? status : null);
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
  
  /// 📄 TILE TRI
  Widget _buildSortTile(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: controller.sortBy.value,
      onChanged: (newValue) {
        if (newValue != null) {
          controller.setSortBy(newValue);
          Get.back();
        }
      },
      dense: true,
    );
  }
}