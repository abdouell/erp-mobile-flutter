import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Cache pour éviter les appels répétés
  List<Product>? _cachedProducts;
  
  /// Récupérer tous les produits
  Future<List<Product>> getAllProducts() async {
    try {

      // Utiliser le cache si disponible
      if (_cachedProducts != null) {
        return _cachedProducts!;
      }
      
      final response = await _apiService.dio.get('/api/product');

      final List<dynamic> productsJson = response.data ?? [];
      final products = productsJson.map((json) => Product.fromJson(json)).toList();
      
      // Mise en cache
      _cachedProducts = products;
      
      return products;
      
    } on DioException catch (e) {
      
      if (e.response?.statusCode == 403) {
        throw Exception('Accès refusé : permissions insuffisantes pour voir les produits');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Endpoint produits non trouvé');
      } else {
        throw Exception('Erreur serveur lors de la récupération des produits');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }
  
  /// Obtenir les catégories disponibles
  Future<List<String>> getAvailableCategories() async {
    try {
      final products = await getAllProducts();
      
      final categories = products
          .map((p) => p.productCategoryCode)
          .toSet()
          .toList();
      
      categories.sort(); // Tri alphabétique
      
      return categories;
      
    } catch (e) {
      throw Exception('Erreur lors de la récupération des catégories');
    }
  }
  
  /// Vider le cache
  void clearCache() {
    _cachedProducts = null;
  }

  /// Récupérer les produits disponibles en stock pour un emplacement
/// Avec pricing client si customerId fourni
/// Utilisé pour les vendeurs conventionnels
Future<List<Product>> getProductsByEmplacement(String emplacementCode, {int? customerId}) async {
  try {

    final response = await _apiService.dio.get(
      '/api/product/emplacement/$emplacementCode/stock',
      queryParameters: customerId != null ? {'customerId': customerId} : null,
    );

    final List<dynamic> productsJson = response.data ?? [];
    final products = productsJson.map((json) => Product.fromJson(json)).toList();
    
    return products;
    
  } on DioException catch (e) {
    
    if (e.response?.statusCode == 403) {
      throw Exception('Accès refusé : permissions insuffisantes');
    } else if (e.response?.statusCode == 404) {
      throw Exception('Emplacement non trouvé');
    } else {
      throw Exception('Erreur serveur lors de la récupération des produits');
    }
  } catch (e) {
    throw Exception('Erreur inattendue: $e');
  }
}

/// Récupérer les produits avec tarification client personnalisée
/// Affiche prix catalogue + prix client + % remise
Future<List<Product>> getProductsForCustomer(int customerId) async {
  try {
    
    final response = await _apiService.dio.get('/api/product/customer/$customerId/pricing');
    
    final List<dynamic> productsJson = response.data ?? [];
    final products = productsJson.map((json) => Product.fromJson(json)).toList();
    
    return products;
    
  } on DioException catch (e) {
    
    if (e.response?.statusCode == 403) {
      throw Exception('Accès refusé : permissions insuffisantes pour voir les produits');
    } else if (e.response?.statusCode == 404) {
      throw Exception('Client non trouvé');
    } else {
      throw Exception('Erreur serveur lors de la récupération des produits');
    }
  } catch (e) {
    throw Exception('Erreur inattendue: $e');
  }
}

}
