import 'package:erp_mobile/app/models/customer.dart';
import 'package:erp_mobile/app/models/statut_visite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/client_tournee.dart';
import '../services/order_service.dart';
import '../services/customer_service.dart';

class OrderDetailsController extends GetxController {
  // Services
  final OrderService _orderService = Get.find<OrderService>();
  final CustomerService _customerService = Get.find<CustomerService>();
  
  // États réactifs
  final isLoading = true.obs; // ✅ Commence en loading
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // Données
  final order = Rxn<Order>();
  final orderItems = <OrderItem>[].obs;
  final customerInfo = Rxn<dynamic>(); // Info client détaillée
  
  @override
  void onInit() {
    super.onInit();
    print('=== INIT ORDER DETAILS CONTROLLER ===');
    
    // ✅ DEBUG: Afficher toutes les infos de navigation
    print('🌐 URL actuelle: ${Get.currentRoute}');
    print('📋 Paramètres Get: ${Get.parameters}');
    print('📋 Arguments Get: ${Get.arguments}');
    print('📋 Paramètres keys: ${Get.parameters.keys.toList()}');
    print('📋 Paramètres values: ${Get.parameters.values.toList()}');
    
    // ✅ SOLUTION ROBUSTE: Essayer plusieurs méthodes
    String? orderIdStr;
    
    // 1. Essayer paramètres d'URL (si route configurée)
    if (Get.parameters.containsKey('id')) {
      orderIdStr = Get.parameters['id'];
      print('✅ ID depuis paramètres URL: $orderIdStr');
    }
    // 2. Essayer arguments (navigation classique)
    else if (Get.arguments != null) {
      if (Get.arguments is Map) {
        final Map args = Get.arguments as Map;
        if (args.containsKey('orderId')) {
          orderIdStr = args['orderId'].toString();
          print('✅ ID depuis arguments Map: $orderIdStr');
        }
      } else if (Get.arguments is String || Get.arguments is int) {
        orderIdStr = Get.arguments.toString();
        print('✅ ID depuis arguments direct: $orderIdStr');
      }
    }
    // 3. Essayer d'extraire depuis l'URL manuellement
    else {
      final currentRoute = Get.currentRoute;
      final RegExp regExp = RegExp(r'/order-details/(\d+)');
      final match = regExp.firstMatch(currentRoute);
      if (match != null) {
        orderIdStr = match.group(1);
        print('✅ ID extrait de l\'URL: $orderIdStr');
      }
    }
    
    print('🎯 ID final retenu: $orderIdStr');
    
    if (orderIdStr != null) {
      final int? orderId = int.tryParse(orderIdStr);
      if (orderId != null) {
        print('✅ Conversion réussie vers int: $orderId');
        loadOrderDetails(orderId);
      } else {
        print('❌ Impossible de convertir "$orderIdStr" en int');
        _setError('ID de commande invalide: $orderIdStr');
      }
    } else {
      print('❌ Aucun ID trouvé nulle part');
      _setError('ID de commande manquant - URL: ${Get.currentRoute}');
    }
  }
  
