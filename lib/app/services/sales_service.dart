import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/sale_request.dart';
import '../models/sale_response.dart';
import '../models/sales_document_history.dart';
import '../models/order.dart';
import 'api_service.dart';
import '../../services/api_client.dart';

class SalesService extends GetxService {
  final ApiClient _apiClient = ApiClient();

  Future<SaleResponse> createSale(SaleRequest request) async {
    final response = await _apiClient.post('/api/sales', data: request.toJson());

    if (response.data is Map<String, dynamic>) {
      return SaleResponse.fromJson(response.data as Map<String, dynamic>);
    }

    throw Exception('Réponse invalide du serveur pour /api/sales');
  }

  /// Historique unifié des ventes (ORDER + BL) pour un utilisateur
  Future<List<SalesDocumentHistory>> getUserHistory(int userId) async {
    final response = await _apiClient.get('/api/sales/history/user/$userId');

    if (response.data is List) {
      final List<dynamic> jsonList = response.data as List<dynamic>;
      return jsonList
          .map((e) => SalesDocumentHistory.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Réponse invalide du serveur pour l\'historique des ventes');
  }

  /// Récupérer les détails d'un document (ORDER ou BL)
  /// Retourne un Order (réutilise le modèle existant)
  Future<Order> getDocumentDetails({
    required String type,
    required int id,
  }) async {
    final response = await _apiClient.get('/api/sales/documents/details',
      queryParameters: {
        'type': type,
        'id': id,
      },
    );

    if (response.data is Map<String, dynamic>) {
      // Le backend retourne SalesDocumentHistoryDto avec lines
      // On le transforme en Order pour réutiliser l'écran existant
      final data = response.data as Map<String, dynamic>;
      
      // Transformer les lignes en orderDetails
      final List<dynamic> linesJson = data['lines'] ?? [];
      final orderDetails = linesJson.map((line) {
        return {
          'id': line['id'],
          'productId': line['productId'] ?? 0,
          'product': null, // Ne pas créer d'objet Product complet, juste l'ID
          'designation': line['productName'] ?? '',
          'quantity': line['quantity'] ?? 0,
          'price': line['price'] ?? 0.0,
          'discount': line['discount'] ?? 0.0,
          'lineTotalHT': line['lineTotalHT'] ?? 0.0,
        };
      }).toList();
      
      // Construire un JSON compatible avec Order.fromJson
      final orderJson = {
        'id': data['id'],
        'userId': data['userId'] ?? 0,
        'customerId': data['customerId'] ?? 0,
        'createdDate': data['documentDate'],
        'status': data['status'] ?? 'DRAFT',
        'totalAmount': data['totalAmount'] ?? 0.0,
        'totalAmountTTC': data['totalAmountTTC'] ?? 0.0,
        'totalDiscount': data['totalDiscount'] ?? 0.0,
        'comment': data['comment'],
        'orderDetails': orderDetails,
      };
      
      return Order.fromJson(orderJson);
    }

    throw Exception('Réponse invalide du serveur pour les détails du document');
  }

  /// Télécharger le PDF d'un document de vente (ORDER, BL, ...)
  Future<List<int>> downloadDocumentPdf({
    required String type,
    required int id,
  }) async {
    final response = await _apiClient.get(
      '/sales/documents/pdf',
      queryParameters: {
        'type': type,
        'id': id,
      },
      options: Options(responseType: ResponseType.bytes),
    );

    return response.data;
  }
}
