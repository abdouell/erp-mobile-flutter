import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import 'api_service.dart';

class OrderService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  
  /// Créer ou mettre à jour une commande
Future<Order> saveOrder(Order order, {int? clientTourneeId}) async {
    try {
      final orderData = order.toJson();

      if (clientTourneeId != null) {
        orderData['clientTourneeId'] = clientTourneeId;
      }
      
      print('📤 Données envoyées: $orderData');
      
      final response = await _apiService.dio.post('/api/order', data: orderData);
      

      // CHANGEMENT: Plus de fallback, vraies exceptions
      if (response.data == null || response.data == "" || response.data is String) {
        throw Exception('Le serveur a retourné une réponse vide ou invalide. La sauvegarde a peut-être échoué.');
      } else if (response.data is Map<String, dynamic>) {
        try {
          final savedOrder = Order.fromJson(response.data);
          return savedOrder;
        } catch (parseError) {
          print('❌ Erreur parsing JSON: $parseError');
          throw Exception('Impossible de parser la réponse du serveur: $parseError');
        }
      } else {
        throw Exception('Le serveur a retourné un type de réponse inattendu: ${response.data.runtimeType}');
      }
      
    } on DioException catch (e) {
    print('❌ Erreur Dio sauvegarde commande: ${e.response?.statusCode}');
    print('Response data: ${e.response?.data}');
    
    // ✅ Extraire le message du serveur s'il existe
    String serverMessage = 'Erreur inconnue';
    
    if (e.response?.data != null) {
      if (e.response?.data is Map<String, dynamic>) {
        serverMessage = e.response?.data['message'] ?? e.response?.data.toString();
      } else if (e.response?.data is String) {
        serverMessage = e.response?.data;
      }
    }
    
    // Lancer l'exception avec le message du serveur
    if (e.response?.statusCode == 400) {
      throw Exception(serverMessage);
    } else if (e.response?.statusCode == 403) {
      throw Exception('Accès refusé: permissions insuffisantes');
    } else if (e.response?.statusCode == 404) {
      throw Exception('Client ou produit introuvable');
    } else if (e.response?.statusCode == 500) {
      throw Exception('Erreur serveur interne. Veuillez réessayer plus tard.');
    } else if (e.response?.statusCode == 503) {
      throw Exception('Service temporairement indisponible');
    } else {
      throw Exception(serverMessage);
    }
  }
  }

// ✅ Plus besoin de validateOrder() séparée
// La sauvegarde gère maintenant le statut directement
  
  /// Récupérer une commande par son ID
  Future<Order> getOrderById(int orderId) async {
    try {

      final response = await _apiService.dio.get('/api/order/$orderId');

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

      final response = await _apiService.dio.get('/api/order/user/$userId');

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
      final response = await _apiService.dio.get('/api/order/$orderId/order-detail');

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