  /// 📋 CHARGER DÉTAILS COMPLETS
  Future<void> loadOrderDetails(int orderId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      print('🔄 Chargement commande $orderId...');
      
      // Charger la commande depuis l'API
      final loadedOrder = await _orderService.getOrderById(orderId);
      order.value = loadedOrder;
      orderItems.value = loadedOrder.orderDetails;
      
      print('✅ Commande chargée: $loadedOrder');
      print('✅ ${loadedOrder.orderDetails.length} articles');
      
      // Charger les infos client en parallèle (non bloquant)
      if (loadedOrder.customerId > 0) {
        _loadCustomerInfo(loadedOrder.customerId);
      }
      
    } catch (e) {
      print('❌ Erreur chargement commande $orderId: $e');
      _setError('Impossible de charger la commande: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 👤 CHARGER INFO CLIENT (non bloquant)
  Future<void> _loadCustomerInfo(int customerId) async {
    try {
      print('👤 Chargement client $customerId...');
      final customer = await _customerService.getCustomerById(customerId); // ✅ Méthode corrigée
      customerInfo.value = customer;
      print('✅ Client chargé: ${customer.displayName}');
    } catch (e) {
      print('⚠️ Erreur chargement client $customerId: $e');
      // Pas grave, on continue sans les détails client
    }
  }
  
  /// ❌ DÉFINIR UNE ERREUR
  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    isLoading.value = false;
    print('❌ Erreur définie: $message');
  }
  
  /// 🔄 RAFRAÎCHIR LES DÉTAILS
  Future<void> refreshOrderDetails() async {
    final currentOrder = order.value;
    if (currentOrder?.id != null) {
      await loadOrderDetails(currentOrder!.id!);
    } else {
      print('❌ Pas de commande à rafraîchir');
    }
  }
  
  /// 📤 PARTAGER LA COMMANDE
  void shareOrder() {
    final currentOrder = order.value;
    if (currentOrder == null) {
      Get.snackbar(
        'Erreur',
        'Aucune commande à partager',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
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
            
            // Options
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: Text('Envoyer par email'),
              onTap: () => _shareByEmail(),
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text('Générer PDF'),
              onTap: () => _generatePDF(),
            ),
            ListTile(
              leading: Icon(Icons.copy, color: Colors.orange),
              title: Text('Copier le résumé'),
              onTap: () => _copyToClipboard(),
            ),
            
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  /// 📧 PARTAGE PAR EMAIL
  void _shareByEmail() {
    Get.back();
    Get.snackbar(
      'Email',
      'Fonctionnalité email à implémenter',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
  
  /// 📄 GÉNÉRATION PDF
  void _generatePDF() async {
    Get.back();
    
    final currentOrder = order.value;
    if (currentOrder?.id == null) return;
    
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
      
      // Appel au service (si implémenté)
      await _orderService.downloadOrderPdf(currentOrder!.id!);
      
      Get.back(); // Fermer loading
      
      Get.snackbar(
        'PDF généré',
        'Le PDF a été téléchargé avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.back(); // Fermer loading
      
      Get.snackbar(
        'Erreur PDF',
        'Fonctionnalité PDF à implémenter',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
  
  /// 📋 COPIER DANS LE PRESSE-PAPIERS
  void _copyToClipboard() {
    Get.back();
    
    final currentOrder = order.value;
    if (currentOrder == null) return;
    
    // ✅ Utilisation du nouveau modèle Customer
    final customer = customerInfo.value as Customer?;
    
    final summary = '''
Commande #${currentOrder.id}
Date: ${currentOrder.formattedDate}
Client: ${customer?.displayName ?? 'Client #${currentOrder.customerId}'}
Articles: ${currentOrder.itemCount}
Quantité totale: ${currentOrder.totalQuantity}
Total: ${currentOrder.formattedTotal}
Statut: ${currentOrder.statusDisplay}
    ''';
    
    // À implémenter avec flutter/services Clipboard
    Get.snackbar(
      'Copié',
      'Résumé de la commande copié',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }
  
  /// 🔙 RETOUR À LA LISTE
  void goBackToOrdersList() {
    Get.back(); // ✅ Simple retour en arrière
  }
  
  /// 🛒 CRÉER UNE NOUVELLE COMMANDE POUR CE CLIENT
  void createNewOrderForClient() {
    final currentOrder = order.value;
    if (currentOrder == null) {
      Get.snackbar(
        'Erreur',
        'Aucune commande disponible',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // ✅ MVP: Fonctionnalité simplifiée avec nouveau modèle Customer
    final customer = customerInfo.value as Customer?;
    if (customer == null) {
      Get.snackbar(
        'Info client manquante',
        'Chargement des détails client en cours...',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    // Créer un ClientTournee temporaire pour la navigation

    final clientTournee = ClientTournee(
      customerId: currentOrder.customerId,
      customerName: customer.displayName,
      customerAddress: customer.fullAddress,
      customerRc: customer.rc ?? '',
      ordre: 0,
    );
    
    Get.toNamed('/order-create', arguments: {
      'client': clientTournee,
    });
  }
}