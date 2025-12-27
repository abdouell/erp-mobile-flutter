// Dans votre customer_service.dart, corrigez la méthode :

import 'package:dio/dio.dart';
import 'package:erp_mobile/app/models/order.dart';
import 'package:get/get.dart';
import '../models/customer.dart';
import 'api_service.dart';

class CustomerService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// 👤 RÉCUPÉRER UN CLIENT PAR ID - MÉTHODE CORRIGÉE
  Future<Customer> getCustomerById(int customerId) async {
    try {
      
      final response = await _apiService.dio.get('/api/customers/$customerId');

      return Customer.fromJson(response.data);
      
    } on DioException catch (e) {
      
      if (e.response?.statusCode == 404) {
        throw Exception('Client #$customerId introuvable');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Accès refusé au client #$customerId');
      } else {
        throw Exception('Erreur serveur lors de la récupération du client');
      }
    } catch (e) {
      throw Exception('Erreur réseau: Impossible de contacter le serveur');
    }
  }

  /// RÉCUPÉRER TOUS LES CLIENTS
  Future<List<Customer>> getAllCustomers() async {
    try {
      final response = await _apiService.dio.get('/api/customers');
      final List<dynamic> customersJson = response.data ?? [];
      return customersJson.map((json) => Customer.fromJson(json)).toList();
      
    } on DioException catch (e) {
      throw Exception('Erreur lors de la récupération des clients');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// 🔍 RECHERCHER DES CLIENTS
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final response = await _apiService.dio.get('/api/customers/search', queryParameters: {
        'q': query,
      });
      
      final List<dynamic> customersJson = response.data ?? [];
      final customers = customersJson.map((json) => Customer.fromJson(json)).toList();
      
      return customers;
      
    } on DioException catch (e) {
      throw Exception('Erreur lors de la recherche de clients');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// 📍 RÉCUPÉRER CLIENTS PAR TOURNÉE
  Future<List<Customer>> getCustomersByTournee(String tourneeId) async {
    try {

      final response = await _apiService.dio.get('/api/customers/tournee/$tourneeId');
      
      final List<dynamic> customersJson = response.data ?? [];
      final customers = customersJson.map((json) => Customer.fromJson(json)).toList();
      
      return customers;
      
    } on DioException catch (e) {
      throw Exception('Erreur lors de la récupération des clients de la tournée');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// 📋 RÉCUPÉRER COMMANDES D'UN CLIENT
Future<List<Order>> getCustomerOrders(int customerId) async {
  try {
    final response = await _apiService.dio.get('/api/order/customer/$customerId');

    final List<dynamic> ordersJson = response.data ?? [];
    final orders = ordersJson.map((json) => Order.fromJson(json)).toList();
    
    // Trier par date décroissante (plus récent en premier)
    orders.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    
    return orders;
    
  } on DioException catch (e) {
    throw Exception('Erreur lors de la récupération des commandes du client');
  } catch (e) {
    throw Exception('Erreur inattendue: $e');
  }
}

}
