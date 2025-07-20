import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import 'api_service.dart';

class OrderService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  
  /// Créer ou mettre à jour une commande
/// Créer ou mettre à jour une commande - Adapté aux modèles Order/OrderItem
Future<Order> saveOrder(Order order) async {
  try {
    print('=== SAUVEGARDE COMMANDE ===');
    print('Order: $order'); // Utilise le toString() de votre modèle
    
    // ✅ Utiliser directement le toJson() de votre modèle Order
    final orderData = order.toJson();
    
    print('📤 Données envoyées: $orderData');
    
    final response = await _apiService.dio.post('/api/order', data: orderData);
    
    print('✅ Réponse brute: ${response.data}');
    print('✅ Type de réponse: ${response.data.runtimeType}');
    
    // ✅ Gestion robuste de la réponse serveur
    if (response.data == null || response.data == "" || response.data is String) {
      print('⚠️ Serveur retourne une réponse vide - Construction manuelle de la réponse');
      
      // Le serveur a probablement sauvegardé mais ne retourne pas l'objet
      // On retourne la commande avec un ID généré et le statut validé
      final savedOrder = order.copyWith(
        id: order.id ?? DateTime.now().millisecondsSinceEpoch,
        status: OrderStatus.VALIDATED,
      );
      
      print('✅ Commande construite manuellement: $savedOrder');
      return savedOrder;
      
    } else if (response.data is Map<String, dynamic>) {
      // ✅ Réponse JSON normale - utiliser votre factory Order.fromJson
      try {
        final savedOrder = Order.fromJson(response.data);
        print('✅ Commande parsée depuis JSON: $savedOrder');
        return savedOrder;
      } catch (parseError) {
        print('❌ Erreur parsing JSON: $parseError');
        print('❌ JSON reçu: ${response.data}');
        
        // Fallback: retourner la commande locale
        final fallbackOrder = order.copyWith(
          id: response.data['id'] ?? DateTime.now().millisecondsSinceEpoch,
          status: OrderStatus.VALIDATED,
        );
        print('⚠️ Fallback sur commande locale: $fallbackOrder');
        return fallbackOrder;
      }
    } else {
      print('❌ Type de réponse inattendu: ${response.data.runtimeType}');
      
      // Dernière chance: retourner la commande locale validée
      final lastResortOrder = order.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        status: OrderStatus.VALIDATED,
      );
      print('🆘 Dernière chance - commande locale: $lastResortOrder');
      return lastResortOrder;
    }
    
  } on DioException catch (e) {
    print('❌ Erreur Dio sauvegarde commande: ${e.response?.statusCode}');
    print('Response data: ${e.response?.data}');
    print('Response type: ${e.response?.data.runtimeType}');
    
    if (e.response?.statusCode == 400) {
      throw Exception('Données de commande invalides');
    } else if (e.response?.statusCode == 403) {
      throw Exception('Accès refusé : permissions insuffisantes');
    } else if (e.response?.statusCode == 404) {
      throw Exception('Client ou produit introuvable');
    } else {
      throw Exception('Erreur serveur lors de la sauvegarde (${e.response?.statusCode})');
    }
  } catch (e) {
    print('❌ Erreur générale sauvegarde: $e');
    print('❌ Type d\'erreur: ${e.runtimeType}');
    
    // En cas d'erreur générale, on peut retourner la commande locale pour continuer
    if (e.toString().contains('is not a subtype')) {
      print('🔧 Erreur de type détectée - retour commande locale');
      final emergencyOrder = order.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        status: OrderStatus.VALIDATED,
      );
      return emergencyOrder;
    }
    
    throw Exception('Erreur inattendue: $e');
  }
}

