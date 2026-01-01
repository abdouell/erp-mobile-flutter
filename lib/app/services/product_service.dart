import 'package:get/get.dart';
import '../models/product.dart';
import 'api_service.dart';
import '../../services/api_client.dart';

class ProductService extends GetxService {
  final ApiClient _apiClient = ApiClient();
  
  // Cache simple pour les produits
  List<Product>? _cachedProducts;

  /// Récupérer tous les produits
  Future<List<Product>> getAllProducts() async {
    // Utiliser le cache si disponible
    if (_cachedProducts != null) {
      return _cachedProducts!;
    }
    
    final response = await _apiClient.get('/api/product');

    final List<dynamic> productsJson = response.data ?? [];
    final products = productsJson.map((json) => Product.fromJson(json)).toList();
    
    // Mise en cache
    _cachedProducts = products;
    
    return products;
  }
  
  /// Obtenir les catégories disponibles
  Future<List<String>> getAvailableCategories() async {
    final products = await getAllProducts();
    
    final categories = products
        .map((p) => p.productCategoryCode)
        .toSet()
        .toList();
    
    categories.sort(); // Tri alphabétique
    
    return categories;
  }
  
  /// Récupérer les produits disponibles en stock pour un emplacement
  /// Avec pricing client si customerId fourni
  /// Utilisé pour les vendeurs conventionnels
  Future<List<Product>> getProductsByEmplacement(String emplacementCode, {int? customerId}) async {
    final response = await _apiClient.get('/api/product/emplacement/$emplacementCode/stock',
      queryParameters: customerId != null ? {'customerId': customerId} : null,
    );

    final List<dynamic> productsJson = response.data ?? [];
    final products = productsJson.map((json) => Product.fromJson(json)).toList();
    
    return products;
  }
  
  /// Récupérer les produits avec tarification client personnalisée
  /// Affiche prix catalogue + prix client + % remise
  Future<List<Product>> getProductsForCustomer(int customerId) async {
    final response = await _apiClient.get('/api/product/customer/$customerId/pricing');
    
    final List<dynamic> productsJson = response.data ?? [];
    final products = productsJson.map((json) => Product.fromJson(json)).toList();
    
    return products;
  }
  
  /// Vider le cache des produits
  void clearCache() {
    _cachedProducts = null;
  }
}
