import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/payment.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Récupérer les paiements d'un document (BL)
  Future<List<Payment>> getPaymentsByDocument(int documentId) async {
    try {
      final response = await _apiService.dio.get('/api/payments/document/$documentId');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Payment.fromJson(json))
            .toList();
      }

      return [];
    } on DioError catch (e) {
      print('❌ Erreur chargement paiements document: ${e.response?.statusCode}');
      throw Exception('Impossible de charger les paiements');
    } catch (e) {
      print('❌ Erreur chargement paiements document: $e');
      throw Exception('Impossible de charger les paiements');
    }
  }

  /// Récupérer les paiements d'un client
  Future<List<Payment>> getPaymentsByClient(int clientId) async {
    try {
      final response = await _apiService.dio.get('/api/payments/client/$clientId');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Payment.fromJson(json))
            .toList();
      }

      return [];
    } on DioError catch (e) {
      print('❌ Erreur chargement paiements client: ${e.response?.statusCode}');
      throw Exception('Impossible de charger les paiements du client');
    } catch (e) {
      print('❌ Erreur chargement paiements client: $e');
      throw Exception('Impossible de charger les paiements du client');
    }
  }

  /// Créer un nouveau paiement
  Future<Payment> createPayment({
    required int salesDocumentId,
    required int clientId,
    required int userId,
    required double amount,
    required String method,
    String? note,
  }) async {
    try {
      final response = await _apiService.dio.post('/api/payments', data: {
        'salesDocumentId': salesDocumentId,
        'clientId': clientId,
        'userId': userId,
        'amount': amount,
        'method': method,
        'note': note,
      });

      return Payment.fromJson(response.data);
    } on DioError catch (e) {
      print('❌ Erreur création paiement: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        throw Exception('Données invalides');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Accès refusé');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Document ou client introuvable');
      } else {
        throw Exception('Erreur serveur');
      }
    } catch (e) {
      print('❌ Erreur création paiement: $e');
      throw Exception('Impossible de créer le paiement');
    }
  }
}
