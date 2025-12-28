import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/sale_request.dart';
import '../models/sale_response.dart';
import '../models/sales_document_history.dart';
import '../exceptions/app_exceptions.dart';
import 'api_service.dart';

class SalesService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Créer une vente
  Future<SaleResponse> createSale(SaleRequest request) async {
    final response = await _apiService.dio.post('/api/sales', data: request.toJson());

    if (response.data is! Map<String, dynamic>) {
      throw UnexpectedException(
        'Invalid server response for sale creation',
        originalError: response.data,
      );
    }
    return SaleResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Historique unifié des ventes (ORDER + BL) pour un utilisateur
  Future<List<SalesDocumentHistory>> getUserHistory(int userId) async {
    final response = await _apiService.dio.get('/api/sales/history/user/$userId');

    if (response.data is List) {
      final List<dynamic> jsonList = response.data as List<dynamic>;
      return jsonList
          .map((json) => SalesDocumentHistory.fromJson(json))
          .toList();
    }

    return [];
  }

  /// Détails d'un document de vente (ORDER ou BL)
  Future<SalesDocumentHistory> getDocumentDetails(String documentType, int documentId) async {
    final response = await _apiService.dio.get('/api/sales/$documentType/$documentId/details');

    if (response.data is! Map<String, dynamic>) {
      throw UnexpectedException(
        'Invalid server response for document details',
        originalError: response.data,
      );
    }
    return SalesDocumentHistory.fromJson(response.data as Map<String, dynamic>);
  }

  /// Télécharger le PDF d'un document de vente
  Future<List<int>> downloadDocumentPdf(String documentType, int documentId) async {
    final response = await _apiService.dio.get(
      '/api/sales/$documentType/$documentId/pdf',
      options: Options(responseType: ResponseType.bytes),
    );
    
    return response.data;
  }
}
