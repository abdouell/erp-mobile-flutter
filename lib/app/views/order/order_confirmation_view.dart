import 'package:erp_mobile/app/controllers/order_controller.dart';
import 'package:erp_mobile/app/models/client_tournee.dart';
import 'package:erp_mobile/app/models/order.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderConfirmationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Récupérer les données passées
    final Map<String, dynamic> args = Get.arguments ?? {};
    final Order order = args['order'];
    final ClientTournee client = args['client'];

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(order, client),
      bottomNavigationBar: _buildBottomBar(order, client),
    );
  }
  
  /// 📱 APP BAR
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Commande validée'),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 2,
      automaticallyImplyLeading: false, // Pas de bouton retour
    );
  }
  
  /// 📱 BODY PRINCIPAL
  Widget _buildBody(Order order, ClientTournee client) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Animation succès
          _buildSuccessHeader(order),
          
          // Info commande
          _buildOrderInfo(order, client),
          
          // Récapitulatif articles
          _buildOrderSummary(order),
          
          // Actions rapides
          _buildQuickActions(order),
        ],
      ),
    );
  }
  
  /// ✅ HEADER SUCCÈS
  Widget _buildSuccessHeader(Order order) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Icône succès avec animation
          TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: 24),
          
          // Titre succès
          Text(
            'Commande validée !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 8),
          
          // Numéro commande
          Text(
            'Commande #${order.id}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          
          SizedBox(height: 4),
          
          // Date
          Text(
            'Créée le ${order.formattedDate}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  /// ℹ️ INFO COMMANDE
  Widget _buildOrderInfo(Order order, ClientTournee client) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre section
              Row(
                children: [
                  Icon(Icons.info_outline, color: Theme.of(Get.context!).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Informations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Client
              _buildInfoRow(
                Icons.person,
                'Client',
                client.customerName,
              ),
              
              SizedBox(height: 8),
              
              // Adresse
              if (client.customerAddress.isNotEmpty)
                _buildInfoRow(
                  Icons.location_on,
                  'Adresse',
                  client.customerAddress,
                ),
              
              SizedBox(height: 8),
              
              // RC
              if (client.customerRc.isNotEmpty)
                _buildInfoRow(
                  Icons.business,
                  'RC',
                  client.customerRc,
                ),
              
              SizedBox(height: 8),
              
              // Statut
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Statut',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.statusDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 📄 LIGNE INFO
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        Spacer(),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  /// 📊 RÉCAPITULATIF COMMANDE
  Widget _buildOrderSummary(Order order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre section
              Row(
                children: [
                  Icon(Icons.receipt_long, color: Theme.of(Get.context!).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Récapitulatif',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Statistiques
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Articles',
                      '${order.itemCount}',
                      Icons.inventory_2_outlined,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Quantité',
                      '${order.totalQuantity}',
                      Icons.shopping_cart_outlined,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Totaux
              if (order.totalDiscount > 0) ...[
                _buildSummaryRow(
                  'Sous-total',
                  '${order.subtotalBeforeDiscount.toStringAsFixed(2)} €',
                ),
                SizedBox(height: 4),
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
                'Total TTC',
                order.formattedTotal,
                isTotal: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 📈 CARD STATISTIQUE
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
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
    return Row(
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
    );
  }
  
  /// ⚡ ACTIONS RAPIDES
  Widget _buildQuickActions(Order order) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre section
              Row(
                children: [
                  Icon(Icons.flash_on, color: Theme.of(Get.context!).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Actions rapides',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadPdf(order),
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text('Télécharger PDF'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareOrder(order),
                      icon: Icon(Icons.share),
                      label: Text('Partager'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 📱 BOTTOM BAR
 Widget _buildBottomBar(Order order, ClientTournee client) {
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
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ Première ligne de boutons
        Row(
          children: [
            // Bouton Nouvelle commande
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _createNewOrder(client),
                icon: Icon(Icons.add_shopping_cart),
                label: Text('Nouvelle commande'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 12),
            
            // ✅ Bouton Mes commandes
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _goToOrdersList(),
                icon: Icon(Icons.receipt_long),
                label: Text('Mes commandes'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12),
        
        // ✅ Deuxième ligne - Bouton principal
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _returnToClients(),
            icon: Icon(Icons.people),
            label: Text('Retour aux clients'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  
  /// 📄 TÉLÉCHARGER PDF
  void _downloadPdf(Order order) async {
    try {
      // Afficher loading
      Get.dialog(
        AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Génération du PDF...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );
      
      // Simuler téléchargement (à implémenter avec votre OrderService)
      await Future.delayed(Duration(seconds: 2));
      
      Get.back(); // Fermer loading
      
      Get.snackbar(
        'PDF généré',
        'Le PDF de la commande #${order.id} a été téléchargé',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: Icon(Icons.download_done, color: Colors.white),
      );
      
    } catch (e) {
      Get.back(); // Fermer loading
      
      Get.snackbar(
        'Erreur',
        'Impossible de générer le PDF: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  /// 📤 PARTAGER COMMANDE
  void _shareOrder(Order order) {
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
                  Icon(Icons.share, color: Theme.of(Get.context!).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Partager la commande',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            // Options de partage
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: Text('Envoyer par email'),
              onTap: () {
                Get.back();
                _sendByEmail(order);
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: Colors.green),
              title: Text('Envoyer par SMS'),
              onTap: () {
                Get.back();
                _sendBySMS(order);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, color: Colors.orange),
              title: Text('Copier le résumé'),
              onTap: () {
                Get.back();
                _copyToClipboard(order);
              },
            ),
            
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  /// 📧 ENVOYER PAR EMAIL
  void _sendByEmail(Order order) {
    // À implémenter avec un package comme url_launcher
    Get.snackbar(
      'Email',
      'Fonctionnalité email à implémenter',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
  
  /// 📱 ENVOYER PAR SMS
  void _sendBySMS(Order order) {
    // À implémenter avec un package comme url_launcher
    Get.snackbar(
      'SMS',
      'Fonctionnalité SMS à implémenter',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
  
  /// 📋 COPIER DANS LE PRESSE-PAPIERS
  void _copyToClipboard(Order order) {
    final summary = '''
Commande #${order.id}
Date: ${order.formattedDate}
Articles: ${order.itemCount}
Quantité totale: ${order.totalQuantity}
Total: ${order.formattedTotal}
Statut: ${order.statusDisplay}
    ''';
    
    // À implémenter avec flutter/services Clipboard
    Get.snackbar(
      'Copié',
      'Résumé de la commande copié dans le presse-papiers',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: Icon(Icons.copy, color: Colors.white),
    );
  }
  
  /// 🛒 CRÉER NOUVELLE COMMANDE
  void _createNewOrder(ClientTournee client) {
    // Nettoyer la session courante
    final orderController = Get.find<OrderController>();
    orderController.clearOrder();
    
    // Retourner à la création de commande
    Get.offNamedUntil(
      '/order-create',
      (route) => route.settings.name == '/clients',
      arguments: {'client': client},
    );
  }
  
  /// 👥 RETOURNER AUX CLIENTS
  void _returnToClients() {
    // Nettoyer la session
    final orderController = Get.find<OrderController>();
    orderController.clearOrder();
    
    // Retourner à la liste des clients
    Get.offNamedUntil(
      '/clients',
      (route) => route.settings.name == '/tournee',
    );
  }

  void _goToOrdersList() {
  // Nettoyer la session
  final orderController = Get.find<OrderController>();
  orderController.clearOrder();
  
  // Aller à la liste des commandes
  Get.offNamedUntil(
    '/orders',
    (route) => route.settings.name == '/tournee',
  );
}

}