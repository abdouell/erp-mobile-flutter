import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/sale_request.dart';
import '../models/sale_response.dart';
import '../models/sales_document_history.dart';
import 'api_service.dart';

class SalesService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<SaleResponse> createSale(SaleRequest request) async {
    try {
      final response = await _apiService.dio.post('/api/sales', data: request.toJson());

      if (response.data is Map<String, dynamic>) {
        return SaleResponse.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Réponse invalide du serveur pour /api/sales');
    } on DioException catch (e) {
      String serverMessage = 'Erreur inconnue';

      if (e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          serverMessage = e.response?.data['message'] ?? e.response?.data.toString();
        } else if (e.response?.data is String) {
          serverMessage = e.response?.data as String;
        }
      }

      throw Exception(serverMessage);
    }
  }

  /// Historique unifié des ventes (ORDER + BL) pour un utilisateur
  Future<List<SalesDocumentHistory>> getUserHistory(int userId) async {
    try {
      final response = await _apiService.dio.get('/api/sales/history/user/$userId');

      if (response.data is List) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList
            .map((e) => SalesDocumentHistory.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Réponse invalide du serveur pour l\'historique des ventes');
    } on DioException catch (e) {
      String serverMessage = 'Erreur inconnue';

      if (e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          serverMessage = e.response?.data['message'] ?? e.response?.data.toString();
        } else if (e.response?.data is String) {
          serverMessage = e.response?.data as String;
        }
      }

      throw Exception(serverMessage);
    }
  }
}
