import 'package:get/get.dart';
import '../models/payment.dart';
import 'api_service.dart';

class PaymentService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Récupérer tous les paiements
  Future<List<Payment>> getAllPayments() async {
    final response = await _apiService.dio.get('/api/payments');

    if (response.data is List) {
      return (response.data as List)
          .map((json) => Payment.fromJson(json))
          .toList();
    }

    return [];
  }

  /// Récupérer les paiements d'un client
  Future<List<Payment>> getPaymentsByClient(int clientId) async {
    final response = await _apiService.dio.get('/api/payments/client/$clientId');

    if (response.data is List) {
      return (response.data as List)
          .map((json) => Payment.fromJson(json))
          .toList();
    }

    return [];
  }

  /// Créer un paiement
  Future<Payment> createPayment(Payment payment) async {
    final response = await _apiService.dio.post(
      '/api/payments',
      data: payment.toJson(),
    );
    
    return Payment.fromJson(response.data);
  }

  /// Mettre à jour un paiement
  Future<Payment> updatePayment(Payment payment) async {
    final response = await _apiService.dio.put(
      '/api/payments/${payment.id}',
      data: payment.toJson(),
    );
    
    return Payment.fromJson(response.data);
  }

  /// Supprimer un paiement
  Future<void> deletePayment(int paymentId) async {
    await _apiService.dio.delete('/api/payments/$paymentId');
  }
}
