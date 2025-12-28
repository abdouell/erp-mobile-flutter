import 'package:get/get.dart';
import '../models/customer.dart';
import '../models/order.dart';
import 'api_service.dart';

class CustomerService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Récupérer un client par son ID
  Future<Customer> getCustomerById(int customerId) async {
    final response = await _apiService.dio.get('/api/customers/$customerId');
    return Customer.fromJson(response.data);
  }

  /// RÉCUPÉRER TOUS LES CLIENTS
  Future<List<Customer>> getAllCustomers() async {
    final response = await _apiService.dio.get('/api/customers');
    final List<dynamic> customersJson = response.data ?? [];
    return customersJson.map((json) => Customer.fromJson(json)).toList();
  }

  /// 🔍 RECHERCHER DES CLIENTS
  Future<List<Customer>> searchCustomers(String query) async {
    final response = await _apiService.dio.get('/api/customers/search', queryParameters: {
      'q': query,
    });
    final List<dynamic> customersJson = response.data ?? [];
    return customersJson.map((json) => Customer.fromJson(json)).toList();
  }

  /// Récupérer les clients d'une tournée
  Future<List<Customer>> getCustomersByTournee(String tourneeId) async {
    final response = await _apiService.dio.get('/api/customers/tournee/$tourneeId');
    final List<dynamic> customersJson = response.data ?? [];
    return customersJson.map((json) => Customer.fromJson(json)).toList();
  }

  /// Récupérer les commandes d'un client
  Future<List<Order>> getCustomerOrders(int customerId) async {
    final response = await _apiService.dio.get('/api/order/customer/$customerId');
    final List<dynamic> ordersJson = response.data ?? [];
    final orders = ordersJson.map((json) => Order.fromJson(json)).toList();
    orders.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return orders;
  }
}
