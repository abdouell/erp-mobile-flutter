import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../exceptions/app_exceptions.dart';
import 'api_service.dart';

class OrderService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  
  /// Créer ou mettre à jour une commande
  Future<Order> saveOrder(Order order, {int? clientTourneeId}) async {
    final orderData = order.toJson();

    if (clientTourneeId != null) {
      orderData['clientTourneeId'] = clientTourneeId;
    }
    
    final response = await _apiService.dio.post('/api/order', data: orderData);
    
    // Map response data to Order object
    if (response.data is! Map<String, dynamic>) {
      throw UnexpectedException(
        'Invalid server response for order save',
        originalError: response.data,
      );
    }
    return Order.fromJson(response.data);
  }

  /// Récupérer une commande par son ID
  Future<Order> getOrderById(int orderId) async {
    final response = await _apiService.dio.get('/api/order/$orderId');
    return Order.fromJson(response.data);
  }
  
  /// Récupérer toutes les commandes d'un utilisateur
  Future<List<Order>> getUserOrders(int userId) async {
    final response = await _apiService.dio.get('/api/order/user/$userId');
    
    final List<dynamic> ordersJson = response.data ?? [];
    final orders = ordersJson.map((json) => Order.fromJson(json)).toList();
    
    // Trier par date décroissante (plus récent en premier)
    orders.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    
    return orders;
  }
   
  
  /// Récupérer les détails d'une commande
  Future<List<OrderItem>> getOrderDetails(int orderId) async {
    final response = await _apiService.dio.get('/api/order/$orderId/order-detail');
    
    final List<dynamic> itemsJson = response.data ?? [];
    return itemsJson.map((json) => OrderItem.fromJson(json)).toList();
  }
  
  /// Récupérer commandes par statut
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    final response = await _apiService.dio.get('/api/order/statut/${status.name}');
    
    final List<dynamic> ordersJson = response.data ?? [];
    return ordersJson.map((json) => Order.fromJson(json)).toList();
  }
  
  /// Télécharger le PDF d'une commande
  Future<List<int>> downloadOrderPdf(int orderId) async {
    final response = await _apiService.dio.get(
      '/api/order/$orderId/pdf',
      options: Options(responseType: ResponseType.bytes),
    );
    
    return response.data;
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