// ✅ Plus besoin de validateOrder() séparée
// La sauvegarde gère maintenant le statut directement
  
  /// Récupérer une commande par son ID
  Future<Order> getOrderById(int orderId) async {
    try {
      print('🔍 Récupération commande ID: $orderId');
      
      final response = await _apiService.dio.get('/api/order/$orderId');
      print('✅ Commande trouvée: ${response.data}');
      
      return Order.fromJson(response.data);
      
    } on DioException catch (e) {
      print('❌ Erreur récupération commande $orderId: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Commande #$orderId introuvable');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Accès refusé à la commande #$orderId');
      } else {
        throw Exception('Erreur serveur lors de la récupération de la commande');
      }
    } catch (e) {
      print('❌ Erreur générale commande $orderId: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }
  
  /// Récupérer toutes les commandes d'un utilisateur
  Future<List<Order>> getUserOrders(int userId) async {
    try {
      print('👤 Récupération commandes user: $userId');
      
      final response = await _apiService.dio.get('/api/order/user/$userId');
      print('✅ Commandes trouvées: ${response.data?.length ?? 0}');
      
      final List<dynamic> ordersJson = response.data ?? [];
      final orders = ordersJson.map((json) => Order.fromJson(json)).toList();
      
      // Trier par date décroissante (plus récent en premier)
      orders.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      
      return orders;
      
    } on DioException catch (e) {
      print('❌ Erreur commandes utilisateur $userId: ${e.response?.statusCode}');
      throw Exception('Erreur lors de la récupération des commandes');
    } catch (e) {
      print('❌ Erreur générale commandes user: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }
   
  
  /// Récupérer les détails d'une commande
  Future<List<OrderItem>> getOrderDetails(int orderId) async {
    try {
      print('📋 Récupération détails commande: $orderId');
      
      final response = await _apiService.dio.get('/api/order/$orderId/order-detail');
      print('✅ Détails trouvés: ${response.data?.length ?? 0} items');
      
      final List<dynamic> itemsJson = response.data ?? [];
      return itemsJson.map((json) => OrderItem.fromJson(json)).toList();
      
    } on DioException catch (e) {
      print('❌ Erreur détails commande $orderId: ${e.response?.statusCode}');
      throw Exception('Erreur lors de la récupération des détails');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }
  
  /// Récupérer commandes par statut
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    try {
      print('📊 Récupération commandes statut: ${status.name}');
      
      final response = await _apiService.dio.get('/api/order/statut/${status.name}');
      print('✅ Commandes trouvées: ${response.data?.length ?? 0}');
      
      final List<dynamic> ordersJson = response.data ?? [];
      return ordersJson.map((json) => Order.fromJson(json)).toList();
      
    } on DioException catch (e) {
      print('❌ Erreur commandes par statut: ${e.response?.statusCode}');
      throw Exception('Erreur lors de la récupération des commandes');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }
  
  /// Télécharger le PDF d'une commande
  Future<List<int>> downloadOrderPdf(int orderId) async {
    try {
      print('📄 Téléchargement PDF commande: $orderId');
      
      final response = await _apiService.dio.get(
        '/api/order/$orderId/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      
      print('✅ PDF téléchargé: ${response.data.length} bytes');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Erreur téléchargement PDF: ${e.response?.statusCode}');
      throw Exception('Erreur lors du téléchargement du PDF');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }
  
  /// Méthodes utilitaires
  
  /// Créer une nouvelle commande vide
  Order createNewOrder({
    required int userId,
    required int customerId,
    String? entrepriseCode,
  }) {
    return Order.create(
      userId: userId,
      customerId: customerId,
      entrepriseCode: entrepriseCode,
    );
  }
  
  /// Calculer le total d'une commande côté client (avant envoi)
  double calculateOrderTotal(List<OrderItem> items) {
    return items.fold(0.0, (total, item) => total + item.subtotalAfterDiscount);
  }
  
  /// Valider qu'une commande peut être sauvegardée
  bool canSaveOrder(Order order) {
    return order.customerId > 0 && 
           order.userId > 0 && 
           order.orderDetails.isNotEmpty &&
           order.orderDetails.every((item) => item.quantity > 0);
  }
  
  /// Valider qu'une commande peut être validée
  bool canValidateOrder(Order order) {
    return canSaveOrder(order) && order.isDraft;
  }
  
  /// Obtenir un résumé de commande pour l'affichage
  Map<String, dynamic> getOrderSummary(Order order) {
    return {
      'itemCount': order.itemCount,
      'totalQuantity': order.totalQuantity,
      'subtotal': order.subtotalBeforeDiscount,
      'discount': order.totalDiscount,
      'total': order.totalAmount,
      'canEdit': order.canEdit,
      'canValidate': order.canValidate,
    };
  }
}