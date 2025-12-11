import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_details_controller.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';

class OrderDetailsView extends GetView<OrderDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: AppBar(
        title: Text(
          controller.order.value != null 
              ? 'Commande #${controller.order.value!.id}'
              : 'Détails commande'
        ),
        backgroundColor: _getStatusColor(controller.order.value?.status),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Bouton partager
          IconButton(
            onPressed: () => controller.shareOrder(),
            icon: Icon(Icons.share, color: Colors.white),
            tooltip: 'Partager',
          ),
          
          // Bouton refresh
          IconButton(
            onPressed: () => controller.refreshOrderDetails(),
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    ));
  }
  
  /// 📱 BODY PRINCIPAL
  Widget _buildBody() {
    return Obx(() {
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
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Retour'),
                ),
              ],
            ),
          ),
        );
      }
      
      // État loading
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement des détails...'),
            ],
          ),
        );
      }
      
      final order = controller.order.value;
      if (order == null) {
        return Center(
          child: Text('Aucune commande à afficher'),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () => controller.refreshOrderDetails(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header avec statut
              _buildStatusHeader(order),
              
              // Informations générales
              _buildOrderInfo(order),
              
              // Informations client
              _buildClientInfo(order),
              
              // Liste des articles
              _buildOrderItems(order),
              
              // Récapitulatif financier
              _buildOrderSummary(order),
              
              SizedBox(height: 80), // Espace pour le bottom bar
            ],
          ),
        ),
      );
    });
  }
  
  /// 🏷️ HEADER STATUT
  Widget _buildStatusHeader(Order order) {
    final color = _getStatusColor(order.status);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(order.status),
            size: 48,
            color: color,
          ),
          SizedBox(height: 8),
          Text(
            order.statusDisplay,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Créée le ${order.formattedDate}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
  
  /// ℹ️ INFORMATIONS COMMANDE
  Widget _buildOrderInfo(Order order) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations commande',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            
            _buildInfoRow(Icons.tag, 'Numéro', '#${order.id}'),
            _buildInfoRow(Icons.calendar_today, 'Date', order.formattedDate),
            _buildInfoRow(Icons.shopping_bag, 'Articles', '${order.itemCount}'),
            _buildInfoRow(Icons.inventory, 'Quantité totale', '${order.totalQuantity}'),
            if (order.entrepriseCode?.isNotEmpty == true)
              _buildInfoRow(Icons.business, 'Entreprise', order.entrepriseCode!),
          ],
        ),
      ),
    );
  }
  
  /// 👤 INFORMATIONS CLIENT
  Widget _buildClientInfo(Order order) {
    return Obx(() {
      final customer = controller.customerInfo.value;
      
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations client',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              
              if (customer != null) ...[
                _buildInfoRow(Icons.person, 'Nom', customer.name ?? 'N/A'),
                _buildInfoRow(Icons.location_on, 'Adresse', customer.address ?? 'N/A'),
                if (customer.rc?.isNotEmpty == true)
                  _buildInfoRow(Icons.business, 'RC', customer.rc!),
                if (customer.phone1?.isNotEmpty == true)
                  _buildInfoRow(Icons.phone, 'Téléphone', customer.phone1!),
              ] else ...[
                _buildInfoRow(Icons.tag, 'ID Client', '#${order.customerId}'),
                Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Détails client en cours de chargement...',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
  
  /// 📦 LISTE DES ARTICLES
  Widget _buildOrderItems(Order order) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Articles commandés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            
            ...order.orderDetails.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildOrderItem(item, index + 1),
                  if (index < order.orderDetails.length - 1)
                    Divider(height: 20),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  /// 🛍️ ITEM DE COMMANDE
  Widget _buildOrderItem(OrderItem item, int position) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header avec position et nom
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$position',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ref: ${item.productCode}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Détails prix et quantité
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prix unitaire',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      item.formattedPrice,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Quantité',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(Get.context!).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Sous-total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (item.hasDiscount) ...[
                      Text(
                        '${item.subtotalBeforeDiscount.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        item.formattedSubtotal,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ] else ...[
                      Text(
                        item.formattedSubtotal,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(Get.context!).primaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 📊 RÉCAPITULATIF FINANCIER
  Widget _buildOrderSummary(Order order) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif financier',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            
            if (order.totalDiscount > 0) ...[
              _buildSummaryRow('Sous-total', order.formattedSubtotal),
              _buildSummaryRow(
                'Remises',
                '-${order.formattedDiscount}',
                color: Colors.green.shade600,
              ),
              SizedBox(height: 8),
              Divider(),
              SizedBox(height: 8),
            ],
            
            _buildSummaryRow(
              'Total HT',
              order.formattedTotal,
            ),
            SizedBox(height: 8),
            _buildSummaryRow(
              'Total TTC',
              order.formattedTotalTTC,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
  
  /// 📄 LIGNE INFO
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Spacer(),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 📄 LIGNE RÉCAPITULATIF
  Widget _buildSummaryRow(
    String label,
    String amount, {
    bool isTotal = false,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color ?? (isTotal ? Theme.of(Get.context!).primaryColor : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 📱 BOTTOM BAR
  Widget _buildBottomBar() {
    return Obx(() {
      final order = controller.order.value;
      if (order == null) return SizedBox.shrink();
      
      // Récupérer le type de document
      final documentType = Get.arguments?['documentType'] ?? 'ORDER';
      
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bouton Retour
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back),
                label: Text('Retour'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            SizedBox(width: 12),
            
            // Bouton Paiements (visible uniquement pour les BL)
            if (documentType == 'BL') ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed('/bl-payments', arguments: {
                      'order': order,
                      'documentType': documentType,
                    });
                  },
                  icon: Icon(Icons.payments),
                  label: Text('Paiements'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
              SizedBox(width: 12),
            ],
            
            // Bouton Nouvelle commande pour ce client
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.createNewOrderForClient(),
                icon: Icon(Icons.add_shopping_cart),
                label: Text('Nouvelle commande'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
  
  /// 🎨 HELPERS COULEURS ET ICÔNES
  Color _getStatusColor(OrderStatus? status) {
    switch (status) {
      case OrderStatus.DRAFT:
        return Colors.orange;
      case OrderStatus.VALIDATED:
        return Colors.green;
      case OrderStatus.CANCELLED:
        return Colors.red;
      case null:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(OrderStatus? status) {
    switch (status) {
      case OrderStatus.DRAFT:
        return Icons.edit;
      case OrderStatus.VALIDATED:
        return Icons.check_circle;
      case OrderStatus.CANCELLED:
        return Icons.cancel;
      case null:
        return Icons.help;
    }
  }
}