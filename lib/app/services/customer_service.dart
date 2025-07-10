import 'package:dio/dio.dart';
import 'package:erp_mobile/app/services/api_service.dart';
import 'package:get/get.dart';
import '../models/customer.dart';


class CustomerService extends GetxService {
   final ApiService _apiService = Get.find<ApiService>();
  
Future<Customer> geCustomerById(int customerId) async {
  try {
    
    final response = await _apiService.dio.get('/api/customers/$customerId');
    
    print('Customer trouvé: ${response.data}');
    return Customer.fromJson(response.data);
    
  } on DioException catch (e) {
    print('Erreur Dio: ${e.response?.statusCode}');
    print('Response data: ${e.response?.data}');
    
    if (e.response?.statusCode == 403) {
      throw Exception('Accès refusé : permissions insuffisantes');
    } else {
      throw Exception('Erreur serveur lors de la récupération du client');
    }
  } catch (e) {
    print('Erreur générale: $e');
    throw Exception('Erreur inattendue: $e');
  }
} 

}